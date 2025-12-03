import 'package:flutter/material.dart';
import 'package:course_app/constants/color.dart';

class QuizManagerScreen extends StatefulWidget {
  @override
  _QuizManagerScreenState createState() => _QuizManagerScreenState();
}

class _QuizManagerScreenState extends State<QuizManagerScreen> {
  final List<Map<String, dynamic>> _quizzes = [
    {
      'title': 'Flutter Basics Quiz',
      'course': 'Flutter Development',
      'questions': 10,
      'studentsTaken': 45,
      'avgScore': 85,
      'status': 'active',
    },
    {
      'title': 'Python Fundamentals',
      'course': 'Python Basics',
      'questions': 15,
      'studentsTaken': 32,
      'avgScore': 78,
      'status': 'active',
    },
    {
      'title': 'Java OOP Quiz',
      'course': 'Java Programming',
      'questions': 12,
      'studentsTaken': 28,
      'avgScore': 92,
      'status': 'active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111827),
      appBar: AppBar(
        title: Text('Quiz Manager'),
        backgroundColor: Color(0xFF1F2933),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNewQuiz,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildQuizStats(),
          SizedBox(height: 25),
          _buildQuizzesList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewQuiz,
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuizStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Total Quizzes', _quizzes.length.toString(), Icons.quiz),
        _buildStatItem('Avg. Score', '85%', Icons.score),
        _buildStatItem('Total Attempts', '105', Icons.people),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: kPrimaryColor, size: 24),
        ),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuizzesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Quizzes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        ..._quizzes.map((quiz) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Color(0xFF1F2933),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.quiz, color: kPrimaryColor),
              ),
              title: Text(
                quiz['title'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    quiz['course'],
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.question_answer, size: 14, color: Colors.grey),
                      SizedBox(width: 5),
                      Text('${quiz['questions']} questions',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(width: 15),
                      Icon(Icons.people, size: 14, color: Colors.grey),
                      SizedBox(width: 5),
                      Text('${quiz['studentsTaken']} students',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    label: Text('${quiz['avgScore']}%'),
                    backgroundColor: quiz['avgScore'] >= 80
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color:
                          quiz['avgScore'] >= 80 ? Colors.green : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              onTap: () => _viewQuizDetails(quiz),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _createNewQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1F2933),
        title: Text('Create New Quiz', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Quiz Title',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Course',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Number of Questions',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Quiz created successfully!'),
                  backgroundColor: kPrimaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _viewQuizDetails(Map<String, dynamic> quiz) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1F2933),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              quiz['title'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              quiz['course'],
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuizStat('Questions', quiz['questions'].toString()),
                _buildQuizStat('Students', quiz['studentsTaken'].toString()),
                _buildQuizStat('Avg. Score', '${quiz['avgScore']}%'),
              ],
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: kPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Edit Quiz',
                        style: TextStyle(color: kPrimaryColor)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('View Results'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
