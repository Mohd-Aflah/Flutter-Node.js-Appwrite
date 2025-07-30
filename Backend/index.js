/**
 * @fileoverview Intern Management System API
 * @description A comprehensive REST API for managing interns and their assigned tasks
 * @author Your Name
 * @version 2.1.0
 */

import 'dotenv/config';
import { Client, Databases, ID } from 'node-appwrite';

/**
 * @class InternManagement
 * @description Main class for handling intern management operations
 */
class InternManagement {
    /**
     * @constructor
     * @description Initializes the Appwrite client and database connections
     */
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

    /**
     * @method validateTask
     * @description Validates task data structure and required fields
     * @param {Object} task - The task object to validate
     * @param {string} task.title - Required task title
     * @param {string} task.status - Required task status
     * @param {string} [task.description] - Optional task description
     * @param {string} [task.id] - Optional task ID
     * @returns {boolean} Returns true if valid
     * @throws {Error} Throws error if validation fails
     */
    validateTask(task) {
        if (!task.title) throw new Error('Task title is required');
        if (!task.status) throw new Error('Task status is required');
        if (!this.validTaskStatuses.includes(task.status)) {
            throw new Error(`Invalid task status. Must be one of: ${this.validTaskStatuses.join(', ')}`);
        }
        return true;
    }

