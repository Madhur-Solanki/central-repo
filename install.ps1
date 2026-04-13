# Database Deployment Agent Installer (Windows)
# Client: dwdfe
# Client ID: client-9mal0yposmnxa2dzj
# Environment: development

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Database Deployment Agent Installer" -ForegroundColor Cyan
Write-Host "Client: dwdfe" -ForegroundColor Green
Write-Host "Client ID: client-9mal0yposmnxa2dzj" -ForegroundColor Green
Write-Host "Environment: development" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

# Check prerequisites
try {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
    Write-Host "✅ npm version: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Node.js and npm are required but not installed" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
try {
    npm install
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

# Create logs directory
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
    Write-Host "✅ Created logs directory" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Installation completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Quick Start:" -ForegroundColor Cyan
Write-Host "  Start agent: npm start" -ForegroundColor White
Write-Host "  Development: npm run dev" -ForegroundColor White
Write-Host "  Health check: npm run health" -ForegroundColor White
Write-Host "  View logs: npm run logs" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Once started, access:" -ForegroundColor Cyan
Write-Host "  Health: http://localhost:3636/health" -ForegroundColor White
Write-Host "  Status: http://localhost:3636/status" -ForegroundColor White
Write-Host ""
Write-Host "📧 Support: solankimadhur65@gmail.com" -ForegroundColor Yellow
