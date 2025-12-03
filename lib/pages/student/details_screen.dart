import 'package:course_app/constants/color.dart';
import 'package:course_app/constants/icons.dart';
import 'package:course_app/models/course.dart';
import 'package:course_app/models/lesson.dart';
import 'package:course_app/pages/student/enrolled_page.dart';
import 'package:course_app/pages/student/quiz_page.dart';
import 'package:course_app/pages/student/pdf_summary_page.dart';
import 'package:course_app/widgets/custom_video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:course_app/widgets/lesson_card.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final String courseId;
  final String thumbnail;
  final String author;
  final String category;
  final String description;
  final Course? course;
  final int initialLessonIndex;

  const DetailsScreen({
    Key? key,
    required this.title,
    required this.courseId,
    this.thumbnail = '',
    this.author = '',
    this.category = '',
    this.description = '',
    this.course,
    this.initialLessonIndex = 0,
  }) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _selectedTag = 0;
  int _currentLessonIndex = 0;

  Set<int> _completedLessonIndices = {};
  double _progress = 0.0;
  double? _quizScore;

  Course? _fullCourse;

  Course? get _effectiveCourse => _fullCourse ?? widget.course;

  List<Map<String, String>> get _lessons =>
      _effectiveCourse?.lessons ?? widget.course?.lessons ?? const [];

  @override
  void initState() {
    super.initState();
    _currentLessonIndex = widget.initialLessonIndex.clamp(0, 1000);
    _loadFullCourseIfNeeded();
    _loadProgress();
  }

  Future<void> _saveContinueLearning(int lessonIndex) async {
    final course = _effectiveCourse;
    final user = FirebaseAuth.instance.currentUser;
    if (course == null || user == null) return;
    if (_lessons.isEmpty || lessonIndex < 0 || lessonIndex >= _lessons.length) {
      return;
    }

    final lesson = _lessons[lessonIndex];
    final title = lesson['title'] ?? 'Lesson ${lessonIndex + 1}';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('continueLearning')
        .doc('current')
        .set({
      'courseId': course.id,
      'courseName': course.name,
      'category': course.category,
      'lessonIndex': lessonIndex,
      'lessonTitle': title,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _loadFullCourseIfNeeded() async {
    // Si nous avons déjà un cours complet, ne rien faire
    if (widget.course != null && widget.course!.lessons.isNotEmpty) return;

    // Si nous avons un courseId, charger le cours complet
    if (widget.courseId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .get();
        if (!doc.exists) return;

        final loaded = Course.fromFirestore(doc);
        if (!mounted) return;
        setState(() {
          _fullCourse = loaded;
        });
      } catch (e) {}
    }
  }

  Future<void> _loadProgress() async {
    final course = _effectiveCourse;
    final user = FirebaseAuth.instance.currentUser;
    if (course == null || user == null || _lessons.isEmpty) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('enrolledCourses')
        .doc(course.id);

    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data();
    if (data == null) return;

    final rawCompleted = (data['completedLessonIndices'] as List?) ?? const [];
    final indices = rawCompleted.whereType<int>().toSet();
    final quizScoreRaw = data['quizScore'];
    final double? quizScore =
        quizScoreRaw is num ? quizScoreRaw.toDouble() : null;

    if (!mounted) return;
    setState(() {
      _completedLessonIndices = indices;
      _recomputeProgress();
      _quizScore = quizScore;
    });
  }

  void _recomputeProgress() {
    if (_lessons.isEmpty) {
      _progress = 0.0;
      return;
    }
    _progress = _completedLessonIndices.length / _lessons.length;
  }

  Future<void> _toggleLessonCompleted(int index, bool completed) async {
    final course = _effectiveCourse ?? widget.course;
    final user = FirebaseAuth.instance.currentUser;
    if (course == null || user == null || _lessons.isEmpty) return;
    if (index < 0 || index >= _lessons.length) return;

    setState(() {
      if (completed) {
        _completedLessonIndices.add(index);
      } else {
        _completedLessonIndices.remove(index);
      }
      _recomputeProgress();
    });

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('enrolledCourses')
        .doc(course.id);

    await ref.set(
      {
        'completedLessonIndices': _completedLessonIndices.toList(),
        'completedPercentage': _progress,
      },
      SetOptions(merge: true),
    );
  }

  void _goToNextLesson() {
    if (_lessons.isEmpty) return;
    if (_currentLessonIndex < _lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
      });
      _saveContinueLearning(_currentLessonIndex);
    }
  }

  void _handleVideoFinished() {
    _markCurrentLessonCompleted();
    _goToNextLesson();
  }

  void _markCurrentLessonCompleted() {
    _toggleLessonCompleted(_currentLessonIndex, true);
  }

  void changeTab(int index) {
    setState(() {
      _selectedTag = index;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final course = _effectiveCourse;
    final displayTitle = course?.name ?? widget.title;
    final author =
        course?.author.isNotEmpty == true ? course!.author : widget.author;
    final lowerName = (course?.name ?? widget.title).toLowerCase();
    final lowerCategory =
        course?.category.toLowerCase() ?? widget.category.toLowerCase();

    String subtitle;
    if (lowerName.contains('python')) {
      subtitle =
          'Apprenez les bases de Python étape par étape avec des exercices pratiques.';
    } else if (lowerName.contains('angular')) {
      subtitle =
          'Construisez des applications web modernes avec Angular et TypeScript.';
    } else if (lowerName.contains('flutter') ||
        lowerCategory.contains('mobile')) {
      subtitle =
          'Créez des applications mobiles modernes avec Flutter et une seule base de code.';
    } else if (lowerName.contains('java')) {
      subtitle =
          'Renforcez vos bases en Java et développez des backends solides.';
    } else if (lowerName.contains('vue')) {
      subtitle = 'Découvrez le développement frontend moderne avec Vue.js.';
    } else {
      subtitle =
          'Un cours complet pour progresser rapidement sur cette matière.';
    }

    final currentVideoUrl = _lessons.isNotEmpty
        ? _lessons[_currentLessonIndex]['url']
        : (course?.videoUrl.isNotEmpty == true
            ? course!.videoUrl
            : _fallbackVideoForCourse(course?.name));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF111827),
        body: SafeArea(
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
                          displayTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: CustomIconButton(
                          child: const Icon(Icons.arrow_back),
                          height: 35,
                          width: 35,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                CustomVideoPlayer(
                  videoUrl: currentVideoUrl,
                  onFinished: _handleVideoFinished,
                ),
                const SizedBox(height: 10),
                if (_lessons.length > 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _goToNextLesson,
                      child: const Text('Next Video'),
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                if (widget.author.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'By ${widget.author}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
                if (widget.category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(widget.category),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
                ],
                if (_quizScore != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Quiz score: ${(_quizScore! * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 15),
                CustomTabView(
                  index: _selectedTag,
                  changeTab: changeTab,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildTabBody(course),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: BottomSheet(
          onClosing: () {},
          backgroundColor: const Color(0xFF111827),
          enableDrag: false,
          builder: (context) {
            return SizedBox(
              height: 80,
              child: EnrollBottomSheet(course: course),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBody(Course? course) {
    switch (_selectedTag) {
      case 0:
        return AboutTab(course: course, titleFallback: widget.title);
      case 1:
        return PlayList(
          course: course,
          lessons: _lessons,
          currentIndex: _currentLessonIndex,
          onLessonSelected: (index) {
            setState(() {
              _currentLessonIndex = index;
            });
            _saveContinueLearning(index);
          },
          completedLessons: _completedLessonIndices,
          onCompletedChanged: _toggleLessonCompleted, // Passer la fonction
        );
      case 2:
        return DocumentsTab(course: course);
      case 3:
        return ToolsTab(course: course);
      default:
        return AboutTab(course: course, titleFallback: widget.title);
    }
  }
}

String _fallbackVideoForCourse(String? name) {
  final lower = (name ?? '').toLowerCase();

  if (lower.contains('php')) {
    // Démo PHP
    return 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4';
  }
  if (lower.contains('vue')) {
    // Démo Vue.js
    return 'https://sample-videos.com/video321/mp4/720/sample-5s.mp4';
  }
  if (lower.contains('flutter') || lower.contains('kotlin')) {
    // Démo Flutter/Kotlin
    return 'https://sample-videos.com/video321/mp4/720/sample-10s.mp4';
  }
  if (lower.contains('java')) {
    // Démo Java
    return 'https://sample-videos.com/video321/mp4/720/sample-15s.mp4';
  }

  // Fallback générique
  return 'https://sample-videos.com/video321/mp4/720/sample-20s.mp4';
}

class AboutTab extends StatelessWidget {
  final Course? course;
  final String titleFallback;

  const AboutTab({Key? key, this.course, required this.titleFallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = course?.name ?? titleFallback;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title is a complete course designed to help you build solid foundations. You will learn key concepts step by step with practical examples so you can apply them in real projects.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 24),
          if (course != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4B8B),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseQuizPage(course: course!),
                    ),
                  );
                },
                child: const Text(
                  'Quiz du cours (3-5 QCM)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DocumentsTab extends StatelessWidget {
  final Course? course;

  const DocumentsTab({Key? key, this.course}) : super(key: key);

  List<Map<String, String>> _docsForCourse() {
    // Priorité : documents venant de Firestore pour ce cours
    if (course != null && course!.documents.isNotEmpty) {
      return course!.documents;
    }

    // Fallback: quelques exemples en fonction du nom du cours
    final name = course?.name.toLowerCase() ?? '';

    if (name.contains('vue')) {
      return [
        {
          'title': 'Introduction to Frontend Engineer with Vue (PDF)',
          'url':
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        },
        {
          'title': 'Vue Component Cheat Sheet',
          'url':
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        },
      ];
    }

    if (name.contains('react')) {
      return [
        {
          'title': 'React JS Beginner Guide (PDF)',
          'url':
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        },
      ];
    }

    return [
      {
        'title': 'Course Syllabus (PDF)',
        'url':
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final docs = _docsForCourse();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20.0, bottom: 40),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return Card(
          color: const Color(0xFF1F2933),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(
              doc['title']!,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  onPressed: () async {
                    await saveUserResourceGlobal(
                      course: course,
                      type: 'pdf',
                      title: doc['title'] ?? 'Document',
                      url: doc['url'] ?? '',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  tooltip: 'Résumé automatique',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfSummaryPage(
                          title: doc['title'] ?? 'Document',
                          pdfUrl: doc['url'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () async {
                    final uri = Uri.parse(doc['url']!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
            onTap: () async {
              final uri = Uri.parse(doc['url']!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        );
      },
    );
  }
}

class ToolsTab extends StatelessWidget {
  final Course? course;

  const ToolsTab({Key? key, this.course}) : super(key: key);

  List<Map<String, String>> _toolsForCourse() {
    // Priorité : outils/plugins venant de Firestore pour ce cours
    if (course != null && course!.tools.isNotEmpty) {
      return course!.tools;
    }

    final name = course?.name.toLowerCase() ?? '';
    final category = course?.category.toLowerCase() ?? '';

    // Vue / React / frontend
    if (name.contains('vue') ||
        name.contains('react') ||
        category == 'frontend') {
      return [
        {
          'name': 'Node.js & npm',
          'subtitle': 'JavaScript runtime & package manager',
          'url': 'https://nodejs.org/',
        },
        {
          'name': 'Visual Studio Code',
          'subtitle': 'Code editor with Vue/React extensions',
          'url': 'https://code.visualstudio.com/',
        },
        {
          'name': 'MongoDB Compass',
          'subtitle': 'GUI client for MongoDB',
          'url': 'https://www.mongodb.com/try/download/compass',
        },
      ];
    }

    // Flutter / mobile / Kotlin
    if (name.contains('flutter') ||
        name.contains('kotlin') ||
        category == 'mobile') {
      return [
        {
          'name': 'Android Studio',
          'subtitle': 'IDE for Android & Flutter development',
          'url': 'https://developer.android.com/studio',
        },
        {
          'name': 'Flutter SDK',
          'subtitle': 'Flutter framework & tools',
          'url': 'https://docs.flutter.dev/get-started/install',
        },
      ];
    }

    // Java backend
    if (name.contains('java')) {
      return [
        {
          'name': 'Java JDK',
          'subtitle': 'Java Development Kit',
          'url': 'https://adoptium.net/',
        },
        {
          'name': 'Eclipse IDE',
          'subtitle': 'Java IDE for backend projects',
          'url': 'https://www.eclipse.org/downloads/',
        },
      ];
    }

    // Python
    if (name.contains('python')) {
      return [
        {
          'name': 'Python',
          'subtitle': 'Python interpreter & standard library',
          'url': 'https://www.python.org/downloads/',
        },
        {
          'name': 'PyCharm Community',
          'subtitle': 'IDE for Python projects',
          'url': 'https://www.jetbrains.com/pycharm/download/',
        },
      ];
    }

    // Default tools
    return [
      {
        'name': 'Visual Studio Code',
        'subtitle': 'Lightweight editor for many languages',
        'url': 'https://code.visualstudio.com/',
      },
      {
        'name': 'Git & GitHub',
        'subtitle': 'Version control & hosting',
        'url': 'https://github.com/',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tools = _toolsForCourse();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20.0, bottom: 40),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Card(
          color: const Color(0xFF1F2933),
          child: ListTile(
            leading:
                const Icon(Icons.build_circle_outlined, color: Colors.white),
            title: Text(
              tool['name']!,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              tool['subtitle'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: TextButton(
              onPressed: () async {
                final uri = Uri.parse(tool['url']!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Download'),
            ),
          ),
        );
      },
    );
  }
}

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'name': 'Student 1',
        'comment': 'Very clear explanations and great examples.',
      },
      {
        'name': 'Student 2',
        'comment':
            'Helped me understand the basics and start my first project.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20.0, bottom: 40),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(review['name']!),
          subtitle: Text(review['comment']!),
        );
      },
    );
  }
}

class PlayList extends StatelessWidget {
  final Course? course;
  final List<Map<String, String>> lessons;
  final int currentIndex;
  final ValueChanged<int> onLessonSelected;
  final Set<int> completedLessons;
  final void Function(int, bool) onCompletedChanged;

  const PlayList({
    Key? key,
    this.course,
    required this.lessons,
    required this.currentIndex,
    required this.onLessonSelected,
    required this.completedLessons,
    required this.onCompletedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return ListView.separated(
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        padding: const EdgeInsets.only(top: 20, bottom: 40),
        shrinkWrap: true,
        itemCount: lessonList.length,
        itemBuilder: (_, index) {
          return LessonCard(lesson: lessonList[index]);
        },
      );
    }

    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final l = lessons[index];
        final title = l['title'] ?? 'Lesson ${index + 1}';

        return ListTile(
          leading: Icon(
            Icons.play_circle_fill,
            color: index == currentIndex ? kPrimaryColor : Colors.grey,
          ),
          title: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: completedLessons.contains(index),
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  if (value == null) return;
                  onCompletedChanged(
                      index, value); // ← Utilise la fonction passée
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                color: kPrimaryColor,
                onPressed: () async {
                  await saveUserResourceGlobal(
                    course: course,
                    type: 'video',
                    title: title,
                    url: l['url'] ?? '',
                  );
                },
              ),
            ],
          ),
          onTap: () => onLessonSelected(index),
        );
      },
    );
  }
}

class Description extends StatelessWidget {
  const Description({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Text(
          "Build Flutter iOS and Android Apps with a Single Codebase: Learn Google's Flutter Mobile Development Framework & Dart"),
    );
  }
}

class CustomTabView extends StatefulWidget {
  final Function(int) changeTab;
  final int index;
  const CustomTabView({Key? key, required this.changeTab, required this.index})
      : super(key: key);

  @override
  State<CustomTabView> createState() => _CustomTabViewState();
}

class _CustomTabViewState extends State<CustomTabView> {
  final List<String> _tags = [
    "About",
    "Lessons",
    "Documents",
    "Tools",
  ];

  Widget _buildTags(int index) {
    return GestureDetector(
      onTap: () {
        widget.changeTab(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: widget.index == index ? kPrimaryColor : null,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          _tags[index],
          style: TextStyle(
            color: widget.index != index ? Colors.white70 : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1F2933),
      ),
      child: Row(
        children: _tags
            .asMap()
            .entries
            .map((MapEntry map) => Expanded(child: _buildTags(map.key)))
            .toList(),
      ),
    );
  }
}

class EnrollBottomSheet extends StatefulWidget {
  final Course? course;

  const EnrollBottomSheet({Key? key, this.course}) : super(key: key);

  @override
  _EnrollBottomSheetState createState() => _EnrollBottomSheetState();
}

class _EnrollBottomSheetState extends State<EnrollBottomSheet> {
  Future<void> _addToWishlist() async {
    final course = widget.course;
    final user = FirebaseAuth.instance.currentUser;
    if (course == null || user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('enrolledCourses')
        .doc(course.id);

    await ref.set(course.toMap(), SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course saved to Enrolled')),
    );

    // Ouvrir directement la page Enrolled après l'ajout
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EnrolledPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomIconButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EnrolledPage()),
                );
              },
              color: kPrimaryColor,
              height: 45,
              width: 45,
              child: const Text(
                "Enroll Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final Color? color;
  final VoidCallback onTap;

  const CustomIconButton({
    Key? key,
    required this.child,
    required this.height,
    required this.width,
    this.color = Colors.white,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Center(child: child),
        onTap: onTap,
      ),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 2.0,
            spreadRadius: .05,
          ), //BoxShadow
        ],
      ),
    );
  }
}

// Fonction globale à ajouter à la fin du fichier, après toutes les classes
Future<void> saveUserResourceGlobal({
  required Course? course,
  required String type,
  required String title,
  required String url,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || course == null || url.isEmpty) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('savedResources')
      .add({
    'courseId': course.id,
    'courseName': course.name,
    'category': course.category,
    'type': type,
    'title': title,
    'url': url,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
