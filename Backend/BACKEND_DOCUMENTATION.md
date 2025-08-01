# Intern Management System - Backend Documentation

## Overview

A Node.js-based REST API backend using Appwrite as the database for managing interns and their tasks. The system provides comprehensive CRUD operations with advanced querying, filtering, and aggregation capabilities.

## Features

### 🔧 Core Functionality
- **Intern Management**: Full CRUD operations for intern records
- **Task Management**: Embedded task system within intern documents
- **Advanced Querying**: Support for filtering, sorting, pagination, and search
- **Data Aggregation**: Statistics and summary endpoints
- **Validation**: Comprehensive input validation and error handling
- **CORS Support**: Configured for cross-origin requests

### 📊 API Capabilities
- **RESTful Design**: Standard HTTP methods and status codes
- **JSON Responses**: Consistent response format across all endpoints
- **Error Handling**: Detailed error messages and proper HTTP status codes
- **Pagination**: Configurable pagination for large datasets
- **Search**: Full-text search across intern names and attributes

## Architecture

### Technology Stack
- **Runtime**: Node.js
- **Database**: Appwrite (Cloud database service)
- **HTTP Server**: Native Node.js HTTP module
- **Environment**: dotenv for configuration management

### File Structure
```
Backend/
├── index.js                 # Main application logic and API handlers
├── main.js                  # HTTP server setup and routing
├── package.json             # Dependencies and scripts
├── .env                     # Environment variables (not in repo)
├── README.md               # API documentation
└── postman-collection.json # Postman API collection
```

### Database Schema

#### Intern Document Structure
```json
{
  "$id": "string",                    // Appwrite document ID
  "internName": "string",             // Required: Intern's full name
  "batch": "string",                  // Required: Batch identifier
  "roles": ["string"],               // Array of role strings
  "currentProjects": ["string"],     // Array of project names
  "tasksAssigned": ["string"],       // Array of JSON-encoded task objects
  "$createdAt": "datetime",          // Auto-generated creation timestamp
  "$updatedAt": "datetime",          // Auto-generated update timestamp
  "$permissions": [],                // Appwrite permissions array
  "$databaseId": "string",           // Database identifier
  "$collectionId": "string"          // Collection identifier
}
```

#### Task Object Structure (JSON-encoded in tasksAssigned)
```json
{
  "id": "string",              // Unique task identifier
  "title": "string",           // Required: Task title
  "description": "string",     // Optional: Task description
  "status": "string",          // Required: Task status
  "assignedAt": "datetime",    // Task assignment timestamp
  "updatedAt": "datetime"      // Last update timestamp
}
```

## Installation & Setup

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn package manager
- Appwrite account and project setup

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Flutter-Node.js-Appwrite/Backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   Create a `.env` file in the Backend directory:
   ```env
   # Appwrite Configuration
   APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
   APPWRITE_PROJECT_ID=your-project-id
   APPWRITE_API_KEY=your-api-key
   DATABASE_ID=your-database-id
   COLLECTION_ID=your-collection-id
   
   # Server Configuration
   PORT=3000
   NODE_ENV=development
   ```

4. **Set up Appwrite**
   - Create an Appwrite project
   - Create a database
   - Create a collection with the following attributes:
     - `internName` (string, required)
     - `batch` (string, required)
     - `roles` (string array, optional)
     - `currentProjects` (string array, optional)
     - `tasksAssigned` (string array, optional)

### Running the Server

#### Development Mode
```bash
# Start the server with nodemon (auto-reload)
npm run dev

# Or start normally
npm start
```

#### Production Mode
```bash
# Set environment to production
export NODE_ENV=production

# Start the server
npm start
```

#### Using PM2 (Recommended for Production)
```bash
# Install PM2 globally
npm install -g pm2

# Start with PM2
pm2 start main.js --name "intern-management-api"

# Monitor
pm2 monit

# Logs
pm2 logs intern-management-api
```

## API Reference

