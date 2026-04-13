#!/usr/bin/env bash
# ------------------------------------------------------------------
# Client Branch Bootstrap Script (Linux/macOS)
# Purpose: Minimal, linear steps for non-technical operators to set up
# an isolated client deployment agent after branch provisioning.
# ------------------------------------------------------------------
set -euo pipefail

LIGHT_BLUE='\033[1;34m'; GREEN='\033[1;32m'; RED='\033[1;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
STEP(){ echo -e "${LIGHT_BLUE}\n[STEP] $1${NC}"; }
INFO(){ echo -e "${GREEN}[OK]${NC} $1"; }
WARN(){ echo -e "${YELLOW}[WARN]${NC} $1"; }
ERR(){ echo -e "${RED}[ERROR]${NC} $1" >&2; }

if [[ $(id -u) -eq 0 ]]; then
  WARN "Running as root is not recommended. Use a deployment user."; fi

if [[ -z "${CLIENT_ID:-}" ]]; then
  ERR "CLIENT_ID not set. Export CLIENT_ID=your-client-id first."; exit 1; fi
if [[ -z "${GIT_REPO_URL:-}" ]]; then
  ERR "GIT_REPO_URL not set. Export GIT_REPO_URL=https://... or git@github.com:owner/repo.git"; exit 1; fi
if [[ -z "${GIT_BRANCH:-}" ]]; then
  ERR "GIT_BRANCH not set. Export GIT_BRANCH=client-${CLIENT_ID}/production"; exit 1; fi

# Optional network binding & health port
HOST=${HOST:-127.0.0.1}
REQUESTED_HEALTH_PORT=${HEALTH_CHECK_PORT:-}

check_port_in_use(){
  local port="$1"
  # Use ss or netstat; suppress errors for portability
  if command -v ss >/dev/null 2>&1; then
    ss -ltn 2>/dev/null | grep -E "[:.]${port}\\b" >/dev/null 2>&1 && return 0 || return 1
  elif command -v netstat >/dev/null 2>&1; then
    netstat -ltn 2>/dev/null | grep -E "[:.]${port}\\b" >/dev/null 2>&1 && return 0 || return 1
  elif command -v lsof >/dev/null 2>&1; then
    lsof -iTCP -sTCP:LISTEN -P 2>/dev/null | grep -E ":${port} ->|:${port} " >/dev/null 2>&1 && return 0 || return 1
  else
    # Fallback: cannot determine; assume free
    return 1
  fi
}

find_free_port(){
  local start="$1"; local p=$start; local max=$((start+50));
  while [ $p -le $max ]; do
    if ! check_port_in_use "$p"; then echo "$p"; return 0; fi
    p=$((p+1))
  done
  return 1
}

if [[ -n "$REQUESTED_HEALTH_PORT" ]]; then
  if check_port_in_use "$REQUESTED_HEALTH_PORT"; then
    WARN "Requested HEALTH_CHECK_PORT=$REQUESTED_HEALTH_PORT already in use. Searching for a free one..."
    HEALTH_CHECK_PORT=$(find_free_port $((REQUESTED_HEALTH_PORT+1)) || echo 9090)
  else
    HEALTH_CHECK_PORT="$REQUESTED_HEALTH_PORT"
  fi
else
  HEALTH_CHECK_PORT=$(find_free_port 9090 || echo 9090)
fi

export HEALTH_CHECK_PORT
export HOST
INFO "Using HOST=$HOST HEALTH_CHECK_PORT=$HEALTH_CHECK_PORT"

CLONE_METHOD=${CLONE_METHOD:-}
if [[ -n "${USE_SSH:-}" && -z "$CLONE_METHOD" ]]; then CLONE_METHOD="ssh"; fi
if [[ -z "$CLONE_METHOD" ]]; then
  # Auto-detect from URL
  if [[ "$GIT_REPO_URL" =~ ^git@ ]]; then CLONE_METHOD="ssh"; else CLONE_METHOD="https"; fi
fi

