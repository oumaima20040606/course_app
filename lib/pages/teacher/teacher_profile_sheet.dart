import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/constants/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherProfileSheet extends StatefulWidget {
  final String teacherId;

  TeacherProfileSheet({required this.teacherId});

  @override
  _TeacherProfileSheetState createState() => _TeacherProfileSheetState();
}

class _TeacherProfileSheetState extends State<TeacherProfileSheet> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _teacherData;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      final doc =
          await _firestore.collection('teachers').doc(widget.teacherId).get();

      if (doc.exists) {
        setState(() {
          _teacherData = doc.data();
        });
      }
    } catch (e) {
      print('Error loading teacher data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 40,
              color: kPrimaryColor,
            ),
          ),
          SizedBox(height: 15),
          Text(
            user?.displayName ?? 'Teacher',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?.email ?? '',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          Divider(),
          _buildProfileOption(Icons.edit, 'Edit Profile'),
          _buildProfileOption(Icons.settings, 'Settings'),
          _buildProfileOption(Icons.notifications, 'Notifications'),
          _buildProfileOption(Icons.help, 'Help & Support'),
          _buildProfileOption(Icons.logout, 'Logout', isLogout: true),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : kPrimaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : null,
        ),
      ),
      trailing:
          Icon(Icons.chevron_right, color: isLogout ? Colors.red : Colors.grey),
      onTap: () {
        if (isLogout) {
          _logout();
        } else {
          _handleProfileOption(title);
        }
      },
    );
  }

  void _handleProfileOption(String option) {
    switch (option) {
      case 'Edit Profile':
        // Navigate to edit profile
        break;
      case 'Settings':
        // Navigate to settings
        break;
      case 'Notifications':
        // Navigate to notifications
        break;
      case 'Help & Support':
        // Navigate to help
        break;
    }
  }

  void _logout() async {
    try {
      await _auth.signOut();
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
