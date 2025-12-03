// pages/teacher/course_management.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/models/course.dart';
import 'package:course_app/app_router.dart';
import 'package:course_app/pages/teacher/edit_course_screen.dart';
import 'package:course_app/pages/teacher/add_course.dart';
import 'package:course_app/pages/teacher/analytics_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  @override
  _CourseManagementScreenState createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
        backgroundColor: Color(0xFF1F2933),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnalyticsScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCourseScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildCourseList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCourseScreen()),
        ),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Draft', 'Archived'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: _selectedFilter == filter,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.grey[800],
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: _selectedFilter == filter
                      ? Colors.white
                      : Colors.grey[300],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No courses found',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first course to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final courses = snapshot.data!.docs.map((doc) {
          return Course.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return _buildCourseCard(course);
          },
        );
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFF1F2933),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(course.thumbnail),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          course.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              course.category,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${course.enrolledCount} enrolled',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(width: 16),
                Icon(Icons.star, size: 14, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  '${course.rating.toStringAsFixed(1)}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'analytics',
              child: Row(
                children: [
                  Icon(Icons.analytics, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Analytics'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCourseScreen(course: course),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteDialog(course);
            } else if (value == 'analytics') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnalyticsScreen()),
              );
            }
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1F2933),
        title: Text(
          'Delete Course',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${course.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('courses').doc(course.id).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Course deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting course: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
