import 'dotenv/config';
import { Client, Databases, ID } from 'node-appwrite';

class InternManagement {
    constructor() {
        this.client = new Client();
        this.databases = new Databases(this.client);
        
        // Initialize Appwrite client
        this.client
            .setEndpoint(process.env.APPWRITE_ENDPOINT)
            .setProject(process.env.APPWRITE_PROJECT_ID)
            .setKey(process.env.APPWRITE_API_KEY);
        
        this.databaseId = process.env.DATABASE_ID;
        this.collectionId = process.env.COLLECTION_ID;
        
        // Valid task statuses
        this.validTaskStatuses = ['open', 'completed', 'todo', 'working', 'deferred', 'pending'];
    }

    // Validate task data
    validateTask(task) {
        if (!task.title) throw new Error('Task title is required');
        if (!task.status) throw new Error('Task status is required');
        if (!this.validTaskStatuses.includes(task.status)) {
            throw new Error(`Invalid task status. Must be one of: ${this.validTaskStatuses.join(', ')}`);
        }
        return true;
    }

    // GET /interns - Get all interns
    async getAllInterns(queries = []) {
        try {
            const response = await this.databases.listDocuments(
                this.databaseId,
                this.collectionId,
                queries
            );
            return {
                success: true,
                data: response.documents,
                total: response.total
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // GET /interns/:id - Get specific intern
    async getIntern(internId) {
        try {
            const response = await this.databases.getDocument(
                this.databaseId,
                this.collectionId,
                internId
            );
            return {
                success: true,
                data: response
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // POST /interns - Create new intern
    async createIntern(internData, customId = null) {
        try {
            const documentId = customId || ID.unique();
            
            // Validate and prepare tasks
            let tasks = [];
            if (internData.tasksAssigned && Array.isArray(internData.tasksAssigned)) {
                tasks = internData.tasksAssigned.map(task => {
                    this.validateTask(task);
                    return {
                        id: task.id || ID.unique(),
                        title: task.title,
                        description: task.description || '',
                        status: task.status,
                        assignedAt: task.assignedAt || new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    };
                });
            }
            
            const data = {
                internName: internData.internName,
                batch: internData.batch,
                roles: internData.roles || [],
                currentProjects: internData.currentProjects || [],
                tasksAssigned: tasks  // Store as array, not JSON string
            };

            const response = await this.databases.createDocument(
                this.databaseId,
                this.collectionId,
                documentId,
                data
            );
            
            return {
                success: true,
                data: response,
                message: 'Intern created successfully'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // PATCH /interns/:id - Update intern
    async updateIntern(internId, updateData) {
        try {
            const data = {};
            
            if (updateData.internName) data.internName = updateData.internName;
            if (updateData.batch) data.batch = updateData.batch;
            if (updateData.roles) data.roles = updateData.roles;
            if (updateData.currentProjects) data.currentProjects = updateData.currentProjects;
            
            // Handle tasks update
            if (updateData.tasksAssigned && Array.isArray(updateData.tasksAssigned)) {
                const tasks = updateData.tasksAssigned.map(task => {
                    this.validateTask(task);
                    return {
                        id: task.id || ID.unique(),
                        title: task.title,
                        description: task.description || '',
                        status: task.status,
                        assignedAt: task.assignedAt || new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    };
                });
                data.tasksAssigned = tasks;  // Store as array, not JSON string
            }

            const response = await this.databases.updateDocument(
                this.databaseId,
                this.collectionId,
                internId,
                data
            );
            
            return {
                success: true,
                data: response,
                message: 'Intern updated successfully'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // DELETE /interns/:id - Delete intern
    async deleteIntern(internId) {
        try {
            await this.databases.deleteDocument(
                this.databaseId,
                this.collectionId,
                internId
            );
            
            return {
                success: true,
                message: 'Intern deleted successfully'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // Get intern count
    async getInternCount() {
        try {
            const response = await this.databases.listDocuments(
                this.databaseId,
                this.collectionId,
                ['limit(1)']
            );
            return {
                success: true,
                count: response.total
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // Get task summary across all interns
    async getTaskSummary() {
        try {
            const response = await this.databases.listDocuments(
                this.databaseId,
                this.collectionId
            );
            
            const summary = {
                open: 0,
                completed: 0,
                todo: 0,
                working: 0,
                deferred: 0,
                pending: 0,
                total: 0
            };
            
            response.documents.forEach(intern => {
                try {
                    // Handle both array and JSON string formats for backward compatibility
                    let tasks = intern.tasksAssigned || [];
                    if (typeof tasks === 'string') {
                        tasks = JSON.parse(tasks);
                    }
                    
                    if (Array.isArray(tasks)) {
                        tasks.forEach(task => {
                            if (summary.hasOwnProperty(task.status)) {
                                summary[task.status]++;
                                summary.total++;
                            }
                        });
                    }
                } catch (e) {
                    // Skip invalid task data
                }
            });
            
            return {
                success: true,
                summary
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }
}

// Simple Appwrite Function Handler - Compatible with multiple versions
export default async (context) => {
    try {
        // Extract request and response objects from context
        const { req, res, log, error } = context;
        
        const internSystem = new InternManagement();
        
        // Parse request
        const method = req.method;
        const path = req.path || req.url || '';
        const pathParts = path.split('/').filter(part => part);
        
        if (log) log(`${method} ${path}`);
        
        // Parse body
        let body = {};
        try {
            if (req.bodyRaw) {
                body = JSON.parse(req.bodyRaw);
            } else if (req.body) {
                body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
            }
        } catch (e) {
            body = {};
        }
        
        let result;
        
        // Route handling
        if (pathParts[0] === 'interns' || pathParts.length === 0) {
            
            // GET /interns - Get all interns
            if (method === 'GET' && pathParts.length <= 1) {
                const queries = [];
                
                // Handle query parameters
                if (req.query) {
                    if (req.query.batch) {
                        queries.push(`equal("batch", "${req.query.batch}")`);
                    }
                    if (req.query.search) {
                        queries.push(`search("internName", "${req.query.search}")`);
                    }
                    if (req.query.limit) {
                        queries.push(`limit(${parseInt(req.query.limit)})`);
                    }
                    if (req.query.offset) {
                        queries.push(`offset(${parseInt(req.query.offset)})`);
                    }
                    if (req.query.sort && req.query.order) {
                        const order = req.query.order === 'desc' ? 'orderDesc' : 'orderAsc';
                        queries.push(`${order}("${req.query.sort}")`);
                    }
                }
                
                result = await internSystem.getAllInterns(queries);
            }
            
            // GET /interns/:id - Get specific intern
            else if (method === 'GET' && pathParts.length === 2) {
                const internId = pathParts[1];
                result = await internSystem.getIntern(internId);
            }
            
            // POST /interns - Create new intern
            else if (method === 'POST' && pathParts.length <= 1) {
                result = await internSystem.createIntern(body);
            }
            
            // PATCH /interns/:id - Update intern
            else if (method === 'PATCH' && pathParts.length === 2) {
                const internId = pathParts[1];
                result = await internSystem.updateIntern(internId, body);
            }
            
            // DELETE /interns/:id - Delete intern
            else if (method === 'DELETE' && pathParts.length === 2) {
                const internId = pathParts[1];
                result = await internSystem.deleteIntern(internId);
            }
            
            // GET /interns/count - Get count
            else if (method === 'GET' && pathParts[1] === 'count') {
                result = await internSystem.getInternCount();
            }
            
            // GET /interns/tasks/summary - Get task summary
            else if (method === 'GET' && pathParts[1] === 'tasks' && pathParts[2] === 'summary') {
                result = await internSystem.getTaskSummary();
            }
            
            else {
                result = { success: false, error: 'Method not allowed' };
            }
        } else {
            result = { success: false, error: 'Route not found', method, path };
        }
        
        // Return response
        return res.send(JSON.stringify(result), 200, {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        });
        
    } catch (err) {
        const { error, res } = context;
        if (error) error('Function error:', err);
        
        return res.send(JSON.stringify({
            success: false,
            error: err.message
        }), 500, {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        });
    }
};

// Also export the class for testing
export { InternManagement };
