/**
 * @fileoverview Mock Intern Management System for Development
 * @description A mock API for testing frontend without Appwrite setup
 */

/**
 * @class MockInternManagement
 * @description Mock implementation for development testing
 */
class MockInternManagement {
    constructor() {
        // Mock data for development
        this.mockInterns = [
            {
                $id: 'intern-001',
                internName: 'John Doe',
                batch: '2025-Summer',
                roles: ['Frontend Developer', 'UI/UX Designer'],
                currentProjects: ['E-commerce Platform', 'Mobile App'],
                tasksAssigned: [
                    {
                        id: 'task-1',
                        title: 'Create Login Page',
                        description: 'Design and implement user login functionality',
                        status: 'working',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    },
                    {
                        id: 'task-2',
                        title: 'Setup Database Schema',
                        description: 'Design and create database tables',
                        status: 'completed',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    }
                ],
                $createdAt: new Date().toISOString(),
                $updatedAt: new Date().toISOString()
            },
            {
                $id: 'intern-002',
                internName: 'Jane Smith',
                batch: '2025-Summer',
                roles: ['Backend Developer', 'DevOps Engineer'],
                currentProjects: ['API Development', 'Cloud Infrastructure'],
                tasksAssigned: [
                    {
                        id: 'task-3',
                        title: 'API Documentation',
                        description: 'Create comprehensive API documentation',
                        status: 'open',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    }
                ],
                $createdAt: new Date().toISOString(),
                $updatedAt: new Date().toISOString()
            },
            {
                $id: 'intern-003',
                internName: 'Mike Johnson',
                batch: '2025-Fall',
                roles: ['Full Stack Developer'],
                currentProjects: ['CRM System'],
                tasksAssigned: [
                    {
                        id: 'task-4',
                        title: 'User Authentication',
                        description: 'Implement JWT-based authentication',
                        status: 'todo',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    },
                    {
                        id: 'task-5',
                        title: 'Dashboard Design',
                        description: 'Create responsive dashboard layout',
                        status: 'pending',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    }
                ],
                $createdAt: new Date().toISOString(),
                $updatedAt: new Date().toISOString()
            },
            {
                $id: 'intern-004',
                internName: 'Sarah Wilson',
                batch: '2025-Spring',
                roles: ['Mobile Developer', 'UI/UX Designer'],
                currentProjects: ['Mobile Shopping App'],
                tasksAssigned: [
                    {
                        id: 'task-6',
                        title: 'Wireframe Creation',
                        description: 'Create wireframes for mobile app',
                        status: 'deferred',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    }
                ],
                $createdAt: new Date().toISOString(),
                $updatedAt: new Date().toISOString()
            },
            {
                $id: 'intern-005',
                internName: 'Alex Chen',
                batch: '2025-Summer',
                roles: ['Data Scientist', 'Backend Developer'],
                currentProjects: ['Analytics Dashboard', 'ML Pipeline'],
                tasksAssigned: [
                    {
                        id: 'task-7',
                        title: 'Data Analysis',
                        description: 'Analyze user behavior patterns',
                        status: 'working',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    },
                    {
                        id: 'task-8',
                        title: 'Model Training',
                        description: 'Train recommendation algorithm',
                        status: 'completed',
                        assignedAt: new Date().toISOString(),
                        updatedAt: new Date().toISOString()
                    }
                ],
                $createdAt: new Date().toISOString(),
                $updatedAt: new Date().toISOString()
            }
        ];
        
        this.validTaskStatuses = ['open', 'completed', 'todo', 'working', 'deferred', 'pending'];
    }

    // Simulate async operations with small delays
    async delay(ms = 100) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async getAllInterns(queries = []) {
        await this.delay();
        
        try {
            let filteredInterns = [...this.mockInterns];
            
            // Apply filters (simplified simulation)
            queries.forEach(query => {
                // This is a simplified mock - in real Appwrite these would be Query objects
                if (typeof query === 'object' && query.method) {
                    switch (query.method) {
                        case 'equal':
                            if (query.attribute === 'batch') {
                                filteredInterns = filteredInterns.filter(intern => 
                                    intern.batch === query.values[0]
                                );
                            }
                            break;
                        case 'search':
                            if (query.attribute === 'internName') {
                                filteredInterns = filteredInterns.filter(intern => 
                                    intern.internName.toLowerCase().includes(query.values[0].toLowerCase())
                                );
                            }
                            break;
                        case 'limit':
                            filteredInterns = filteredInterns.slice(0, query.values[0]);
                            break;
                        case 'offset':
                            filteredInterns = filteredInterns.slice(query.values[0]);
                            break;
                    }
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

    async getIntern(internId) {
        await this.delay();
        
        try {
            const intern = this.mockInterns.find(i => i.$id === internId);
            if (!intern) {
                return {
                    success: false,
                    error: 'Intern not found'
                };
            }
            
            return {
                success: true,
                data: intern
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    async createIntern(internData) {
        await this.delay();
        
        try {
            if (!internData.internName || !internData.batch) {
                return {
                    success: false,
                    error: 'internName and batch are required'
                };
            }
            
            const newIntern = {
                $id: `intern-${Date.now()}`,
                internName: internData.internName,
                batch: internData.batch,
                roles: internData.roles || [],
                currentProjects: internData.currentProjects || [],
                tasksAssigned: internData.tasksAssigned || [],
                $createdAt: new Date().toISOString(),
                $updatedAt: new Date().toISOString()
            };
            
            this.mockInterns.push(newIntern);
            
            return {
                success: true,
                data: newIntern
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    async updateIntern(internId, updateData) {
        await this.delay();
        
        try {
            const internIndex = this.mockInterns.findIndex(i => i.$id === internId);
            if (internIndex === -1) {
                return {
                    success: false,
                    error: 'Intern not found'
                };
            }
            
            this.mockInterns[internIndex] = {
                ...this.mockInterns[internIndex],
                ...updateData,
                $updatedAt: new Date().toISOString()
            };
            
            return {
                success: true,
                data: this.mockInterns[internIndex]
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    async deleteIntern(internId) {
        await this.delay();
        
        try {
            const internIndex = this.mockInterns.findIndex(i => i.$id === internId);
            if (internIndex === -1) {
                return {
                    success: false,
                    error: 'Intern not found'
                };
            }
            
            this.mockInterns.splice(internIndex, 1);
            
            return {
                success: true,
                data: { message: 'Intern deleted successfully' }
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    async getInternCount() {
        await this.delay();
        
        return {
            success: true,
            count: this.mockInterns.length
        };
    }

    async getTaskSummary() {
        await this.delay();
        
        try {
            const summary = {
                open: 0,
                completed: 0,
                todo: 0,
                working: 0,
                deferred: 0,
                pending: 0
            };
            
            this.mockInterns.forEach(intern => {
                if (intern.tasksAssigned && Array.isArray(intern.tasksAssigned)) {
                    intern.tasksAssigned.forEach(task => {
                        if (summary.hasOwnProperty(task.status)) {
                            summary[task.status]++;
                        }
                    });
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

export { MockInternManagement };
