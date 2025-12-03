import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StudentProgressScreen extends StatefulWidget {
  final String studentId;
  final String teacherId;

  StudentProgressScreen({required this.studentId, required this.teacherId}) {
    assert(studentId.isNotEmpty, 'studentId must not be empty');
    assert(teacherId.isNotEmpty, 'teacherId must not be empty');
  }

  @override
  _StudentProgressScreenState createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _progressData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStudentProgress();
  }

  Future<void> _fetchStudentProgress() async {
    if (widget.studentId.isEmpty || widget.teacherId.isEmpty) {
      setState(() {
        _errorMessage = 'Invalid student or teacher ID';
        _isLoading = false;
      });
      return;
    }

    try {
      // Get student info
      final studentDoc = await _firestore
          .collection('users')
          .doc(widget.studentId)
          .get(GetOptions(source: Source.serverAndCache));

      if (!studentDoc.exists) {
        throw Exception('Student not found with ID: ${widget.studentId}');
      }

      final studentInfo = studentDoc.data() as Map<String, dynamic>;

      // Get teacher's courses
      final coursesSnapshot = await _firestore
          .collection('courses')
          .where('authorId', isEqualTo: widget.teacherId)
          .get(const GetOptions(source: Source.serverAndCache));

      final List<Map<String, dynamic>> coursesProgress = [];

      // For each course, check if student is enrolled
      for (final courseDoc in coursesSnapshot.docs) {
        final courseId = courseDoc.id;
        final courseData = courseDoc.data();

        // Check enrollment - fix the query to use correct field names
        final enrollmentQuery = await _firestore
            .collection('enrollments')
            .where('courseId', isEqualTo: courseId)
            .where('studentId', isEqualTo: widget.studentId)
            .limit(1)
            .get(const GetOptions(source: Source.serverAndCache));

        if (enrollmentQuery.docs.isNotEmpty) {
          final enrollmentDoc = enrollmentQuery.docs.first;
          final enrollmentData = enrollmentDoc.data();

          // Get progress for this course
          final progressDoc = await _firestore
              .collection('progress')
              .where('studentId', isEqualTo: widget.studentId)
              .where('courseId', isEqualTo: courseId)
              .where('teacherId', isEqualTo: widget.teacherId)
              .limit(1)
              .get(const GetOptions(source: Source.serverAndCache));

          double progress = 0.0;
          Timestamp? lastAccessed;
          List<String> completedLessons = [];

          if (progressDoc.docs.isNotEmpty) {
            final progressData = progressDoc.docs.first.data();
            progress = (progressData['progress'] ?? 0.0).toDouble();
            lastAccessed = progressData['lastAccessed'] as Timestamp?;
            completedLessons =
                List<String>.from(progressData['completedLessons'] ?? []);
          }

          coursesProgress.add({
            'courseId': courseId,
            'courseTitle': courseData['name'] ?? 'Untitled Course',
            'progress': progress,
            'enrollmentDate': enrollmentData['enrolledAt'] ?? Timestamp.now(),
            'lastAccessed': lastAccessed,
            'completedLessons': completedLessons,
          });
        }
      }

      setState(() {
        _progressData = {
          'studentInfo': studentInfo,
          'coursesProgress': coursesProgress,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching student progress: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Progress'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchStudentProgress,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error loading progress',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchStudentProgress,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _progressData == null
                  ? Center(
                      child: Text('No progress data available'),
                    )
                  : _buildProgressContent(),
    );
  }

  Widget _buildProgressContent() {
    final studentInfo = _progressData!['studentInfo'] as Map<String, dynamic>;
    final coursesProgress =
        _progressData!['coursesProgress'] as List<Map<String, dynamic>>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      (studentInfo['name'] ??
                              studentInfo['displayName'] ??
                              'S')[0]
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentInfo['name'] ??
                              studentInfo['displayName'] ??
                              'Unknown Student',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          studentInfo['email'] ?? 'No email',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${coursesProgress.length} enrolled courses',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Progress Header
          if (coursesProgress.isNotEmpty) ...[
            Text(
              'Course Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Overview of student progress across all courses',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            // Courses List
            ...coursesProgress.map((course) {
              final progress = course['progress'] ?? 0.0;
              final lastAccessed = course['lastAccessed'] as Timestamp?;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title and Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              course['courseTitle'] ?? 'Untitled Course',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: progress >= 1.0
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            backgroundColor: progress >= 1.0
                                ? Colors.green
                                : progress >= 0.5
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0
                                ? Colors.green
                                : progress >= 0.5
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Additional Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enrolled: ${_formatDate(course['enrollmentDate'] as Timestamp?)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Last activity: ${_formatDate(lastAccessed)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Completed lessons
                      if ((course['completedLessons'] as List).isNotEmpty)
                        Text(
                          'Completed ${course['completedLessons'].length} lessons',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ] else
            Container(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.school, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No courses enrolled',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This student hasn\'t enrolled in any of your courses yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Never';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
