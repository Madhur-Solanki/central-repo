#!/bin/bash
# Database Deployment Agent Installer
# Client: dwdfe
# Client ID: client-9mal0yposmnxa2dzj
# Environment: development

set -e

echo "=================================================="
echo "Database Deployment Agent Installer"
echo "Client: dwdfe"
echo "Client ID: client-9mal0yposmnxa2dzj"
echo "Environment: development"
echo "=================================================="

# Check prerequisites
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is required but not installed"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is required but not installed"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create logs directory
mkdir -p logs

# Set permissions
chmod +x scripts/*.sh 2>/dev/null || true

echo "✅ Installation completed successfully!"
echo ""
echo "🚀 Quick Start:"
echo "  Start agent: npm start"
echo "  Development: npm run dev" 
echo "  Health check: npm run health"
echo "  View logs: npm run logs"
echo ""
echo "🌐 Once started, access:"
echo "  Health: http://localhost:3636/health"
echo "  Status: http://localhost:3636/status"
echo ""
echo "📧 Support: solankimadhur65@gmail.com"
