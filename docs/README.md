# Database Deployment Agent - dwdfe

## Overview
This is an isolated deployment branch for **dwdfe** containing only the necessary files for database deployment operations.

**⚠️ IMPORTANT: This branch is isolated and contains only client-specific files. It does not include the centralized management components.**

## Client Information
- **Client ID:** `client-9mal0yposmnxa2dzj`
- **Environment:** `development`
- **Git Branch:** `client/dwdfe-development`
- **Database:** postgresql on localhost:5432
- **Contact:** solankimadhur65@gmail.com

## Quick Start

### Step 1: Clone & Enter Directory
```bash
git clone -b client/dwdfe-development https://github.com/viriminfo/int_256_Kratinn_database-deployment-system.git client-9mal0yposmnxa2dzj
cd client-9mal0yposmnxa2dzj
```

### Step 2: Setup, Configure & Run (All-in-One)

#### Windows (PowerShell)
```powershell
# (Run PowerShell normally; use Administrator only if target path requires it)
$env:CLIENT_ID = "client-9mal0yposmnxa2dzj"
$env:GIT_REPO_URL = "https://github.com/viriminfo/int_256_Kratinn_database-deployment-system.git"
$env:GIT_BRANCH = "client/dwdfe-development"
# Optional: $env:GIT_TOKEN = "ghp_your_token_here"   # Fine-grained PAT (Contents:Read, Metadata:Read)
$env:HOST = "127.0.0.1"  # Keep loopback binding for security
# Optional: $env:HEALTH_CHECK_PORT = "3636"

powershell -ExecutionPolicy Bypass -File scripts/client-bootstrap.ps1
```

#### Linux / macOS
```bash
export CLIENT_ID="client-9mal0yposmnxa2dzj"
export GIT_REPO_URL="https://github.com/viriminfo/int_256_Kratinn_database-deployment-system.git"
export GIT_BRANCH="client/dwdfe-development"
# Optional: export GIT_TOKEN="ghp_your_token_here"   # Fine-grained PAT
export HOST="127.0.0.1"
# Optional: export HEALTH_CHECK_PORT="3636"

chmod +x scripts/client-bootstrap.sh
./scripts/client-bootstrap.sh
```

During bootstrap you will ONLY be prompted for the database password (if not already set) or a different port if a conflict is detected. Everything else auto-configures.

### Step 3: Verify
Open a browser and visit: `http://localhost:3636/health` – you should see JSON status output.

> ✅ Run as a normal (non-root) deployment user when possible. Use sudo/Administrator only for directory permission issues.

## Available Commands
```bash
npm start          # Start the deployment agent
npm run dev        # Start in development mode with auto-restart
npm run health     # Check agent health
npm run status     # Get detailed status
npm run logs       # View recent logs
./scripts/stop-agent.sh <PORT?>   # (Linux/macOS) Stop agent & free port
powershell -ExecutionPolicy Bypass -File scripts/stop-agent.ps1 -Port <PORT?> # (Windows) Stop agent
```

## Endpoints
Once running, the following endpoints are available:

- **Health Check:** http://localhost:3636/health
- **Detailed Status:** http://localhost:3636/status
- **Root Info:** http://localhost:3636/

## Configuration Files

### Environment Variables (`.env`)
Contains all environment-specific configuration including database credentials and agent settings.

### Database Configuration (`config/database-config.json`)
Database connection settings and pool configuration.

### Deployment Configuration (`config/deployment-config.json`)
Deployment policies, notification settings, and monitoring configuration.

## Directory Structure
```
client-9mal0yposmnxa2dzj/
├── client-agent/           # Main agent code
│   └── deployment-agent.js # Primary agent application
├── config/                 # Configuration files
│   ├── database-config.json
│   └── deployment-config.json
├── docs/                   # Documentation
├── logs/                   # Log files (created automatically)
├── migrations/             # SQL migration files (add your migrations here)
├── scripts/                # Utility scripts
├── .env                    # Environment variables
├── package.json            # Node.js project configuration
├── install.sh              # Linux installation script
├── install.ps1             # Windows installation script
└── README.md               # This file
```

---

## 🛑 Stopping & Cleanup (Releasing Ports)

Deleting the folder alone does NOT free the port. Always stop the process first:

### Quick Stop (Recommended)
**Linux/macOS:**
```bash
./scripts/stop-agent.sh <PORT>
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/stop-agent.ps1 -Port <PORT>
```

If you don't remember the port, run health/status first or look inside `.env` (`HEALTH_CHECK_PORT`).

### Manual Method
**Linux/macOS:**
```bash
lsof -i :<PORT>
kill <PID>
# if still alive after a few seconds
kill -9 <PID>
```

**Windows:**
```powershell
netstat -ano | findstr :<PORT>
Stop-Process -Id <PID> -Force
```

### After Stopping
1. Confirm port free:
    - Linux/macOS: `lsof -i :<PORT>` (no output = free)
    - Windows: `netstat -ano | findstr :<PORT>` (no line = free)
2. (Optional) Remove directory safely
3. Recreate new client branch or redeploy

> Note: Seeing TIME_WAIT is normal; it clears shortly. Only a LISTEN entry means something is still bound.

## Migration Management
1. Place your SQL migration files in the `migrations/` directory
2. Use the naming convention: `YYYY-MM-DD-HH-MM-SS-description.sql`
3. Example: `2025-08-13-14-30-00-add-user-table.sql`

## Monitoring & Health Checks
The agent provides comprehensive monitoring:

- **Health endpoint** for basic status checks
- **Status endpoint** for detailed system information  
- **Automatic logging** to `logs/agent.log`
- **Process monitoring** with graceful shutdown

## Security Features
- Isolated branch with no access to other clients
- Environment-based configuration
- Secure database connections
- Audit logging (if enabled)

## Support & Troubleshooting

### Common Issues
1. **Port already in use:** Change `HEALTH_CHECK_PORT` in `.env`
2. **Database connection failed:** Verify settings in `config/database-config.json`
3. **Agent won't start:** Check `logs/agent.log` for error details

### Getting Help
- **Contact:** solankimadhur65@gmail.com
- **Environment:** development
- **Client ID:** client-9mal0yposmnxa2dzj

### Log Files
- **Agent logs:** `logs/agent.log`
- **Console output:** Use `npm run logs` to tail the log file

---

**Generated for dwdfe on 2026-04-13T14:18:15.919Z**
