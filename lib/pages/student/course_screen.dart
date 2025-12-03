import 'package:course_app/constants/color.dart';
import 'package:course_app/constants/icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/course.dart';
import 'details_screen.dart';

class CourseScreen extends StatefulWidget {
  final String initialCategory;

  const CourseScreen({Key? key, this.initialCategory = 'all'})
      : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

extension on CourseContainer {
  Widget _buildThumbnail() {
    final thumb = course.thumbnail;
    if (thumb.startsWith('http://') || thumb.startsWith('https://')) {
      return Image.network(
        thumb,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(height: 60),
      );
    }

    if (thumb.isEmpty) {
      return const SizedBox(height: 60);
    }

    return Image.asset(
      thumb,
      height: 60,
      fit: BoxFit.cover,
    );
  }
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = const [
    {'label': 'All', 'value': 'all'},
    {'label': 'Backend Engineer', 'value': 'backend'},
    {'label': 'Frontend Engineer', 'value': 'frontend'},
    {'label': 'Mobile Engineer', 'value': 'mobile'},
    {'label': 'UI/UX Designer', 'value': 'uiux'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Stack(
                    children: [
                      Align(
                        child: Text(
                          'Course Learning',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: CustomIconButton(
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          height: 35,
                          width: 35,
                          color: const Color(0xFF1F2933),
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/main",
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une matière...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1F2933),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Color(0xFFFF4B8B), width: 1),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            cat['label'] ?? '',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFF4B8B),
                          backgroundColor: const Color(0xFF1F2933),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat['value'] ?? 'all';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFF4B8B)),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Erreur de chargement des cours',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      List<Course> courses =
                          docs.map((doc) => Course.fromFirestore(doc)).toList();

                      if (_searchQuery.isNotEmpty) {
                        courses = courses
                            .where((c) =>
                                c.name.toLowerCase().contains(_searchQuery))
                            .toList();
                      }

                      if (_selectedCategory != 'all') {
                        courses = courses
                            .where((c) =>
                                c.category.toLowerCase().trim() ==
                                _selectedCategory)
                            .toList();
                      }

                      if (courses.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aucun cours trouvé',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        separatorBuilder: (_, __) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemBuilder: (_, int index) {
                          return CourseContainer(
                            course: courses[index],
                          );
                        },
                        itemCount: courses.length,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CourseContainer extends StatelessWidget {
  final Course course;
  const CourseContainer({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            title: course.name,
            courseId: course.id, // Ajoutez ceci
            thumbnail: course.thumbnail,
            author: course.author,
            category: course.category,
            description: course.description,
            course: course,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildThumbnail(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Builder(
                    builder: (context) {
                      final lowerName = course.name.toLowerCase();
                      final lowerCategory = course.category.toLowerCase();
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
                            ?.copyWith(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: course.completedPercentage,
                    backgroundColor: Colors.black12,
                    color: kPrimaryColor,
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
