import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String name;
  final String thumbnail;
  final String author;
  final String authorId;
  final double completedPercentage;
  final String category;
  final String videoUrl;
  final List<Map<String, String>> documents;
  final List<Map<String, String>> lessons;
  final List<Map<String, String>> tools;
  final String description;
  final int enrolledCount;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.author,
    required this.authorId,
    required this.completedPercentage,
    this.category = '',
    this.videoUrl = '',
    this.documents = const [],
    this.lessons = const [],
    this.tools = const [],
    this.description = '',
    this.enrolledCount = 0,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // --- Documents (PDF) ---
    final rawDocuments = (data['documents'] ?? data['document']) as List? ?? [];
    final parsedDocuments =
        rawDocuments.map((e) => Map<String, String>.from(e as Map)).toList();

    // --- Lessons (videos) ---
    final sections = (data['sections'] ?? data['section']) as List? ?? [];
    final List<Map<String, String>> parsedLessons = [];
    for (final s in sections) {
      final materials = (s is Map && s['materials'] is List)
          ? (s['materials'] as List)
          : const [];
      for (final m in materials) {
        if (m is Map &&
            (m['materialType'] as String?)?.toLowerCase() == 'video') {
          parsedLessons.add({
            'title': (m['materialName'] ?? '') as String,
            'url': (m['url'] ?? '') as String,
          });
        }
      }
    }

    // Fallback for single video courses
    if (parsedLessons.isEmpty && (data['url'] as String? ?? '').isNotEmpty) {
      parsedLessons.add({
        'title':
            (data['sectionName'] ?? data['name'] ?? 'Introduction') as String,
        'url': data['url'] as String,
      });
    }

    // --- Tools ---
    final rawTools = (data['tools'] as List?) ?? [];
    final parsedTools = rawTools.map((e) {
      final m = e as Map;
      return <String, String>{
        'name': (m['name'] ?? m['Name'] ?? '') as String,
        'subtitle': (m['subtitle'] ?? m['Subtitle'] ?? '') as String,
        'url': (m['url'] ?? '') as String,
      };
    }).toList();

    return Course(
      id: doc.id,
      name: (data['name'] ?? data['sectionName'] ?? '') as String,
      thumbnail: data['thumbnail'] ?? '',
      author: data['author'] ?? '',
      authorId: data['authorId'] ?? data['teacherUid'] ?? '',
      completedPercentage: (data['completedPercentage'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      description: data['description'] ?? '',
      enrolledCount: (data['enrolledCount'] ?? 0) as int,
      rating: (data['rating'] ?? 0.0).toDouble(),
      documents: parsedDocuments,
      lessons: parsedLessons,
      tools: parsedTools,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'thumbnail': thumbnail,
      'author': author,
      'authorId': authorId,
      'completedPercentage': completedPercentage,
      'category': category,
      'videoUrl': videoUrl,
      'description': description,
      'enrolledCount': enrolledCount,
      'rating': rating,
      'documents': documents,
      'lessons': lessons,
      'tools': tools,
    };
  }
}
