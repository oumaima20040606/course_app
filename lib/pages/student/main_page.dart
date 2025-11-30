import 'package:flutter/material.dart';
import 'package:course_app/constants/color.dart';
import 'home_screen.dart';
import 'course_screen.dart';
import 'profile_page.dart';
import 'enrolled_page.dart';
import 'notifications_page.dart';

class MainStudentPage extends StatefulWidget {
  @override
  _MainStudentPageState createState() => _MainStudentPageState();
}

class _MainStudentPageState extends State<MainStudentPage> {
  int index = 0;

  final pages = [
    HomeScreen(),
    CourseScreen(),
    EnrolledPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF111827),
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.white70,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: "Enrolled"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
