# Intern Management System

A comprehensive full-stack application for managing interns, projects, and tasks with a modern Flutter frontend and Node.js backend powered by Appwrite.

## 🌟 Features

### Frontend (Flutter)
- **📱 Responsive Dashboard**: Modern Material Design 3 interface
- **🎯 Multi-screen Navigation**: Home, Projects, and Tasks views
- **📊 Real-time Statistics**: Interactive cards showing key metrics
- **🔍 Advanced Search & Filtering**: Find interns, projects, and tasks quickly
- **✨ Smooth Animations**: Elegant transitions and hover effects
- **📋 Task Management**: Create, update, and track task progress
- **👥 Team Collaboration**: Project-based team visualization
- **🎨 Color-coded Status**: Visual status indicators for tasks and projects

### Backend (Node.js + Appwrite)
- **🚀 RESTful API**: Comprehensive CRUD operations
- **📊 Data Aggregation**: Statistics and summary endpoints
- **🔍 Advanced Querying**: Filtering, sorting, and pagination
- **✅ Input Validation**: Robust data validation and error handling
- **🌐 CORS Support**: Cross-origin resource sharing configured
- **📈 Scalable Architecture**: Built for growth and performance

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter/Dart with GetX state management
- **Backend**: Node.js with native HTTP server
- **Database**: Appwrite Cloud Database
- **HTTP Client**: Flutter HTTP package
- **UI Framework**: Material Design 3
- **State Management**: GetX reactive framework

### Project Structure
```
Flutter-Node.js-Appwrite/
├── Frontend/                  # Flutter application
│   ├── lib/
│   │   ├── main.dart         # App entry point
│   │   ├── config/           # Configuration files
│   │   ├── controllers/      # GetX controllers
│   │   ├── models/           # Data models
│   │   ├── screens/          # Main screens
│   │   ├── services/         # API services
│   │   └── widgets/          # Reusable widgets
│   ├── pubspec.yaml          # Flutter dependencies
│   └── FRONTEND_DOCUMENTATION.md
│
├── Backend/                   # Node.js API server
│   ├── index.js              # API logic and handlers
│   ├── main.js               # HTTP server setup
│   ├── package.json          # Node.js dependencies
│   ├── postman-collection.json
│   └── BACKEND_DOCUMENTATION.md
│
└── README.md                 # This file
```

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK** (3.0+)
- **Node.js** (16+)
- **Appwrite Account** (Free tier available)
- **Git**

### 1. Clone Repository
```bash
git clone https://github.com/your-username/Flutter-Node.js-Appwrite.git
cd Flutter-Node.js-Appwrite
```

### 2. Backend Setup

#### Install Dependencies
```bash
cd Backend
npm install
```

#### Configure Environment
Create `.env` file in Backend directory:
```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-api-key
DATABASE_ID=your-database-id
COLLECTION_ID=your-collection-id
PORT=3000
```

#### Start Backend Server
```bash
npm start
# Server runs on http://localhost:3000
```

### 3. Frontend Setup

#### Install Dependencies
```bash
cd ../Frontend
flutter pub get
```

#### Configure API Endpoint
Update `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:3000';
  // ... other configurations
}
```

#### Run Flutter Application
```bash
flutter run -d chrome
# For web development

flutter run
# For mobile development
```

## 📱 Application Features

### Dashboard Home Screen
- **Statistics Overview**: Total interns, active projects, task completion rates
- **Intern Grid View**: Visual cards with intern details and status
- **Quick Actions**: Add new interns, assign tasks, view details
- **Search & Filter**: Real-time search with role and batch filtering

### Projects Management
- **Project Overview**: All projects with assigned team members
- **Team Visualization**: Color-coded member chips for each project
- **Progress Tracking**: Project completion status and metrics
- **Resource Allocation**: View intern assignments across projects

### Task Management
- **Task Dashboard**: Comprehensive view of all tasks across interns
- **Status Filtering**: Filter by open, completed, working, deferred, pending
- **Assignment Interface**: Assign tasks to specific interns
- **Progress Tracking**: Visual status indicators and completion tracking

### Intern Management
- **Simplified Form**: Streamlined intern creation with essential fields
- **Multi-select Roles**: Searchable dropdown for role assignment
- **Detailed Views**: Comprehensive intern profiles with task history
- **Batch Management**: Organize interns by intake batches

## 🔧 Configuration

### Available Roles
```dart
static const List<String> availableRoles = [
  'Frontend Developer',
  'Backend Developer',
  'Full Stack Developer',
  'Mobile Developer',
  'UI/UX Designer',
  'DevOps Engineer',
  'Data Scientist',
  'Project Manager',
  'Quality Assurance',
  'Team Lead'
];
```

### Task Status Colors
- **Open**: Orange (New tasks)
- **Completed**: Green (Finished tasks)
- **Working**: Blue (In progress)
- **Todo**: Purple (Planned tasks)
- **Deferred**: Red (Postponed)
- **Pending**: Grey (Waiting for dependencies)

## 📖 API Documentation

### Key Endpoints

#### Interns
- `GET /interns` - List all interns with filtering
- `GET /interns/{id}` - Get specific intern
- `POST /interns` - Create new intern
- `PATCH /interns/{id}` - Update intern
- `DELETE /interns/{id}` - Delete intern

