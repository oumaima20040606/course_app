import 'package:course_app/pages/teacher/course_management.dart';
import 'package:course_app/pages/teacher/edit_course_screen.dart';
import 'package:flutter/material.dart';

// AUTH
import 'pages/auth/welcome_screen.dart';
import 'pages/auth/login_screen.dart';
import 'pages/auth/register_screen.dart';

// STUDENT
import 'pages/student/main_page.dart';
import 'pages/student/home_screen.dart';
import 'pages/student/course_screen.dart';
import 'pages/student/details_screen.dart';
import 'pages/student/profile_page.dart';

// TEACHER
import 'pages/teacher/teacher_dashboard.dart';
import 'pages/teacher/add_course.dart';
import 'pages/teacher/student_progress.dart';
import 'pages/teacher/teacher_chat.dart';
import 'pages/teacher/analytics_screen.dart';
import 'pages/teacher/quiz_manager.dart' as quiz_manager;

class RouteManager {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // AUTH
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';

  // STUDENT
  static const String mainStudent = '/main';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String details = '/details';
  static const String profile = '/profile';

  // TEACHER
  static const String teacherDashboard = '/teacher-dashboard';
  static const String addCourse = '/add-course';
  static const String studentProgress = '/student-progress';
  static const String teacherChat = '/teacher-chat';
  static const String analytics = '/analytics';
  static const String quizManager = '/quiz-manager';
  static const String courseManagement = '/course-management';
  static const String editCourse = '/edit-course';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // AUTH ROUTES
      case welcome:
        return _buildRoute(settings, WelcomePage());
      case login:
        return _buildRoute(settings, LoginScreen());
      case register:
        return _buildRoute(settings, RegisterScreen());

      // STUDENT ROUTES
      case mainStudent:
        return _buildRoute(settings, MainStudentPage());
      case home:
        return _buildRoute(settings, HomeScreen());
      case courses:
        return _buildRoute(settings, CourseScreen());
      case profile:
        return _buildRoute(settings, ProfilePage());

      // TEACHER ROUTES
      case teacherDashboard:
        return _buildRoute(settings, TeacherDashboard());
      case addCourse:
        return _buildRoute(settings, AddCourseScreen());
      case analytics:
        return _buildRoute(settings, AnalyticsScreen());
      case quizManager:
        return _buildRoute(settings, quiz_manager.QuizManagerScreen());

      // ROUTES WITH ARGUMENTS

      case courseManagement:
        return _buildRoute(settings, CourseManagementScreen());

      case editCourse:
        final args = settings.arguments;
        if (args is Map<String, dynamic> && args['course'] != null) {
          return _buildRoute(
            settings,
            EditCourseScreen(course: args['course']),
          );
        }
        return _errorRoute(settings, 'Invalid arguments for EditCourse');
      case details:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return _buildRoute(
            settings,
            DetailsScreen(
              title: args['title'] ?? '',
              courseId: args['courseId'] ?? '',
              thumbnail: args['thumbnail'] ?? '',
              author: args['author'] ?? '',
              category: args['category'] ?? '',
              description: args['description'] ?? '',
            ),
          );
        }
        return _errorRoute(settings, 'Invalid arguments for DetailsScreen');

      case studentProgress:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return _buildRoute(
            settings,
            StudentProgressScreen(
              studentId: args['studentId'] ?? '',
              teacherId: args['teacherId'] ?? '',
            ),
          );
        }
        return _errorRoute(
            settings, 'Invalid arguments for StudentProgressScreen');

      case teacherChat:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return _buildRoute(
            settings,
            TeacherChatScreen(
              studentId: args['studentId'] ?? '',
              studentName: args['studentName'] ?? '',
            ),
          );
        }
        return _errorRoute(settings, 'Invalid arguments for TeacherChatScreen');

      default:
        return _errorRoute(settings, 'Route not found');
    }
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget page) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }

  static Route<dynamic> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Error loading ${settings.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(_),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Legacy route map for backward compatibility
final Map<String, WidgetBuilder> appRoutes = {
  RouteManager.welcome: (_) => WelcomePage(),
  RouteManager.login: (_) => LoginScreen(),
  RouteManager.register: (_) => RegisterScreen(),
  RouteManager.mainStudent: (_) => MainStudentPage(),
  RouteManager.home: (_) => HomeScreen(),
  RouteManager.courses: (_) => CourseScreen(),
  RouteManager.profile: (_) => ProfilePage(),
  RouteManager.teacherDashboard: (_) => TeacherDashboard(),
  RouteManager.addCourse: (_) => AddCourseScreen(),
  RouteManager.analytics: (_) => AnalyticsScreen(),
  RouteManager.quizManager: (_) => quiz_manager.QuizManagerScreen(),
  RouteManager.details: (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map<String, dynamic>) {
      return DetailsScreen(
        title: args['title'] ?? '',
        courseId: args['courseId'] ?? '',
        thumbnail: args['thumbnail'] ?? '',
        author: args['author'] ?? '',
        category: args['category'] ?? '',
        description: args['description'] ?? '',
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(child: Text('Invalid arguments for DetailsScreen')),
    );
  },
  RouteManager.studentProgress: (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map<String, dynamic>) {
      return StudentProgressScreen(
        studentId: args['studentId'] ?? '',
        teacherId: args['teacherId'] ?? '',
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(child: Text('Invalid arguments for StudentProgressScreen')),
    );
  },
  RouteManager.teacherChat: (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map<String, dynamic>) {
      return TeacherChatScreen(
        studentId: args['studentId'] ?? '',
        studentName: args['studentName'] ?? '',
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(child: Text('Invalid arguments for TeacherChatScreen')),
    );
  },
};