### Base URL
- **Local Development**: `http://localhost:3000`
- **Production**: `https://your-domain.com`

### Response Format
All API responses follow this consistent format:
```json
{
  "success": boolean,
  "data": any,           // Present on successful responses
  "error": "string",     // Present on error responses
  "total": number        // Present on list responses
}
```

### Endpoints

#### 1. Get All Interns
**GET** `/interns`

Retrieve all interns with optional filtering and pagination.

**Query Parameters:**
- `batch` (string): Filter by batch
- `search` (string): Search in intern names
- `limit` (number): Number of results to return (default: 50)
- `offset` (number): Number of results to skip (default: 0)
- `sort` (string): Field to sort by (default: "createdAt")
- `order` (string): Sort order "asc" or "desc" (default: "desc")

**Example Request:**
```bash
GET /interns?batch=2025-Summer&limit=10&offset=0&search=john
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "$id": "intern-001",
      "internName": "John Doe",
      "batch": "2025-Summer",
      "roles": ["Frontend Developer"],
      "currentProjects": ["E-commerce Website"],
      "tasksAssigned": [
        {
          "id": "task-1",
          "title": "Create Login Page",
          "description": "Design and implement user login functionality",
          "status": "open",
          "assignedAt": "2025-07-30T10:00:00.000Z",
          "updatedAt": "2025-07-30T10:00:00.000Z"
        }
      ],
      "$createdAt": "2025-07-30T10:00:00.000Z",
      "$updatedAt": "2025-07-30T10:00:00.000Z"
    }
  ],
  "total": 1
}
```

#### 2. Get Specific Intern
**GET** `/interns/{internId}`

Retrieve a specific intern by their ID.

**Path Parameters:**
- `internId` (string): The intern's document ID

**Example Request:**
```bash
GET /interns/intern-001
```

#### 3. Create New Intern
**POST** `/interns`

Create a new intern record.

**Request Body:**
```json
{
  "documentId": "custom-intern-001",  // Optional: Custom document ID
  "internName": "John Doe",           // Required
  "batch": "2025-Summer",             // Required
  "roles": ["Frontend Developer"],    // Optional
  "currentProjects": ["Project Name"], // Optional
  "tasksAssigned": [                  // Optional
    {
      "id": "task-1",                 // Optional: auto-generated if not provided
      "title": "Task Title",          // Required
      "description": "Task Description", // Optional
      "status": "open",               // Required
      "assignedAt": "2025-07-30T10:00:00.000Z", // Optional: auto-generated
      "updatedAt": "2025-07-30T10:00:00.000Z"   // Optional: auto-generated
    }
  ]
}
```

**Validation Rules:**
- `internName`: Required, non-empty string
- `batch`: Required, non-empty string
- `roles`: Optional array of strings
- `currentProjects`: Optional array of strings
- `tasksAssigned`: Optional array of task objects
- Each task must have `title` and `status`
- Task status must be one of: `open`, `completed`, `todo`, `working`, `deferred`, `pending`

#### 4. Update Intern
**PATCH** `/interns/{internId}`

Update an existing intern record.

**Path Parameters:**
- `internId` (string): The intern's document ID

**Request Body:** (All fields optional)
```json
{
  "internName": "Jane Smith",
  "batch": "2025-Fall",
  "roles": ["Backend Developer", "Team Lead"],
  "currentProjects": ["API Development"],
  "tasksAssigned": [
    {
      "id": "task-1",
      "title": "Updated Task Title",
      "description": "Updated description",
      "status": "completed",
      "assignedAt": "2025-07-30T10:00:00.000Z",
      "updatedAt": "2025-07-30T15:00:00.000Z"
    }
  ]
}
```

#### 5. Delete Intern
**DELETE** `/interns/{internId}`

Delete an intern record.

**Path Parameters:**
- `internId` (string): The intern's document ID

**Example Response:**
```json
{
  "success": true,
  "data": {
    "message": "Intern deleted successfully"
  }
}
```

#### 6. Get Intern Count
**GET** `/interns/count`

