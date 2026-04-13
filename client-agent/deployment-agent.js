// Database Deployment Agent for dwdfe
// Client ID: client-9mal0yposmnxa2dzj
// Environment: development
// THIS IS AN ISOLATED CLIENT BRANCH - Contains only client-specific files

const express = require('express');
const fs = require('fs');
const path = require('path');

// Load configuration
const config = require('../config/deployment-config.json');
const dbConfig = require('../config/database-config.json');

const app = express();
app.use(express.json());

const PORT = process.env.HEALTH_CHECK_PORT || 3636;

// Agent status
const agentStatus = {
    clientId: 'client-9mal0yposmnxa2dzj',
    clientName: 'dwdfe',
    environment: 'development',
    gitBranch: 'client/dwdfe-development',
    status: 'running',
    startTime: new Date().toISOString(),
    lastSync: null,
    lastDeployment: null,
    version: '1.0.0'
};

// Logging function
function log(level, message) {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] ${level.toUpperCase()}: ${message}`;
    console.log(logEntry);
    
    // Ensure logs directory exists
    const logsDir = path.join(__dirname, '../logs');
    if (!fs.existsSync(logsDir)) {
        fs.mkdirSync(logsDir, { recursive: true });
    }
    
    // Write to log file
    const logFile = path.join(logsDir, 'agent.log');
    fs.appendFileSync(logFile, logEntry + '\n');
}

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        ...agentStatus,
        timestamp: new Date().toISOString(),
        uptime: Math.floor(process.uptime()),
        database: {
            type: dbConfig.type,
            host: dbConfig.connection.host,
            database: dbConfig.connection.database,
            port: dbConfig.connection.port
        },
        config: {
            pollingInterval: config.pollingInterval,
            environment: config.environment
        }
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        ...agentStatus,
        config: config,
        database: dbConfig,
        migrations: getMigrationStatus(),
        system: {
            nodeVersion: process.version,
            platform: process.platform,
            architecture: process.arch,
            memory: process.memoryUsage()
        }
    });
});

// Get migration status
function getMigrationStatus() {
    try {
        const migrationsDir = path.join(__dirname, '../migrations');
        if (fs.existsSync(migrationsDir)) {
            const files = fs.readdirSync(migrationsDir)
                .filter(file => file.endsWith('.sql'))
                .sort();
            return {
                available: files.length,
                files: files,
                last_checked: new Date().toISOString()
            };
        }
        return { available: 0, files: [], last_checked: new Date().toISOString() };
    } catch (error) {
        return { error: error.message };
    }
}

// Root endpoint with client information
app.get('/', (req, res) => {
    res.json({
        message: 'Database Deployment Agent',
        client: agentStatus.clientName,
        environment: agentStatus.environment,
        clientId: agentStatus.clientId,
        branch: agentStatus.gitBranch,
        endpoints: {
            health: '/health',
            status: '/status'
        }
    });
});

// Start the agent
app.listen(PORT, () => {
    log('info', `=== Database Deployment Agent Started ===`);
    log('info', `Client: ${agentStatus.clientName}`);
    log('info', `Environment: ${agentStatus.environment}`);
    log('info', `Client ID: ${agentStatus.clientId}`);
    log('info', `Git Branch: ${agentStatus.gitBranch}`);
    log('info', `Port: ${PORT}`);
    log('info', `Health Check: http://localhost:${PORT}/health`);
    log('info', `Status: http://localhost:${PORT}/status`);
    log('info', `==========================================`);
    
    agentStatus.status = 'active';
});

// Graceful shutdown
process.on('SIGINT', () => {
    log('info', 'Agent shutting down gracefully...');
    agentStatus.status = 'shutting_down';
    process.exit(0);
});

process.on('SIGTERM', () => {
    log('info', 'Agent received SIGTERM, shutting down...');
    agentStatus.status = 'shutting_down';
    process.exit(0);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    log('error', `Uncaught exception: ${error.message}`);
    log('error', error.stack);
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    log('error', `Unhandled promise rejection: ${reason}`);
    process.exit(1);
});
