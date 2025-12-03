import 'package:flutter/material.dart';
import 'package:course_app/constants/color.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111827),
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        backgroundColor: Color(0xFF1F2933),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(),
            SizedBox(height: 25),
            _buildEngagementChart(),
            SizedBox(height: 25),
            _buildCoursePerformance(),
            SizedBox(height: 25),
            _buildStudentDemographics(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    final stats = [
      {
        'title': 'Total Views',
        'value': '1,245',
        'change': '+12%',
        'color': Colors.blue
      },
      {
        'title': 'Completion Rate',
        'value': '78%',
        'change': '+5%',
        'color': Colors.green
      },
      {
        'title': 'Avg. Rating',
        'value': '4.8',
        'change': '+0.2',
        'color': Colors.amber
      },
      {
        'title': 'Revenue',
        'value': '\$2,450',
        'change': '+18%',
        'color': Colors.purple
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF1F2933),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stat['color'] != null
                          ? Color.lerp(
                              Colors.transparent, stat['color'] as Color?, 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.trending_up,
                        color: stat['color'] as Color?, size: 20),
                  ),
                  Text(
                    stat['change'] as String,
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    stat['title'] as String,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEngagementChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1F2933),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Engagement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Engagement Chart',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Coming Soon',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePerformance() {
    final courses = [
      {'name': 'Flutter Development', 'students': 45, 'progress': 85},
      {'name': 'Python Basics', 'students': 32, 'progress': 78},
      {'name': 'Java Programming', 'students': 28, 'progress': 92},
      {'name': 'Web Development', 'students': 21, 'progress': 65},
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1F2933),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          ...courses.map((course) {
            return Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        course['name'] as String,
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${course['students']} students',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (course['progress'] as int) / 100,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    minHeight: 6,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${course['progress']}% completion',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStudentDemographics() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1F2933),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Demographics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDemographicItem('Age 18-25', '42%', Colors.blue),
              _buildDemographicItem('Age 26-35', '35%', Colors.green),
              _buildDemographicItem('Age 36+', '23%', Colors.orange),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDemographicItem('Beginner', '45%', Colors.purple),
              _buildDemographicItem('Intermediate', '38%', Colors.red),
              _buildDemographicItem('Advanced', '17%', Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
