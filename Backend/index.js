require('dotenv').config();
const { Client, Databases, ID } = require('node-appwrite');

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
            if (internData.tasks && Array.isArray(internData.tasks)) {
                tasks = internData.tasks.map(task => {
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
                tasksAssigned: JSON.stringify(tasks)
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
            if (updateData.tasks && Array.isArray(updateData.tasks)) {
                const tasks = updateData.tasks.map(task => {
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
                data.tasksAssigned = JSON.stringify(tasks);
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

    // Add task to intern
    async addTaskToIntern(internId, taskData) {
        try {
            // Get current intern
            const internResult = await this.getIntern(internId);
            if (!internResult.success) {
                return internResult;
            }

            // Validate new task
            this.validateTask(taskData);

            // Parse existing tasks
            let tasks = [];
            if (internResult.data.tasksAssigned) {
                try {
                    tasks = JSON.parse(internResult.data.tasksAssigned);
                } catch (e) {
                    tasks = [];
                }
            }

            // Add new task
            const newTask = {
                id: taskData.id || ID.unique(),
                title: taskData.title,
                description: taskData.description || '',
                status: taskData.status,
                assignedAt: taskData.assignedAt || new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            tasks.push(newTask);

            // Update intern with new tasks
            return await this.updateIntern(internId, { tasks });
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // Update task status
    async updateTaskStatus(internId, taskId, newStatus) {
        try {
            if (!this.validTaskStatuses.includes(newStatus)) {
                throw new Error(`Invalid task status. Must be one of: ${this.validTaskStatuses.join(', ')}`);
            }

            // Get current intern
            const internResult = await this.getIntern(internId);
            if (!internResult.success) {
                return internResult;
            }

            // Parse existing tasks
            let tasks = [];
            if (internResult.data.tasksAssigned) {
                try {
                    tasks = JSON.parse(internResult.data.tasksAssigned);
                } catch (e) {
                    return { success: false, error: 'Invalid tasks data' };
                }
            }

            // Find and update task
            const taskIndex = tasks.findIndex(task => task.id === taskId);
            if (taskIndex === -1) {
                return { success: false, error: 'Task not found' };
            }

            tasks[taskIndex].status = newStatus;
            tasks[taskIndex].updatedAt = new Date().toISOString();

            // Update intern with modified tasks
            return await this.updateIntern(internId, { tasks });
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // Get interns by task status
    async getInternsByTaskStatus(status) {
        try {
            if (!this.validTaskStatuses.includes(status)) {
                throw new Error(`Invalid task status. Must be one of: ${this.validTaskStatuses.join(', ')}`);
            }

            // Get all interns
            const allInterns = await this.getAllInterns();
            if (!allInterns.success) {
                return allInterns;
            }

            // Filter interns that have tasks with the specified status
            const filteredInterns = allInterns.data.filter(intern => {
                if (!intern.tasksAssigned) return false;
                
                try {
                    const tasks = JSON.parse(intern.tasksAssigned);
                    return tasks.some(task => task.status === status);
                } catch (e) {
                    return false;
                }
            });

            return {
                success: true,
                data: filteredInterns,
                total: filteredInterns.length
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    // Get task summary for all interns
    async getTaskSummary() {
        try {
            const allInterns = await this.getAllInterns();
            if (!allInterns.success) {
                return allInterns;
            }

            const summary = {
                totalInterns: allInterns.total,
                taskStatusCounts: {}
            };

            // Initialize status counts
            this.validTaskStatuses.forEach(status => {
                summary.taskStatusCounts[status] = 0;
            });

            // Count tasks by status
            allInterns.data.forEach(intern => {
                if (intern.tasksAssigned) {
                    try {
                        const tasks = JSON.parse(intern.tasksAssigned);
                        tasks.forEach(task => {
                            if (summary.taskStatusCounts.hasOwnProperty(task.status)) {
                                summary.taskStatusCounts[task.status]++;
                            }
                        });
                    } catch (e) {
                        // Skip invalid task data
                    }
                }
            });

            return {
                success: true,
                data: summary
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }
}

// Initialize system
async function initializeSystem() {
    try {
        const internSystem = new InternManagement();
        
        // Validate environment
        const required = ['APPWRITE_ENDPOINT', 'APPWRITE_PROJECT_ID', 'APPWRITE_API_KEY', 'DATABASE_ID', 'COLLECTION_ID'];
        const missing = required.filter(key => !process.env[key]);
        
        if (missing.length > 0) {
            throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
        }

        console.log('✅ Intern Management System initialized');
        console.log(`📊 Valid task statuses: ${internSystem.validTaskStatuses.join(', ')}`);
        
        return internSystem;
    } catch (error) {
        console.error('❌ System initialization failed:', error.message);
        process.exit(1);
    }
}

// Export the class
module.exports = { InternManagement, initializeSystem };

// Run initialization if this file is executed directly
if (require.main === module) {
    initializeSystem().then(system => {
        console.log('System ready for use!');
    }).catch(console.error);
}
