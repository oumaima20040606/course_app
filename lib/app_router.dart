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

final Map<String, WidgetBuilder> appRoutes = {
  "/welcome": (_) => WelcomePage(),
  "/login": (_) => LoginScreen(),
  "/register": (_) => RegisterScreen(),

  "/main": (_) => MainStudentPage(),
  "/home": (_) => HomeScreen(),
  "/courses": (_) => CourseScreen(),

 "/details": (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map;
  return DetailsScreen(
    title: args["title"],
  );
},


  "/profile": (_) => ProfilePage(),
};