EFFECTIVE_CLONE_URL="$GIT_REPO_URL"
if [[ "$CLONE_METHOD" == "https" ]]; then
  # Optional: Personal Access Token (fine-grained) for private repo access
  # Expected scopes: Contents: Read, Metadata: Read (per README Step 1.5)
  if [[ -z "${GIT_TOKEN:-}" ]]; then
    WARN "(HTTPS mode) GIT_TOKEN not set. Private repo clone may prompt or fail."
    WARN "Export GIT_TOKEN=ghp_yourtoken (fine-grained) to enable non-interactive clone."
  fi
  if [[ -n "${GIT_TOKEN:-}" ]]; then
    if [[ "$GIT_REPO_URL" =~ ^https:// ]]; then
      EFFECTIVE_CLONE_URL="https://${GIT_TOKEN}@${GIT_REPO_URL#https://}"
    else
      WARN "GIT_TOKEN provided but GIT_REPO_URL not https:// (skipping token injection)."
    fi
  fi
elif [[ "$CLONE_METHOD" == "ssh" ]]; then
  INFO "SSH clone mode selected (CLONE_METHOD=ssh). Ensure your SSH key is loaded (ssh-add -l)."
  if ! ssh -o BatchMode=yes -T git@github.com 2>/dev/null; then
    WARN "SSH pre-auth test failed or interactive. If it hangs, ensure ssh-agent is running and key added: eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_rsa"
  fi
else
  WARN "Unknown CLONE_METHOD=$CLONE_METHOD (expected ssh or https). Proceeding with literal URL."; CLONE_METHOD="https"
fi

# Preflight: verify branch visibility (ls-remote) for chosen mode
STEP "0. Preflight repository access ($CLONE_METHOD)"
if ! command -v git >/dev/null 2>&1; then ERR "git command not found."; exit 1; fi

if [[ "$CLONE_METHOD" == "https" ]]; then
  if ! git ls-remote --heads "$EFFECTIVE_CLONE_URL" "$GIT_BRANCH" >/dev/null 2>&1; then
    if [[ -z "${GIT_TOKEN:-}" ]]; then
      ERR "Cannot access $GIT_BRANCH via HTTPS at $GIT_REPO_URL. Set GIT_TOKEN or switch to SSH (CLONE_METHOD=ssh)."; exit 1
    else
      ERR "Access denied even with provided GIT_TOKEN. Check token permissions (Contents: Read)."; exit 1
    fi
  else
    INFO "Preflight access OK (HTTPS)."
  fi
elif [[ "$CLONE_METHOD" == "ssh" ]]; then
  # Use original URL (EFFECTIVE_CLONE_URL may still be ssh form already)
  if ! git ls-remote --heads "$GIT_REPO_URL" "$GIT_BRANCH" >/dev/null 2>&1; then
    ERR "SSH access failed for $GIT_BRANCH at $GIT_REPO_URL. Ensure your SSH key has repo read access."; exit 1
  else
    INFO "Preflight access OK (SSH)."
  fi
fi

BOOT_DIR=${BOOT_DIR:-/opt/deployment}
REPO_DIR="$BOOT_DIR/repo"

# If the script is already inside a suitable git repo with correct branch, reuse it
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')
  REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo '')
  # Normalize remote URL (strip token if present)
  SANITIZED_REMOTE=${REMOTE_URL#https://*:@}
  if [[ "$CURRENT_BRANCH" == "$GIT_BRANCH" ]]; then
    # Compare by suffix to allow token injected URL
    if [[ -n "$REMOTE_URL" && "$GIT_REPO_URL" == *"${SANITIZED_REMOTE##*/}"* || "$REMOTE_URL" == *"${GIT_REPO_URL##*/}"* ]]; then
      INFO "Detected existing matching repository in current directory. Reusing without re-clone."
      REPO_DIR="$(pwd)"
      SKIP_CLONE=1
    fi
  fi
fi

STEP "1. Creating base directories"
sudo mkdir -p "$BOOT_DIR" || true
sudo chown "$(id -u)":"$(id -g)" "$BOOT_DIR"

if [[ "${SKIP_CLONE:-0}" -eq 1 ]]; then
  STEP "2. Using existing repository (branch $GIT_BRANCH)"
  git fetch --all || WARN "Fetch failed; continuing with current state."
  git checkout "$GIT_BRANCH" || ERR "Failed to checkout $GIT_BRANCH" || exit 1
  git pull origin "$GIT_BRANCH" || WARN "Pull failed; proceeding with local copy."
else
  STEP "2. Cloning branch: $GIT_BRANCH"
  if [[ -d "$REPO_DIR/.git" ]]; then
    WARN "Repo already exists. Pulling updates."
    git -C "$REPO_DIR" fetch --all
    git -C "$REPO_DIR" checkout "$GIT_BRANCH"
    git -C "$REPO_DIR" pull origin "$GIT_BRANCH"
  else
    git clone --branch "$GIT_BRANCH" --single-branch "$EFFECTIVE_CLONE_URL" "$REPO_DIR"
  fi
  INFO "Repository ready."
  cd "$REPO_DIR"
fi

STEP "3. Installing Node dependencies"
if command -v npm >/dev/null 2>&1; then
  npm install --no-audit --no-fund
  INFO "Dependencies installed."
else
  ERR "npm not found. Install Node.js first."; exit 1
fi

STEP "4. Generating local configuration (if generator exists)"
if [[ -f scripts/generate-local-config.js ]]; then
  node scripts/generate-local-config.js load --client-id "$CLIENT_ID" || WARN "Config generation skipped/failed."
else
  WARN "Config generator script not found. Ensure .env exists."
fi

STEP "5. Basic validation"
if [[ -f scripts/test-database-connection.js ]]; then
  node scripts/test-database-connection.js || WARN "Database test failed. Continue if intentional (e.g., DB not up yet)."
else
  WARN "Database test script not found."
fi

STEP "6. Starting agent"
if [[ -f client-agent/deployment-agent.js ]]; then
  nohup npm start >/dev/null 2>&1 &
  INFO "Agent starting in background (use 'ps -ef | grep deployment-agent' to confirm)."
else
  ERR "Agent file missing (client-agent/deployment-agent.js)."; exit 1
fi

STEP "7. Health check warm-up"
for i in {1..10}; do
  sleep 2
  if curl -fs "http://localhost:${HEALTH_CHECK_PORT:-9090}/health" >/dev/null 2>&1; then
    INFO "Health endpoint responding."; break
  fi
  echo -n "."
  if [[ $i -eq 10 ]]; then WARN "Health endpoint not responding yet. Check logs."; fi
done

STEP "8. Summary"
cat <<EOF
------------------------------------------------------------------
Client ID        : $CLIENT_ID
Branch           : $GIT_BRANCH
Repo Directory   : $REPO_DIR
Health Endpoint  : http://${HOST}:${HEALTH_CHECK_PORT}/health
Status Endpoint  : http://${HOST}:${HEALTH_CHECK_PORT}/status
Logs (Linux)     : tail -f $REPO_DIR/logs/agent.log
Restart (manual) : (pkill -f deployment-agent.js && npm start) or systemctl restart service if installed
------------------------------------------------------------------
EOF

INFO "Bootstrap complete."