# dwdfe - Database Deployment Agent

**🔒 ISOLATED CLIENT BRANCH - COMPLETE SETUP GUIDE**

This branch contains everything needed to deploy and run the database deployment agent for **dwdfe**. Follow these instructions step-by-step for a successful installation.

## 📋 Client Information
- **Client ID:** client-9mal0yposmnxa2dzj
- **Environment:** development 
- **Git Branch:** client/dwdfe-development
- **Database:** postgresql
- **Health Check Port:** 3636

---

## 🚀 COMPLETE INSTALLATION GUIDE

### Prerequisites Check
Before starting, ensure you have:

#### 📦 **Git Installation**
**Windows:**
1. Download Git from: https://git-scm.com/download/win
2. Run the installer (.exe file)
3. During installation, select "Git from the command line and also from 3rd-party software"
4. Keep all other default settings
5. Verify installation: Open Command Prompt and type `git --version`

**macOS:**
1. Install via Homebrew: `brew install git`
2. Or download from: https://git-scm.com/download/mac
3. Verify installation: Open Terminal and type `git --version`

**Linux (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install git
git --version
```

**Linux (CentOS/RHEL):**

```bash
sudo yum install git
# or for newer versions
sudo dnf install git
git --version
```

#### 🟢 **Node.js Installation**
**Windows:**
1. Go to: https://nodejs.org/
2. Download the "LTS" version (Long Term Support)
3. Run the installer (.msi file)
4. Follow the installation wizard (keep default settings)
5. Verify installation: Open Command Prompt and type:
   - `node --version` (should show v18.x.x or newer)
   - `npm --version` (should show 9.x.x or newer)

**macOS:**
1. Install via Homebrew: `brew install node`
2. Or download from: https://nodejs.org/
3. Verify installation:
   - `node --version`
   - `npm --version`

**Linux (Ubuntu/Debian):**

```bash
# Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

**Linux (CentOS/RHEL):**

```bash
# Install Node.js LTS
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version
npm --version
```

#### ✅ **Additional Requirements**
- ✅ **Network access** to this repository
- ✅ **Database credentials** provided by your administrator
- ✅ **Administrative privileges** on your machine

### Step 1: Repository Access Setup

⚠️ **IMPORTANT:** This is a private repository requiring authentication.

#### 🔐 **Authentication Options**

**Option A: Repository Owner Provides Token (Recommended)**
If you're not the repository owner, request an access token from:
- **Repository Owner:** viriminfo
- **Contact:** solankimadhur65@gmail.com
- **Required Scope:** Read access to repository

**Option B: Public Repository Access**
If the repository is made public, no authentication is needed:

```bash
# No token required for public repos
git clone -b client/dwdfe-development https://github.com/viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj-deployment
```

**Option C: Download ZIP Package (No Git Required)**
If you cannot access Git or tokens, request a ZIP download:
1. Contact your administrator for a download link
2. OR visit: `http://your-server:3000/downloads/client-9mal0yposmnxa2dzj-deployment.zip`
3. Extract ZIP file to your desired location
4. Follow instructions in the extracted INSTALLATION.md file

**Quick ZIP Setup:**

```bash
# After downloading and extracting the ZIP
cd client-9mal0yposmnxa2dzj-deployment
npm install
# Configure your database settings in config/
npm start
```

**Option D: Personal Access Token (If you have repository access)**
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Fine-grained tokens"
3. Set expiration (recommend 90 days)
4. Select repository: viriminfo/int_256_Kratinn_database-deployment-system
5. **Configure Repository Permissions:**
   - **✅ Contents: Read** (Required - Access to repository files and folders)
   - **✅ Metadata: Read** (Required - Access to repository metadata)
   - ⚠️ **DO NOT SELECT:**
     - Actions (Not needed for cloning)
     - Administration (Not needed for cloning)
     - Issues (Not needed for cloning)
     - Pull requests (Not needed for cloning)
     - Security events (Not needed for cloning)
6. Click "Generate token"
7. **📋 COPY THE TOKEN IMMEDIATELY** (you won't see it again!)

   **📋 Required Permissions Summary:**
   
```
   Repository permissions:
   ✅ Contents: Read
   ✅ Metadata: Read
   ❌ All others: No access
```

#### 🔧 **Using Access Token**

**Method 1: Token in Clone URL (Most Secure)**

```bash
# Replace ACCESS_TOKEN with the token provided by repository owner
git clone -b client/dwdfe-development https://ACCESS_TOKEN@github.com/viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj-deployment
```

**Method 2: Configure Git Credentials**

```bash
# Set your username and token globally
git config --global user.name "your-github-username"
git config --global user.email "your-email@example.com"

# Store credentials (first time only)
git config --global credential.helper store

# Then clone normally (will prompt for token once)
git clone -b client/dwdfe-development https://github.com/viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj-deployment
```

**Method 3: SSH Key Authentication (Advanced)**

```bash
# If you have SSH keys set up with GitHub
git clone -b client/dwdfe-development git@github.com:viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj-deployment
```

### Step 2: Download, Configure & Run

#### Windows (Single Block)

```powershell
# (Run in PowerShell, Administrator only if target directory needs it)
git clone -b client/dwdfe-development https://YOUR_TOKEN@github.com/viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj-deployment
cd client-9mal0yposmnxa2dzj-deployment

# Required variables (non-interactive bootstrap)
$env:CLIENT_ID = "client-9mal0yposmnxa2dzj"
$env:GIT_REPO_URL = "https://github.com/viriminfo/int_256_Kratinn_database-deployment-system.git"
$env:GIT_BRANCH = "client/dwdfe-development"
# Optional: $env:GIT_TOKEN = "ghp_your_token_here"  # Fine-grained PAT (Contents:Read, Metadata:Read)
$env:HOST = "127.0.0.1"  # Keep loopback for security
# Optional: $env:HEALTH_CHECK_PORT = "3636"
# Optional: $env:BOOT_DIR = "C:\Deployment"

powershell -ExecutionPolicy Bypass -File scripts/client-bootstrap.ps1
```

#### Linux / macOS (Single Block)

```bash
git clone -b client/dwdfe-development https://YOUR_TOKEN@github.com/viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj-deployment
cd client-9mal0yposmnxa2dzj-deployment

# Required for non-interactive bootstrap
export CLIENT_ID="client-9mal0yposmnxa2dzj"
export GIT_REPO_URL="https://github.com/viriminfo/int_256_Kratinn_database-deployment-system.git"
export GIT_BRANCH="client/dwdfe-development"
# Optional: export GIT_TOKEN="ghp_your_token_here"   # Fine-grained PAT
export HOST="127.0.0.1"   # Keep loopback binding
# Optional: export HEALTH_CHECK_PORT="3636"
# Optional: export BOOT_DIR="/opt/deployment"

chmod +x scripts/client-bootstrap.sh
./scripts/client-bootstrap.sh
```

During bootstrap you will ONLY be prompted for the database password (if not predefined) or port if a conflict occurs. Other items auto-configure.

### Step 3: Verification
After installation completes:
1. Open your web browser
2. Go to: `http://localhost:3636/health`
3. You should see a JSON response with client status

---

## 🔧 Manual Installation (Alternative)

If the automated script fails, follow these manual steps:

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment
Create a `.env` file in the root directory:

```
CLIENT_ID=client-9mal0yposmnxa2dzj
DB_HOST=localhost
DB_PORT=5432
DB_NAME=
DB_USER=deployment_user
DB_PASSWORD=YOUR_DATABASE_PASSWORD
HEALTH_CHECK_PORT=3636
```

### 3. Start the Agent

```bash
npm start
```

---

## 🩺 Error Tracking & Troubleshooting

### Common Installation Errors

**Error: "npm not found" or "node not found"**
- **Windows Solution:**
  1. Download Node.js LTS from: https://nodejs.org/
  2. Run the .msi installer and follow the wizard
  3. Restart Command Prompt/PowerShell
  4. Verify: `node --version` and `npm --version`

- **macOS Solution:**

```bash
# Using Homebrew (recommended)
brew install node
# Or download from nodejs.org
```

- **Linux Solution:**

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# CentOS/RHEL
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
sudo yum install -y nodejs
```

**Error: "git not found"**
- **Windows Solution:**
  1. Download Git from: https://git-scm.com/download/win
  2. Run the installer and select "Git from command line"
  3. Restart Command Prompt/PowerShell
  4. Verify: `git --version`

- **macOS Solution:**

```bash
# Using Homebrew
brew install git
# Or download from git-scm.com
```

- **Linux Solution:**

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install git

# CentOS/RHEL
sudo yum install git
# or: sudo dnf install git
```

**Error: "Permission denied"**
- **Windows:** Run PowerShell as Administrator
- **Linux/macOS:** Use `sudo` with commands

**Error: "Port already in use"**
- **Solution:** Change the port in configuration or stop the conflicting service
- **Check what's using the port:** 
  - Windows: `netstat -ano | findstr :3636`
  - Linux/macOS: `lsof -i :3636`

**Error: "Database connection failed"**
- **Check:** Database credentials are correct
- **Check:** Database server is running and accessible
- **Check:** Network connectivity to database host

**Error: "Authentication failed" or "Invalid username or token"**
- **Cause:** GitHub no longer supports password authentication
- **Solution:** Use Personal Access Token (PAT)
  1. Create token: https://github.com/settings/tokens
  2. Select "repo" scope for full repository access
  3. Use token instead of password:

```bash
# Replace YOUR_TOKEN with actual token
git clone -b client/dwdfe-development https://YOUR_TOKEN@github.com/viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj-deployment
```
  4. Or configure Git to store credentials:

```bash
git config --global credential.helper store
# Then clone normally - will prompt for token once
```

**Error: "fatal: could not read Username" or "fatal: could not read Password"**
- **Solution:** Specify credentials in URL or configure Git:

```bash
# Option 1: Include token in URL
git clone https://YOUR_TOKEN@github.com/viriminfo/int_256_Kratinn_database-deployment-system.git

# Option 2: Set up credential helper
git config --global credential.helper store
git config --global user.name "your-username"
```

### Real-time Error Monitoring

#### View Live Logs:
**Windows:**

```powershell
Get-Content .\logs\agent.log -Tail 50 -Wait
```

**Linux/macOS:**

```bash
tail -f logs/agent.log
```

#### Check System Status:

```bash
npm run health
npm run status
```

#### Debug Mode:

```bash
DEBUG=* npm start
```

---

## 📂 What's Included in This Branch
- ✅ **Deployment Agent** (`client-agent/deployment-agent.js`)
- ✅ **Configuration Files** (`config/`)
- ✅ **Automated Setup Scripts** (`scripts/`)
- ✅ **Migration Directory** (`migrations/`)
- ✅ **Documentation** (`docs/`)
- ✅ **Error Monitoring** (`logs/`)
- ✅ **Health Check Endpoint**

## 🚫 What's NOT Included
- ❌ Centralized server components
- ❌ Management interface  
- ❌ Other clients' configurations
- ❌ Admin tools and utilities

---

## ⚡ Quick Commands Reference

| Command | Purpose |
|---------|---------|
| `npm install` | Install all dependencies |
| `npm start` | Start the deployment agent |
| `npm run health` | Check agent health status |
| `npm run status` | View detailed system status |
| `npm run logs` | View recent log entries |
| `npm run stop` | Stop the agent |
| `npm run restart` | Restart the agent |

---

## 🔐 Client Access Token (Optional / May Be Disabled)

This platform can protect deployment actions using a **Client Access Token** (a secret string like a password). If your administrator supplied a token, follow these steps. If not, you can ignore this section.

### What It Is
- Proves this client is allowed to request deployments
- Shown to you only ONCE when issued or rotated (copy it immediately)
- NOT stored in this branch (only a secure hash exists on the server)

### Your Simple Responsibilities
| Do | Why |
|----|-----|
| Keep the token private | Anyone with it could trigger deployments |
| Store it in **.client-token** (recommended) | Easiest & automatic for the agent |
| Do NOT commit **.client-token** | It is intentionally in .gitignore |
| Contact admin if leaked | They will rotate it safely |

### Store It Securely (Choose ONE)
1. Create a file named **.client-token** in the project root (same folder as this README). Put ONLY the token value (one line, no quotes).
2. Or set it just for your current session:  
   - Linux/macOS: `export CLIENT_TOKEN=your_token_here`  
   - Windows PowerShell: `$env:CLIENT_TOKEN = "your_token_here"`

> The file **.client-token** is ignored by Git so it will NOT be committed. If you ever see it staged, STOP and inform the administrator.

### Automatic Token Rotation (Hands‑Free Security)
Your token may rotate automatically on a schedule (e.g., every 30 days) to reduce risk. When a rotation happens you normally **do nothing**. Behind the scenes: 
1. A tiny trigger file appears: `deployments/security/dwdfe-token-rotation.yml` (contains NO secret).
2. The client agent sees it and securely asks the server for a new token.
3. The agent overwrites **.client-token** with the new token (old one still works briefly).
4. The trigger file is removed. After a short grace period the old token stops working.

If everything is healthy you will not even notice.

### When You Might Need To Act
| Situation | What You See | Your Action |
|-----------|--------------|-------------|
| Agent was stopped during rotation | Trigger file stays present | Start / restart the agent so it refreshes |
| Deployments suddenly fail with 401 | Logs mention invalid token | Open **.client-token** – if empty/corrupt contact admin |
| You accidentally deleted **.client-token** | File missing | Ask admin to issue / show the current token; recreate file |
| You think token leaked | You disclosed it in chat/email | Inform admin immediately; they will rotate it |

### Manual Rotation (If Lost/Leaked)
1. Ask administrator to rotate your token.
2. They give you NEW token (old one enters a short grace period, then expires).
3. Replace the content of **.client-token** (one line).
4. Nothing else required; do NOT commit anything.

### Example: Direct Deployment Request (Advanced)
Most users do not need this – the management UI or agent handles deployments.

```bash
curl -X POST \
  -H 'Content-Type: application/json' \
  -d '{"versions":["v1.2.3"],"clientToken":"<YOUR_CLIENT_TOKEN>"}' \
  http://<SERVER_HOST>:3000/api/deployments/client-9mal0yposmnxa2dzj
```

### Example: Batch Body Snippet

```json
{
  "deployments": [
    { "clientId": "client-9mal0yposmnxa2dzj", "versions": ["v1.2.3", "v1.2.4"] }
  ],
  "tokens": {
    "client-9mal0yposmnxa2dzj": "<YOUR_CLIENT_TOKEN>"
  }
}
```

### Quick Troubleshooting
| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| 401 Unauthorized | Wrong/missing token | Re-copy token exactly (no spaces) |
| Deployment skipped in batch | Token missing in tokens map | Add entry under `tokens` |
| Trigger file never disappears | Agent not running | Start/restart agent process |
| Old token still works | Grace period active | Wait – it will expire automatically |
| **.client-token** has multiple lines | Accidental paste with newline | Keep ONLY the token, no extra spaces |

### Current Mode
Token enforcement is currently DISABLED – deployments may work without a token, but keep yours for future use.

> Never email or publicly paste the token. Treat it exactly like a password.

## 🆘 Getting Help

### For Technical Issues:
1. **Check logs:** `npm run logs`
2. **Check status:** `npm run status` 
3. **Check health:** Visit `http://localhost:3636/health`

### For Support:
📧 **Email:** solankimadhur65@gmail.com
📋 **Include:** 
- Error message (exact text)
- Last 50 lines of logs
- Your operating system
- Client ID: client-9mal0yposmnxa2dzj

### Get Last 50 Log Lines:
**Windows:**

```powershell
Get-Content .\logs\agent.log -Tail 50 | Out-File error-report.txt
```

**Linux/macOS:**

```bash
tail -n 50 logs/agent.log > error-report.txt
```

---

## 🛠️ Advanced Configuration

### 🔑 Database Password Configuration
The database password is NEVER stored in the repository. You must set it locally after cloning.

#### Option 1: Add to `.env` (recommended for persistent restarts)

```
DB_PASSWORD=your_real_password_here
```
`.env` is listed in `.gitignore` so it will NOT be committed.

#### Option 2: Export at runtime (one session only)
Linux / macOS:

```bash
export DB_PASSWORD="your_real_password_here"
npm start
```

Windows PowerShell:

```powershell
$env:DB_PASSWORD = "your_real_password_here"
npm start
```

#### Option 3: Provide when prompted
If you use the bootstrap script and it detects no DB_PASSWORD, it will prompt you securely.

#### Security Tips
1. NEVER commit `.env` or share the password via email/chat in plain text.
2. Rotate passwords periodically (e.g., every 90 days) and update the local `.env`.
3. Prefer database users with least privilege (only migration-required permissions).
4. If password changes, just update `.env` and restart the agent.

#### Verification
After starting the agent, confirm connectivity via the health endpoint. If DB auth fails you will see errors in `logs/agent.log`.

### Environment Variables
All configuration can be set via environment variables:
- `CLIENT_ID` - Your unique client identifier
- `DB_HOST` - Database server hostname  
- `DB_PORT` - Database server port
- `DB_NAME` - Database name
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password
- `HEALTH_CHECK_PORT` - Port for health checks
- `LOG_LEVEL` - Logging level (debug, info, warn, error)

### Service Installation
To run as a system service:

**Windows (as Service):**

```powershell
npm install -g node-windows
npm run install-service
```

**Linux (systemd):**

```bash
sudo npm run install-service
```

---

**📅 Branch Created:** 2026-04-13T14:18:15.922Z
**🔧 Agent Version:** 1.0.0
**🌟 Ready for Production**

> This deployment agent is fully isolated and contains everything needed for your development environment.