    /**
     * @method getAllInterns
     * @description Retrieves all interns from the database with optional filtering
     * @param {string[]} [queries=[]] - Array of Appwrite query strings for filtering
     * @returns {Promise<Object>} Promise resolving to response object
     * @returns {boolean} returns.success - Indicates if operation was successful
     * @returns {Object[]} returns.data - Array of intern objects with parsed tasks
     * @returns {number} returns.total - Total number of matching documents
     * @example
     * // Get all interns
     * const result = await getAllInterns();
     * 
     * // Get interns with filtering
     * const filtered = await getAllInterns(['equal("batch", "2025-Summer")', 'limit(10)']);
     */
    async getAllInterns(queries = []) {
        try {
            const response = await this.databases.listDocuments(
                this.databaseId,
                this.collectionId,
                queries
            );
            
            // Parse tasks for client response
            const documents = response.documents.map(intern => {
                const internData = { ...intern };
                if (internData.tasksAssigned && Array.isArray(internData.tasksAssigned)) {
                    internData.tasksAssigned = internData.tasksAssigned.map(taskStr => {
                        try {
                            return JSON.parse(taskStr);
                        } catch (e) {
                            return taskStr; // Return as-is if not parseable
                        }
                    });
                }
                return internData;
            });
            
            return {
                success: true,
                data: documents,
                total: response.total
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * @method getIntern
     * @description Retrieves a specific intern by their document ID
     * @param {string} internId - The unique document ID of the intern
     * @returns {Promise<Object>} Promise resolving to response object
     * @returns {boolean} returns.success - Indicates if operation was successful
     * @returns {Object} returns.data - Intern object with parsed tasks
     * @example
     * const result = await getIntern('custom-intern-001');
     */
    async getIntern(internId) {
        try {
            const response = await this.databases.getDocument(
                this.databaseId,
                this.collectionId,
                internId
            );
            
            // Parse tasks for client response
            const internData = { ...response };
            if (internData.tasksAssigned && Array.isArray(internData.tasksAssigned)) {
                internData.tasksAssigned = internData.tasksAssigned.map(taskStr => {
                    try {
                        return JSON.parse(taskStr);
                    } catch (e) {
                        return taskStr; // Return as-is if not parseable
                    }
                });
            }
            
            return {
                success: true,
                data: internData
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * @method createIntern
     * @description Creates a new intern document in the database
     * @param {Object} internData - The intern data object
     * @param {string} [internData.documentId] - Optional custom document ID
     * @param {string} internData.internName - Required name of the intern
     * @param {string} internData.batch - Required batch identifier
     * @param {string[]} [internData.roles] - Optional array of roles
     * @param {string[]} [internData.currentProjects] - Optional array of current projects
     * @param {Object[]} [internData.tasksAssigned] - Optional array of tasks
     * @param {string} [customId=null] - Alternative way to provide custom document ID
     * @returns {Promise<Object>} Promise resolving to response object
     * @returns {boolean} returns.success - Indicates if operation was successful
     * @returns {Object} returns.data - Created intern document
     * @returns {string} returns.message - Success message
     * @example
     * const newIntern = {
     *   documentId: 'custom-id-001',
     *   internName: 'John Doe',
     *   batch: '2025-Summer',
     *   roles: ['Frontend Developer'],
     *   tasksAssigned: [{
     *     title: 'Setup Environment',
     *     status: 'open'
     *   }]
     * };
     * const result = await createIntern(newIntern);
     */
    async createIntern(internData, customId = null) {
        try {
            // Use custom ID from request body if provided, otherwise generate one
            const documentId = internData.documentId || customId || ID.unique();
            
            // Validate and prepare tasks
            let tasks = [];
            if (internData.tasksAssigned && Array.isArray(internData.tasksAssigned)) {
                tasks = internData.tasksAssigned.map(task => {
                    this.validateTask(task);
                    const taskObj = {
                        id: task.id || ID.unique(),
                        title: task.title,
                        description: task.description || '',
                        status: task.status,
                        assignedAt: task.assignedAt || new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    };
                    // Convert each task object to JSON string for array storage
                    return JSON.stringify(taskObj);
                });
            }
            
            const data = {
                internName: internData.internName,
                batch: internData.batch,
                roles: internData.roles || [],
                currentProjects: internData.currentProjects || [],
                tasksAssigned: tasks  // Array of JSON strings
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

    /**
     * @method updateIntern
     * @description Updates an existing intern's information and tasks
     * @param {string} internId - The document ID of the intern to update
     * @param {Object} updateData - Object containing fields to update
     * @param {string} [updateData.internName] - New intern name
     * @param {string} [updateData.batch] - New batch identifier
     * @param {string[]} [updateData.roles] - New array of roles
     * @param {string[]} [updateData.currentProjects] - New array of projects
     * @param {Object[]} [updateData.tasksAssigned] - New array of tasks
     * @returns {Promise<Object>} Promise resolving to response object
     * @returns {boolean} returns.success - Indicates if operation was successful
     * @returns {Object} returns.data - Updated intern document
     * @returns {string} returns.message - Success message
     * @example
     * const updates = {
     *   roles: ['Senior Developer'],
     *   tasksAssigned: [{
     *     id: 'task-1',
     *     title: 'Updated Task',
     *     status: 'completed'
     *   }]
     * };
     * const result = await updateIntern('intern-id', updates);
     */
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
                    const taskObj = {
                        id: task.id || ID.unique(),
                        title: task.title,
                        description: task.description || '',
                        status: task.status,
                        assignedAt: task.assignedAt || new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    };
                    // Convert each task object to JSON string for array storage
                    return JSON.stringify(taskObj);
                });
                data.tasksAssigned = tasks;  // Array of JSON strings
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
                    // Handle different formats for backward compatibility
                    let tasks = intern.tasksAssigned || [];
                    
                    // If it's a string (old format), parse it
                    if (typeof tasks === 'string') {
                        tasks = JSON.parse(tasks);
                    }
                    
                    // If it's an array, process each element
                    if (Array.isArray(tasks)) {
                        tasks.forEach(taskItem => {
                            try {
                                // If array element is a string, parse it
                                let task = taskItem;
                                if (typeof taskItem === 'string') {
                                    task = JSON.parse(taskItem);
                                }
                                
                                if (task && task.status && summary.hasOwnProperty(task.status)) {
                                    summary[task.status]++;
                                    summary.total++;
                                }
                            } catch (taskError) {
                                // Skip invalid task items
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
                // Extract document ID from request body if provided
                const customId = body.documentId || null;
                result = await internSystem.createIntern(body, customId);
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