#### Statistics
- `GET /interns/count` - Total intern count
- `GET /interns/tasks/summary` - Task statistics

### Request Examples

#### Create Intern
```bash
POST /interns
Content-Type: application/json

{
  "internName": "John Doe",
  "batch": "2025-Summer",
  "roles": ["Frontend Developer", "UI/UX Designer"],
  "currentProjects": ["E-commerce Platform"],
  "tasksAssigned": [
    {
      "title": "Design Login Page",
      "description": "Create responsive login interface",
      "status": "open"
    }
  ]
}
```

#### Filter Interns
```bash
GET /interns?batch=2025-Summer&limit=10&search=john&sort=createdAt&order=desc
```

## 🎨 UI/UX Features

### Design System
- **Material Design 3**: Modern design language
- **Responsive Layout**: Adapts to different screen sizes
- **Dark Theme Support**: Built-in theme switching capability
- **Accessibility**: Screen reader and keyboard navigation support

### Animations
- **Page Transitions**: Smooth fade animations between screens
- **Hover Effects**: Interactive button and card hover states
- **Loading States**: Progress indicators and skeleton screens
- **Status Changes**: Animated status transitions

### Color Palette
- **Primary**: Blue accent colors for actions and navigation
- **Surface**: Clean backgrounds with proper elevation
- **Status Colors**: Distinct colors for different task states
- **Semantic Colors**: Success, warning, error, and info indicators

## 🧪 Testing

### Frontend Testing
```bash
cd Frontend
flutter test
```

### Backend Testing
```bash
cd Backend
npm test
```

### Integration Testing
```bash
# Test API endpoints with Postman collection
newman run postman-collection.json
```

## 📦 Deployment

### Frontend Deployment

#### Web Deployment
```bash
flutter build web
# Deploy dist/ folder to web hosting
```

#### Mobile App Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Backend Deployment

#### Using PM2
```bash
npm install -g pm2
pm2 start main.js --name "intern-api"
```

#### Using Docker
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

#### Cloud Platforms
- **Heroku**: `git push heroku main`
- **Vercel**: `vercel deploy`
- **AWS/Azure**: Use respective deployment tools

## 🔒 Security

### Frontend Security
- **Input Validation**: Client-side validation for all forms
- **XSS Prevention**: Proper data sanitization
- **HTTPS Enforcement**: Secure communication protocols

### Backend Security
- **CORS Configuration**: Proper cross-origin setup
- **Input Sanitization**: Server-side validation
- **Rate Limiting**: API request throttling
- **Environment Variables**: Secure configuration management

## 📊 Monitoring

### Performance Metrics
- **API Response Times**: Monitor endpoint performance
- **Database Queries**: Track query efficiency
- **Error Rates**: Monitor and alert on failures
- **User Analytics**: Track feature usage

### Health Checks
```bash
# Check backend health
curl http://localhost:3000/health

# Check frontend build
flutter doctor
```

## 🐛 Troubleshooting

### Common Issues

#### Network Connection Errors
```dart
// In app_config.dart, verify correct base URL
static const String baseUrl = 'http://localhost:3000';
```

#### CORS Issues
```javascript
// In main.js, check CORS headers
res.setHeader('Access-Control-Allow-Origin', '*');
```

#### Flutter Dependencies
```bash
flutter clean
flutter pub get
flutter pub deps
```

#### Node.js Issues
```bash
npm cache clean --force
rm -rf node_modules
npm install
```

## 🔄 Development Workflow

### Adding New Features

1. **Backend First**: Create API endpoints
2. **Frontend Integration**: Update services and controllers
3. **UI Implementation**: Create/update screens and widgets
4. **Testing**: Write unit and integration tests
5. **Documentation**: Update relevant documentation

### Code Style

#### Flutter/Dart
- Use `dart format` for consistent formatting
- Follow official Dart style guide
- Use meaningful variable and function names
- Write comprehensive comments

#### Node.js
- Use ESLint for code consistency
- Follow Node.js best practices
- Implement proper error handling
- Write comprehensive API documentation

## 🤝 Contributing

### Getting Started
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Add tests for new functionality
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Development Guidelines
- Write clear commit messages
- Add tests for new features
- Update documentation as needed
- Follow existing code patterns
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing cross-platform framework
- **Appwrite**: For the backend-as-a-service platform
- **Material Design**: For the design system
- **GetX**: For reactive state management
- **Community**: For continuous support and contributions

## 📞 Support

### Documentation
- [Frontend Documentation](Frontend/FRONTEND_DOCUMENTATION.md)
- [Backend Documentation](Backend/BACKEND_DOCUMENTATION.md)

### Getting Help
- **Issues**: Report bugs and feature requests on GitHub Issues
- **Discussions**: Join project discussions on GitHub Discussions
- **Email**: Contact the maintainers at support@internmanagement.com

### Useful Links
- [Flutter Documentation](https://docs.flutter.dev/)
- [Node.js Documentation](https://nodejs.org/docs/)
- [Appwrite Documentation](https://appwrite.io/docs)
- [GetX Documentation](https://pub.dev/packages/get)

---

**Built with ❤️ by the Development Team**

*Last Updated: December 2024*
