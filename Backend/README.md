# Intern Management System API Documentation

## Overview

The Intern Management System is a RESTful API built with Node.js and Appwrite that provides comprehensive intern and task management capabilities. The system allows you to manage interns, assign tasks, track task statuses, and perform various queries and analytics.

## Features

- **CRUD Operations**: Complete Create, Read, Update, Delete operations for interns
- **Task Management**: Assign and track tasks with multiple status states
- **Custom Document IDs**: Support for both auto-generated and custom document IDs
- **Query & Filtering**: Advanced filtering, searching, and pagination
- **Analytics**: Task summary and statistics
- **Status Tracking**: Six different task statuses (open, completed, todo, working, deferred, pending)

## Base URL

```
https://688a1c420012de357297.fra.appwrite.run
```

## Environment Variables

The following environment variables are required:

```env
APPWRITE_ENDPOINT=your_appwrite_endpoint
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
DATABASE_ID=your_database_id
COLLECTION_ID=your_collection_id
```

## Data Models

### Intern Model

```javascript
{
  "$id": "string",           // Document ID (auto-generated or custom)
  "internName": "string",    // Required: Name of the intern
  "batch": "string",         // Required: Batch identifier
  "roles": ["string"],       // Array of roles
  "currentProjects": ["string"], // Array of current projects
  "tasksAssigned": [Task],   // Array of assigned tasks
  "$createdAt": "datetime",  // Auto-generated creation timestamp
  "$updatedAt": "datetime"   // Auto-generated update timestamp
}
```

### Task Model

```javascript
{
  "id": "string",           // Unique task identifier
  "title": "string",        // Required: Task title
  "description": "string",  // Task description
  "status": "string",       // Required: Task status (see valid statuses below)
  "assignedAt": "datetime", // Task assignment timestamp
  "updatedAt": "datetime"   // Last update timestamp
}
```

### Valid Task Statuses

- `open`: Task is available to start
- `todo`: Task is planned but not started
- `working`: Task is currently in progress
- `completed`: Task has been finished
- `pending`: Task is waiting for something
- `deferred`: Task has been postponed

## API Endpoints

### 1. Get All Interns

**GET** `/interns`

Retrieves all interns from the system with optional filtering.

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `batch` | string | Filter by specific batch |
| `search` | string | Search interns by name |
| `limit` | number | Limit number of results |
| `offset` | number | Offset for pagination |
| `sort` | string | Field to sort by |
| `order` | string | Sort order: `asc` or `desc` |

#### Example Request

```http
GET /interns?batch=2025-Summer&limit=10&offset=0
```

#### Response

```json
{
  "success": true,
  "data": [
    {
      "$id": "custom-intern-001",
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

### 2. Get Specific Intern

**GET** `/interns/{internId}`

Retrieves a specific intern by their ID.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `internId` | string | The intern's document ID |

#### Example Request

```http
GET /interns/custom-intern-001
```

#### Response

```json
{
  "success": true,
  "data": {
    "$id": "custom-intern-001",
    "internName": "John Doe",
    "batch": "2025-Summer",
    "roles": ["Frontend Developer"],
    "currentProjects": ["E-commerce Website"],
    "tasksAssigned": [...],
    "$createdAt": "2025-07-30T10:00:00.000Z",
    "$updatedAt": "2025-07-30T10:00:00.000Z"
  }
}
```

### 3. Create New Intern

**POST** `/interns`

Creates a new intern in the system.

#### Request Body

```json
{
  "documentId": "custom-intern-001",  // Optional: Custom document ID
  "internName": "John Doe",           // Required
  "batch": "2025-Summer",             // Required
  "roles": ["Frontend Developer"],     // Optional
  "currentProjects": ["Project Name"], // Optional
  "tasksAssigned": [                  // Optional
    {
      "id": "task-1",                 // Optional: auto-generated if not provided
      "title": "Task Title",          // Required
      "description": "Task Description", // Optional
      "status": "open",               // Required
      "assignedAt": "2025-07-30T10:00:00.000Z", // Optional: auto-generated if not provided
      "updatedAt": "2025-07-30T10:00:00.000Z"   // Optional: auto-generated if not provided
    }
  ]
}
```

#### Example Request

```http
POST /interns
Content-Type: application/json