Get the total count of interns.

**Example Response:**
```json
{
  "success": true,
  "count": 42
}
```

#### 7. Get Task Summary
**GET** `/interns/tasks/summary`

Get aggregated task statistics across all interns.

**Example Response:**
```json
{
  "success": true,
  "summary": {
    "open": 15,
    "completed": 23,
    "working": 8,
    "todo": 12,
    "deferred": 3,
    "pending": 5
  }
}
```

### Error Handling

#### HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `404`: Not Found
- `500`: Internal Server Error

#### Error Response Format
```json
{
  "success": false,
  "error": "Detailed error message"
}
```

#### Common Error Scenarios
1. **Validation Errors**: Missing required fields, invalid data types
2. **Not Found**: Intern ID doesn't exist
3. **Database Errors**: Connection issues, permission errors
4. **Task Validation**: Invalid task status, missing task fields

## Configuration

### Environment Variables
```env
# Appwrite Configuration (Required)
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-server-api-key
DATABASE_ID=your-database-id
COLLECTION_ID=your-collection-id

# Server Configuration (Optional)
PORT=3000                    # Server port (default: 3000)
NODE_ENV=development         # Environment mode

# CORS Configuration (Optional)
CORS_ORIGIN=*               # Allowed origins (default: *)
```

### Task Status Configuration
Valid task statuses are defined in the application:
```javascript
const validTaskStatuses = [
  'open',      // New task
  'completed', // Finished task
  'todo',      // Planned task
  'working',   // In progress
  'deferred',  // Postponed
  'pending'    // Waiting for dependencies
];
```

### Appwrite Collection Setup
Required collection attributes:
```javascript
// String attributes
internName: { type: 'string', required: true, size: 255 }
batch: { type: 'string', required: true, size: 100 }

// Array attributes
roles: { type: 'string', required: false, array: true }
currentProjects: { type: 'string', required: false, array: true }
tasksAssigned: { type: 'string', required: false, array: true }
```

## Deployment

### Local Development
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Server runs on http://localhost:3000
```

### Production Deployment

#### Using Docker
```dockerfile
FROM node:16-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
EXPOSE 3000

CMD ["npm", "start"]
```

#### Using PM2
```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start ecosystem.config.js

# Configure auto-restart
pm2 startup
pm2 save
```

#### Using Cloud Platforms

**Heroku:**
```bash
# Add buildpack
heroku buildpacks:set heroku/nodejs

# Set environment variables
heroku config:set APPWRITE_ENDPOINT=your-endpoint
heroku config:set APPWRITE_PROJECT_ID=your-project-id
# ... other env vars

# Deploy
git push heroku main
```

**Vercel:**
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables in Vercel dashboard
```

### Environment-Specific Configuration
```javascript
// config/environment.js
const config = {
  development: {
    port: process.env.PORT || 3000,
    corsOrigin: '*',
    logLevel: 'debug'
  },
  production: {
    port: process.env.PORT || 8080,
    corsOrigin: process.env.CORS_ORIGIN || 'https://yourdomain.com',
    logLevel: 'error'
  }
};

module.exports = config[process.env.NODE_ENV || 'development'];
```

## Monitoring & Logging

### Application Logging
```javascript
// Add to main.js
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Log requests
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.url}`, {
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });
  next();
});
```

### Health Check Endpoint
```javascript
// Add to main.js
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});
```

### Performance Monitoring
```javascript
// Add request timing
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.url} - ${res.statusCode} - ${duration}ms`);
  });
  next();
});
```

## Security

### CORS Configuration
```javascript
// In main.js
res.setHeader('Access-Control-Allow-Origin', process.env.CORS_ORIGIN || '*');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
```

### Input Validation
```javascript
// Validation middleware
function validateIntern(data) {
  if (!data.internName || typeof data.internName !== 'string') {
    throw new Error('Invalid intern name');
  }
  if (!data.batch || typeof data.batch !== 'string') {
    throw new Error('Invalid batch');
  }
  // Additional validations...
}
```

