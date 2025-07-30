// Simple Node.js version for local testing
import { InternManagement } from './index.js';
import http from 'http';
import url from 'url';

const PORT = process.env.PORT || 3000;

const server = http.createServer(async (req, res) => {
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    // Handle preflight OPTIONS request
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    try {
        const internSystem = new InternManagement();
        const parsedUrl = url.parse(req.url, true);
        const path = parsedUrl.pathname;
        const query = parsedUrl.query;
        const method = req.method;
        
        console.log(`${method} ${path}`);
        
        // Parse body for POST/PATCH requests
        let body = {};
        if (method === 'POST' || method === 'PATCH') {
            const chunks = [];
            for await (const chunk of req) {
                chunks.push(chunk);
            }
            const bodyString = Buffer.concat(chunks).toString();
            try {
                body = JSON.parse(bodyString);
            } catch (e) {
                body = {};
            }
        }
        
        let result;
        let statusCode = 200;
        
        // Route handling
        if (path === '/interns' || path === '/') {
            if (method === 'GET') {
                const queries = [];
                if (query.batch) queries.push(`equal("batch", "${query.batch}")`);
                if (query.search) queries.push(`search("internName", "${query.search}")`);
                if (query.limit) queries.push(`limit(${parseInt(query.limit)})`);
                if (query.offset) queries.push(`offset(${parseInt(query.offset)})`);
                if (query.sort && query.order) {
                    const order = query.order === 'desc' ? 'orderDesc' : 'orderAsc';
                    queries.push(`${order}("${query.sort}")`);
                }
                result = await internSystem.getAllInterns(queries);
            } else if (method === 'POST') {
                result = await internSystem.createIntern(body);
                statusCode = 201; // Created
            } else {
                result = { success: false, error: 'Method not allowed' };
                statusCode = 405;
            }
        } else if (path.startsWith('/interns/')) {
            const pathParts = path.split('/').filter(p => p);
            const internId = pathParts[1];
            
            if (method === 'GET') {
                if (internId === 'count') {
                    result = await internSystem.getInternCount();
                } else if (pathParts[2] === 'tasks' && pathParts[3] === 'summary') {
                    result = await internSystem.getTaskSummary();
                } else {
                    result = await internSystem.getIntern(internId);
                }
            } else if (method === 'PATCH') {
                result = await internSystem.updateIntern(internId, body);
            } else if (method === 'DELETE') {
                result = await internSystem.deleteIntern(internId);
                statusCode = 204; // No Content
            } else {
                result = { success: false, error: 'Method not allowed' };
                statusCode = 405;
            }
        } else {
            result = { success: false, error: 'Route not found' };
            statusCode = 404;
        }
        
        // Set response status based on result
        if (result && !result.success && statusCode === 200) {
            statusCode = 400; // Bad Request
        }
        
        res.writeHead(statusCode, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result || { success: false, error: 'No response' }));
        
    } catch (error) {
        console.error('Server error:', error);
        if (!res.headersSent) {
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                success: false,
                error: error.message
            }));
        }
    }
});

server.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log('📋 Available endpoints:');
    console.log('  GET    /interns - Get all interns');
    console.log('  POST   /interns - Create intern');
    console.log('  GET    /interns/:id - Get specific intern');
    console.log('  PATCH  /interns/:id - Update intern');
    console.log('  DELETE /interns/:id - Delete intern');
    console.log('  GET    /interns/count - Get intern count');
    console.log('  GET    /interns/tasks/summary - Get task summary');
});