{
  "documentId": "custom-intern-001",
  "internName": "John Doe",
  "batch": "2025-Summer",
  "roles": ["Frontend Developer"],
  "currentProjects": ["E-commerce Website"],
  "tasksAssigned": [
    {
      "title": "Create Login Page",
      "description": "Design and implement user login functionality",
      "status": "open"
    }
  ]
}
```

#### Response

```json
{
  "success": true,
  "data": {
    "$id": "custom-intern-001",
    "internName": "John Doe",
    "batch": "2025-Summer",
    "roles": ["Frontend Developer"],
    "currentProjects": ["E-commerce Website"],
    "tasksAssigned": [...],
    "$createdAt": "2025-07-30T10:00:00.000Z",
    "$updatedAt": "2025-07-30T10:00:00.000Z"
  },
  "message": "Intern created successfully"
}
```

### 4. Update Intern

**PATCH** `/interns/{internId}`

Updates an existing intern's information.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `internId` | string | The intern's document ID |

#### Request Body

```json
{
  "internName": "Updated Name",       // Optional
  "batch": "2025-Fall",              // Optional
  "roles": ["New Role"],             // Optional
  "currentProjects": ["New Project"], // Optional
  "tasksAssigned": [...]             // Optional
}
```

#### Example Request

```http
PATCH /interns/custom-intern-001
Content-Type: application/json

{
  "roles": ["Senior Frontend Developer", "Team Lead"],
  "tasksAssigned": [
    {
      "id": "task-1",
      "title": "Create Login Page",
      "description": "Design and implement user login functionality",
      "status": "completed"
    }
  ]
}
```

#### Response

```json
{
  "success": true,
  "data": {
    "$id": "custom-intern-001",
    "internName": "John Doe",
    "batch": "2025-Summer",
    "roles": ["Senior Frontend Developer", "Team Lead"],
    "currentProjects": ["E-commerce Website"],
    "tasksAssigned": [...],
    "$createdAt": "2025-07-30T10:00:00.000Z",
    "$updatedAt": "2025-07-30T12:00:00.000Z"
  },
  "message": "Intern updated successfully"
}
```

### 5. Delete Intern

**DELETE** `/interns/{internId}`

Deletes an intern from the system.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `internId` | string | The intern's document ID |

#### Example Request

```http
DELETE /interns/custom-intern-001
```

#### Response

```json
{
  "success": true,
  "message": "Intern deleted successfully"
}
```

### 6. Get Intern Count

**GET** `/interns/count`

Retrieves the total number of interns in the system.

#### Example Request

```http
GET /interns/count
```

#### Response

```json
{
  "success": true,
  "count": 42
}
```

### 7. Get Task Summary

**GET** `/interns/tasks/summary`

Retrieves a summary of all task statuses across all interns.

#### Example Request

```http
GET /interns/tasks/summary
```

#### Response

```json
{
  "success": true,
  "summary": {
    "open": 15,
    "todo": 8,
    "working": 12,
    "completed": 45,
    "pending": 3,
    "deferred": 2,
    "total": 85
  }
}
```

## Error Responses

All error responses follow this format:

```json
{
  "success": false,
  "error": "Error message description"
}
```

### Common Error Codes

- **400 Bad Request**: Invalid request data or missing required fields
- **404 Not Found**: Intern or resource not found
- **500 Internal Server Error**: Server-side error

## Task Validation Rules

1. **Title**: Required, cannot be empty
2. **Status**: Required, must be one of the valid statuses
3. **ID**: Auto-generated if not provided
4. **Timestamps**: Auto-generated if not provided

## Examples

### Creating an Intern with Custom ID

```bash
curl -X POST "https://688a1c420012de357297.fra.appwrite.run/interns" \
  -H "Content-Type: application/json" \
  -d '{
    "documentId": "intern-2025-001",
    "internName": "Alice Johnson",
    "batch": "2025-Summer",
    "roles": ["Full Stack Developer"],
    "currentProjects": ["Mobile App", "API Development"],
    "tasksAssigned": [
      {
        "title": "Setup Development Environment",
        "description": "Configure local development setup",
        "status": "completed"
      },
      {
        "title": "Database Integration",
        "description": "Integrate with Appwrite database",
        "status": "working"
      }
    ]
  }'
```

### Filtering Interns by Batch

```bash
curl "https://688a1c420012de357297.fra.appwrite.run/interns?batch=2025-Summer&limit=5"
```

### Updating Task Status

```bash
curl -X PATCH "https://688a1c420012de357297.fra.appwrite.run/interns/intern-2025-001" \
  -H "Content-Type: application/json" \
  -d '{
    "tasksAssigned": [
      {
        "id": "task-1",
        "title": "Setup Development Environment",
        "description": "Configure local development setup",
        "status": "completed"
      },
      {
        "id": "task-2",
        "title": "Database Integration",
        "description": "Integrate with Appwrite database",
        "status": "completed"
      }
    ]
  }'
```

## Rate Limiting

The API doesn't implement rate limiting by default, but it's recommended to implement it based on your Appwrite configuration and usage requirements.

## Authentication

This API doesn't require authentication for basic operations, but in production, you should implement proper authentication and authorization mechanisms.

## Support

For issues and questions, please refer to the project repository or contact the development team.