### Rate Limiting (Recommended)
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP'
});

app.use(limiter);
```

## Testing

### Unit Tests
```javascript
// tests/intern.test.js
const { InternManagement } = require('../index');

describe('Intern Management', () => {
  let internSystem;

  beforeEach(() => {
    internSystem = new InternManagement();
  });

  test('should validate intern data', () => {
    const validIntern = {
      internName: 'John Doe',
      batch: '2025-Summer'
    };
    
    expect(() => internSystem.validateIntern(validIntern)).not.toThrow();
  });

  test('should reject invalid task status', () => {
    const invalidTask = {
      title: 'Test Task',
      status: 'invalid-status'
    };
    
    expect(() => internSystem.validateTask(invalidTask)).toThrow();
  });
});
```

### Integration Tests
```javascript
// tests/api.test.js
const request = require('supertest');
const app = require('../main');

describe('API Endpoints', () => {
  test('GET /interns should return intern list', async () => {
    const response = await request(app)
      .get('/interns')
      .expect(200);
    
    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.data)).toBe(true);
  });

  test('POST /interns should create new intern', async () => {
    const newIntern = {
      internName: 'Test Intern',
      batch: '2025-Test'
    };

    const response = await request(app)
      .post('/interns')
      .send(newIntern)
      .expect(201);
    
    expect(response.body.success).toBe(true);
    expect(response.body.data.internName).toBe(newIntern.internName);
  });
});
```

### Load Testing
```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:3000/interns

# Using Artillery
npm install -g artillery
artillery quick --count 10 --num 50 http://localhost:3000/interns
```

## Troubleshooting

### Common Issues

1. **Appwrite Connection Failed**
   - Verify API key and project ID
   - Check network connectivity
   - Ensure proper permissions

2. **Database Permissions**
   - Check collection permissions in Appwrite dashboard
   - Verify API key has required scopes

3. **CORS Errors**
   - Update CORS_ORIGIN environment variable
   - Check browser console for specific CORS errors

4. **Memory Issues**
   - Monitor memory usage with `process.memoryUsage()`
   - Implement proper cleanup for large datasets

### Debug Mode
```bash
# Enable debug logging
DEBUG=* npm start

# Or specific modules
DEBUG=appwrite:* npm start
```

### Performance Issues
```javascript
// Add performance monitoring
const performanceHooks = require('perf_hooks');

function measurePerformance(name, fn) {
  return async (...args) => {
    const start = performanceHooks.performance.now();
    const result = await fn(...args);
    const end = performanceHooks.performance.now();
    console.log(`${name} took ${end - start} milliseconds`);
    return result;
  };
}
```

## API Collection

### Postman Collection
A complete Postman collection is included (`postman-collection.json`) with:
- All API endpoints
- Example requests and responses
- Environment variables setup
- Test scripts for validation

### Usage
1. Import `postman-collection.json` into Postman
2. Set up environment variables:
   - `base_url`: Your API base URL
   - `intern_id`: Test intern ID for specific requests
3. Run individual requests or the entire collection

## Future Enhancements

### Planned Features
- [ ] Authentication and authorization
- [ ] File upload support for intern profiles
- [ ] Bulk operations (batch create/update)
- [ ] Advanced search with fuzzy matching
- [ ] Real-time updates with WebSockets
- [ ] API versioning
- [ ] GraphQL endpoint option
- [ ] Automated backup system

### Performance Improvements
- [ ] Redis caching layer
- [ ] Database indexing optimization
- [ ] Response compression
- [ ] Connection pooling
- [ ] Request queuing for high load

### Monitoring Enhancements
- [ ] Prometheus metrics
- [ ] Distributed tracing
- [ ] Custom dashboards
- [ ] Alert system for errors
- [ ] Performance analytics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Style
- Use ESLint configuration
- Follow Node.js best practices
- Write comprehensive tests
- Document new features

## License

This project is licensed under the MIT License - see the LICENSE file for details.
