import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_app/constants/color.dart';
import 'package:course_app/constants/size.dart';
import 'package:course_app/models/category.dart';
import 'package:course_app/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_screen.dart';
import 'package:course_app/widgets/circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'course_screen.dart';
import 'notifications_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: const [
              CustomAppBar(),
              Expanded(child: Body()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueLearningSection extends StatelessWidget {
  const _ContinueLearningSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('continueLearning')
        .doc('current');

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data();
        if (data == null) return const SizedBox.shrink();

        final courseId = data['courseId'] as String? ?? '';
        final courseName = data['courseName'] as String? ?? '';
        final lessonTitle = data['lessonTitle'] as String? ?? '';
        final lessonIndex = (data['lessonIndex'] as num?)?.toInt() ?? 0;

        if (courseId.isEmpty || courseName.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F2933),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Continue learning',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        courseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lessonTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final doc = await FirebaseFirestore.instance
                          .collection('courses')
                          .doc(courseId)
                          .get();
                      if (!doc.exists) return;

                      final course = Course.fromFirestore(doc);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsScreen(
                            title: course.name,
                            course: course,
                            initialLessonIndex: lessonIndex,
                          ),
                        ),
                      );
                    } catch (_) {
                      // en cas d'erreur, on ne fait rien
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PromoCardsRow extends StatelessWidget {
  const _PromoCardsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: const [
            _PromoCard(
              title: 'Build your future today',
              subtitle: 'Each chapter you study brings you closer to your dream job.',
            ),
            SizedBox(width: 12),
            _PromoCard(
              title: 'Keep learning, keep growing',
              subtitle: 'Small progress every day becomes big success in your studies.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PromoCard({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2933),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/laptop.jpg',
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const _ContinueLearningSection(),
          const SizedBox(height: 16),
          const _PromoCardsRow(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explore Categories",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
          
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // plus la valeur est petite, plus la carte est haute → évite l'overflow
              childAspectRatio: 0.75,
              crossAxisSpacing: 20,
              mainAxisSpacing: 24,
            ),
            itemBuilder: (context, index) {
              return CategoryCard(category: categoryList[index]);
            },
            itemCount: categoryList.length,
          ),
          const SizedBox(height: 20),
          const TopCourseSection(),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseScreen(
            initialCategory: _mapCategoryToFilter(category.name),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2933),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 4.0,
              spreadRadius: .05,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                category.thumbnail,
                height: kCategoryCardImageSize,
              ),
            ),
            const SizedBox(height: 10),

            /// ➤ TITLE
            Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),

            const SizedBox(height: 4),

            /// ➤ SUBTITLE
            Text(
              category.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.2,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class TopCourseSection extends StatelessWidget {
  const TopCourseSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Top Course",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseScreen(
                        initialCategory: 'all',
                      ),
                    ),
                  );
                },
                child: Text(
                  "See All",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0xFFFF4B8B)),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection('courses').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF4B8B)),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  'Erreur de chargement des cours',
                  style: TextStyle(color: Colors.white70),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              List<Course> courses =
                  docs.map((doc) => Course.fromFirestore(doc)).toList();

              if (courses.isEmpty) {
                return const Text(
                  'Aucun cours disponible',
                  style: TextStyle(color: Colors.white70),
                );
              }

              // On ne montre que quelques cours en "Top Course"
              courses = courses.take(4).toList();

              return Column(
                children: courses
                    .map((course) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TopCourseCard(course: course),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopCourseCard extends StatelessWidget {
  final Course course;

  const _TopCourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            title: course.name,
            course: course,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildCourseThumbnail(course),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final lowerName = course.name.toLowerCase();
                      final lowerCategory = course.category.toLowerCase();
                      String subtitle;
                      if (lowerName.contains('python')) {
                        subtitle =
                            'Apprenez les bases de Python avec des exercices pratiques.';
                      } else if (lowerName.contains('angular')) {
                        subtitle =
                            'Construisez des apps web modernes avec Angular.';
                      } else if (lowerName.contains('flutter') ||
                          lowerCategory == 'mobile') {
                        subtitle =
                            'Développez des applications mobiles avec Flutter.';
                      } else if (lowerName.contains('java')) {
                        subtitle =
                            'Solidez vos compétences backend en Java.';
                      } else if (lowerName.contains('vue')) {
                        subtitle =
                            'Frontend moderne et réactif avec Vue.js.';
                      } else {
                        subtitle =
                            'Un cours complet pour progresser sur cette matière.';
                      }

                      return Text(
                        subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCourseThumbnail(Course course) {
  final thumb = course.thumbnail;

  if (thumb.startsWith('http://') || thumb.startsWith('https://')) {
    return Image.network(
      thumb,
      height: 60,
      width: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox(height: 60, width: 80),
    );
  }

  if (thumb.isEmpty) {
    return const SizedBox(height: 60, width: 80);
  }

  return Image.asset(
    thumb,
    height: 60,
    width: 80,
    fit: BoxFit.cover,
  );
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 14),
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: Color(0xFFFF4B8B),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, Student",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Future programmer",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              CircleButton(
                icon: Icons.notifications,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Converts category name → backend/front/mobile/uiux
String _mapCategoryToFilter(String name) {
  switch (name.toLowerCase()) {
    case 'backend engineer':
      return 'backend';
    case 'frontend engineer':
      return 'frontend';
    case 'mobile engineer':
      return 'mobile';
    case 'ui/ux designer':
      return 'uiux';
    default:
      return 'all';
  }
}
