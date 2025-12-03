import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:course_app/pages/teacher/student_progress.dart';
import 'package:course_app/pages/teacher/teacher_chat.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Students'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading students',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No students enrolled yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Students will appear here once they enroll in your courses',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      student['name']?[0]?.toUpperCase() ?? 'S',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  title: Text(
                    student['name'] ?? 'Unknown Student',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['email'] ?? 'No email',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${student['enrolledCourses']} course${student['enrolledCourses'] != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Avg progress: ${student['averageProgress']}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.message, color: Colors.blue),
                        onPressed: () => _chatWithStudent(student),
                      ),
                      IconButton(
                        icon: Icon(Icons.assessment, color: Colors.green),
                        onPressed: () => _viewStudentProgress(student),
                      ),
                    ],
                  ),
                  onTap: () => _viewStudentProgress(student),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    try {
      final teacherId = _auth.currentUser!.uid;

      // Get all enrollments for this teacher
      final enrollmentsSnapshot = await _firestore
          .collection('enrollments')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      // Group enrollments by student
      Map<String, List<Map<String, dynamic>>> studentEnrollments = {};

      for (final doc in enrollmentsSnapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'] as String?;

        if (studentId != null && studentId.isNotEmpty) {
          if (!studentEnrollments.containsKey(studentId)) {
            studentEnrollments[studentId] = [];
          }
          studentEnrollments[studentId]!.add(data);
        }
      }

      // Build student list with aggregated data
      List<Map<String, dynamic>> students = [];

      for (final entry in studentEnrollments.entries) {
        final studentId = entry.key;
        final enrollments = entry.value;

        // Get student info
        final studentDoc =
            await _firestore.collection('users').doc(studentId).get();

        if (studentDoc.exists) {
          final studentData = studentDoc.data() as Map<String, dynamic>;

          // Calculate average progress
          double totalProgress = 0;
          for (final enrollment in enrollments) {
            totalProgress += (enrollment['progress'] ?? 0.0) * 100;
          }
          final averageProgress = enrollments.isNotEmpty
              ? (totalProgress / enrollments.length).round()
              : 0;

          students.add({
            'id': studentId,
            'name': studentData['displayName'] ??
                studentData['name'] ??
                'Unknown Student',
            'email': studentData['email'] ?? '',
            'enrolledCourses': enrollments.length,
            'averageProgress': averageProgress,
            'enrollments': enrollments,
          });
        }
      }

      // Sort by name
      students
          .sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      return students;
    } catch (e) {
      print('Error fetching students: $e');
      rethrow;
    }
  }

  void _chatWithStudent(Map<String, dynamic> student) {
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

  void _viewStudentProgress(Map<String, dynamic> student) {
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
