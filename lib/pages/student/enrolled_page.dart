import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/course.dart';
import 'details_screen.dart';

class EnrolledPage extends StatelessWidget {
  EnrolledPage({Key? key}) : super(key: key);

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF111827),
        body: Center(
          child: Text(
            'You must be logged in to see enrolled courses.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final enrolledStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('enrolledCourses')
        .snapshots();

    final savedResourcesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savedResources')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4B8B),
        elevation: 0,
        title: const Text(
          'Enrolled Courses',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: enrolledStream,
        builder: (context, enrolledSnapshot) {
          final enrolledState = enrolledSnapshot.connectionState;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: savedResourcesStream,
            builder: (context, savedSnapshot) {
              if (enrolledState == ConnectionState.waiting ||
                  savedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF4B8B)),
                );
              }

              if (enrolledSnapshot.hasError || savedSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error loading enrolled data',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final enrolledDocs = enrolledSnapshot.data?.docs ?? [];
              final savedDocs = savedSnapshot.data?.docs ?? [];

              final courses = enrolledDocs
                  .map((d) => Course.fromFirestore(d))
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Enrolled Courses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (courses.isEmpty)
                      const Text(
                        'No enrolled courses yet',
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: courses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = courses[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsScreen(
                                    title: c.name,
                                    course: c,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2933),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Builder(
                                    builder: (context) {
                                      final lowerName = c.name.toLowerCase();
                                      final lowerCategory =
                                          c.category.toLowerCase();
                                      String subtitle;
                                      if (lowerName.contains('python')) {
                                        subtitle =
                                            'Apprenez les bases de Python étape par étape.';
                                      } else if (lowerName.contains('angular')) {
                                        subtitle =
                                            'Construisez des applications web modernes avec Angular.';
                                      } else if (lowerName.contains('flutter') ||
                                          lowerCategory == 'mobile') {
                                        subtitle =
                                            'Créez des applications mobiles modernes avec Flutter.';
                                      } else if (lowerName.contains('java')) {
                                        subtitle =
                                            'Renforcez vos bases en Java pour le backend.';
                                      } else if (lowerName.contains('vue')) {
                                        subtitle =
                                            'Découvrez le développement frontend avec Vue.js.';
                                      } else {
                                        subtitle =
                                            'Progressez rapidement sur cette matière avec ce cours.';
                                      }

                                      return Text(
                                        subtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white70),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                  if (c.category.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Category: ${c.category}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white54),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: c.completedPercentage,
                                    backgroundColor: Colors.black26,
                                    color: const Color(0xFFFF4B8B),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(c.completedPercentage * 100).toStringAsFixed(0)}% completed',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('enrolledCourses')
                                            .doc(c.id)
                                            .delete();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    const Text(
                      'Saved resources',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (savedDocs.isEmpty)
                      const Text(
                        'No saved videos or documents yet',
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: savedDocs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final d = savedDocs[index].data();
                          final courseId = (d['courseId'] ?? '') as String;
                          final courseName = (d['courseName'] ?? '') as String;
                          final title = (d['title'] ?? '') as String;
                          final type = (d['type'] ?? '') as String;
                          final url = (d['url'] ?? '') as String;

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              if (type == 'pdf') {
                                if (url.isEmpty) return;
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                                return;
                              }

                              if (type == 'video') {
                                if (courseId.isEmpty) return;
                                try {
                                  final doc = await FirebaseFirestore.instance
                                      .collection('courses')
                                      .doc(courseId)
                                      .get();
                                  if (!doc.exists) return;

                                  final course = Course.fromFirestore(doc);
                                  int initialIndex = 0;
                                  if (url.isNotEmpty) {
                                    final idx = course.lessons
                                        .indexWhere((l) => l['url'] == url);
                                    if (idx != -1) initialIndex = idx;
                                  } else if (title.isNotEmpty) {
                                    final idx = course.lessons.indexWhere(
                                        (l) => (l['title'] ?? '') == title);
                                    if (idx != -1) initialIndex = idx;
                                  }

                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailsScreen(
                                        title: course.name,
                                        course: course,
                                        initialLessonIndex: initialIndex,
                                      ),
                                    ),
                                  );
                                } catch (_) {
                                  // ignore errors
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2933),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courseName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white70),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    type.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.white54),
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
            },
          );
        },
      ),
    );
  }
}
