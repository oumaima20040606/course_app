import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/pages/teacher/teacher_profile_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:course_app/models/course.dart';
import 'package:course_app/pages/teacher/add_course.dart';
import 'package:course_app/pages/teacher/student_progress.dart';
import 'package:course_app/pages/teacher/teacher_chat.dart';
import 'package:course_app/pages/teacher/quiz_manager.dart';
import 'package:course_app/pages/teacher/analytics_screen.dart';
import 'package:course_app/pages/teacher/course_management.dart';
import 'package:course_app/pages/teacher/student_list_screen.dart';
import 'package:course_app/constants/color.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();

  int _coursesCount = 0;
  int _studentsCount = 0;
  int _totalRevenue = 0;
  double _averageRating = 0.0;
  int _currentPageIndex = 0;

  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _topStudents = [];
  List<Course> _recentCourses = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([
      _loadStats(),
      _loadRecentActivities(),
      _loadTopStudents(),
      _loadRecentCourses(),
    ]);
  }

  Future<void> _loadStats() async {
    final teacherId = _auth.currentUser!.uid;

    // Courses count
    final coursesSnapshot = await _firestore
        .collection('courses')
        .where('authorId', isEqualTo: teacherId)
        .get();

    // Students count (unique students across all courses)
    final enrollments = await _firestore
        .collection('enrollments')
        .where('teacherId', isEqualTo: teacherId)
        .get();

    Set<String> uniqueStudents = {};
    for (var doc in enrollments.docs) {
      if (doc['studentId'] != null) {
        uniqueStudents.add(doc['studentId']);
      }
    }

    // Calculate total revenue
    double revenue = 0;
    for (var courseDoc in coursesSnapshot.docs) {
      final courseData = courseDoc.data() as Map<String, dynamic>;
      final price = (courseData['price'] ?? 0).toDouble();
      final enrolledCount = (courseData['enrolledCount'] ?? 0).toInt();
      revenue += price * enrolledCount;
    }

    // Calculate average rating
    double totalRating = 0;
    int ratedCourses = 0;
    for (var courseDoc in coursesSnapshot.docs) {
      final courseData = courseDoc.data() as Map<String, dynamic>;
      final rating = (courseData['rating'] ?? 0).toDouble();
      if (rating > 0) {
        totalRating += rating;
        ratedCourses++;
      }
    }

    setState(() {
      _coursesCount = coursesSnapshot.docs.length;
      _studentsCount = uniqueStudents.length;
      _totalRevenue = revenue.toInt();
      _averageRating = ratedCourses > 0 ? totalRating / ratedCourses : 0.0;
    });
  }

  Future<void> _loadRecentActivities() async {
    final teacherId = _auth.currentUser!.uid;

    try {
      // Get recent enrollments
      final enrollments = await _firestore
          .collection('enrollments')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('enrolledAt', descending: true)
          .limit(5)
          .get();

      // Get recent course completions
      final completions = await _firestore
          .collection('progress')
          .where('teacherId', isEqualTo: teacherId)
          .where('completed', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> activities = [];

      // Add enrollment activities
      for (var doc in enrollments.docs) {
        final data = doc.data();
        activities.add({
          'type': 'enrollment',
          'message':
              '${data['studentName'] ?? 'A student'} enrolled in ${data['courseName'] ?? 'your course'}',
          'time': _formatTimestamp(data['enrolledAt']),
          'icon': Icons.person_add,
          'color': Colors.green,
        });
      }

      // Add completion activities
      for (var doc in completions.docs) {
        final data = doc.data();
        activities.add({
          'type': 'completion',
          'message':
              '${data['studentName'] ?? 'A student'} completed ${data['courseName'] ?? 'a course'}',
          'time': _formatTimestamp(data['completedAt']),
          'icon': Icons.check_circle,
          'color': Colors.blue,
        });
      }

      // Sort by time and limit to 4
      activities.sort((a, b) => b['time'].compareTo(a['time']));
      activities = activities.take(4).toList();

      setState(() {
        _recentActivities = activities;
      });
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    DateTime time;
    if (timestamp is Timestamp) {
      time = timestamp.toDate();
    } else if (timestamp is DateTime) {
      time = timestamp;
    } else {
      return 'Recently';
    }

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _loadTopStudents() async {
    final teacherId = _auth.currentUser!.uid;

    try {
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('progress', descending: true)
          .limit(3)
          .get();

      List<Map<String, dynamic>> topStudents = [];

      for (var doc in progressSnapshot.docs) {
        final data = doc.data();

        // Get student info
        final studentDoc =
            await _firestore.collection('users').doc(data['studentId']).get();

        final studentData = studentDoc.data();
        final name = studentData?['displayName'] ??
            studentData?['email']?.split('@').first ??
            'Student';
        final email = studentData?['email'] ?? '';
        final avatar = name.isNotEmpty ? name[0].toUpperCase() : 'S';

        topStudents.add({
          'id': data['studentId'],
          'name': name,
          'email': email,
          'progress': (data['progress'] ?? 0).toInt(),
          'courses': 1, // You can expand this to count courses
          'avatar': avatar,
        });
      }

      setState(() {
        _topStudents = topStudents;
      });
    } catch (e) {
      print('Error loading top students: $e');
    }
  }

  Future<void> _loadRecentCourses() async {
    final teacherId = _auth.currentUser!.uid;

    try {
      final coursesSnapshot = await _firestore
          .collection('courses')
          .where('authorId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      List<Course> courses = [];
      for (var doc in coursesSnapshot.docs) {
        courses.add(Course.fromFirestore(doc));
      }

      setState(() {
        _recentCourses = courses;
      });
    } catch (e) {
      print('Error loading recent courses: $e');
    }
  }

  Widget _buildDashboardHeader() {
    return Container(
      padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teacher Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.school,
                  color: Color(0xFF667eea),
                  size: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {
        'icon': Icons.library_books,
        'value': _coursesCount.toString(),
        'label': 'Courses',
        'color': Colors.blue,
      },
      {
        'icon': Icons.people,
        'value': _studentsCount.toString(),
        'label': 'Students',
        'color': Colors.green,
      },
      {
        'icon': Icons.attach_money,
        'value': '\$$_totalRevenue',
        'label': 'Revenue',
        'color': Colors.amber,
      },
      {
        'icon': Icons.star,
        'value': _averageRating.toStringAsFixed(1),
        'label': 'Rating',
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(height: 5),
              Text(
                stat['value'] as String,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                stat['label'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.add,
        'label': 'Add Course',
        'color': kPrimaryColor,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddCourseScreen()),
            ),
      },
      {
        'icon': Icons.library_books,
        'label': 'Manage Courses',
        'color': Colors.blue,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CourseManagementScreen()),
            ),
      },
      {
        'icon': Icons.analytics,
        'label': 'Analytics',
        'color': Colors.green,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnalyticsScreen()),
            ),
      },
      {
        'icon': Icons.quiz,
        'label': 'Quiz Manager',
        'color': Colors.orange,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuizManagerScreen()),
            ),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: action['onTap'] as VoidCallback,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCourses() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CourseManagementScreen()),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (_recentCourses.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(Icons.library_books, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No courses yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._recentCourses.map((course) {
              return Card(
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(course.thumbnail),
                  ),
                  title: Text(course.name),
                  subtitle: Text(
                    '${course.enrolledCount} students • ${course.rating}★',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.analytics, size: 20),
                            SizedBox(width: 8),
                            Text('Analytics'),
                          ],
                        ),
                        value: 'analytics',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Navigate to edit course
                      } else if (value == 'analytics') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AnalyticsScreen()),
                        );
                      }
                    },
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () => _viewAllActivities(),
                child: Text(
                  'View All',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ..._recentActivities.map((activity) {
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activity['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    activity['icon'],
                    color: activity['color'],
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['message'],
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  activity['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => _handleActivityTap(activity),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopStudents() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Students',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10),
          ..._topStudents.map((student) {
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kPrimaryColor.withOpacity(0.2),
                  child: Text(
                    student['avatar'],
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  student['name'],
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student['email']),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Progress: ${student['progress']}%',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Courses: ${student['courses']}',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.message, size: 20),
                      onPressed: () => _chatWithStudent(student),
                    ),
                    IconButton(
                      icon: Icon(Icons.assessment, size: 20),
                      onPressed: () => _viewStudentProgress(student),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentPageIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) => _handleBottomNavTap(index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Students',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CourseManagementScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentListScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnalyticsScreen()),
        );
        break;
      case 4:
        _showTeacherProfile();
        break;
    }
  }

  void _handleActivityTap(Map<String, dynamic> activity) {
    if (activity['type'] == 'enrollment') {
      // Navigate to student details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening enrollment details...')),
      );
    } else if (activity['type'] == 'completion') {
      // Navigate to course analytics
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AnalyticsScreen()),
      );
    }
  }

  void _viewAllActivities() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Activities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = _recentActivities[index];
                  return ListTile(
                    leading: Icon(activity['icon'], color: activity['color']),
                    title: Text(activity['message']),
                    subtitle: Text(activity['time']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _chatWithStudent(Map<String, dynamic> student) {
    if (student['id'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeacherChatScreen(
            studentId: student['id'],
            studentName: student['name'],
          ),
        ),
      );
    }
  }

  void _viewStudentProgress(Map<String, dynamic> student) {
    if (student['id'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentProgressScreen(
            studentId: student['id'],
            teacherId: _auth.currentUser!.uid,
          ),
        ),
      );
    }
  }

  void _showTeacherProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TeacherProfileSheet(
        teacherId: _auth.currentUser!.uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboardData();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDashboardHeader(),
              _buildQuickActions(),
              _buildRecentCourses(),
              _buildRecentActivities(),
              _buildTopStudents(),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddCourseScreen()),
        ),
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
