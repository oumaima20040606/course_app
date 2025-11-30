import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String name;
  final String thumbnail;
  final String author;
  final double completedPercentage;
  final String category;
  final String videoUrl;
  final List<Map<String, String>> documents;
  final List<Map<String, String>> lessons;
  final List<Map<String, String>> tools;

  Course({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.author,
    required this.completedPercentage,
    this.category = '',
    this.videoUrl = '',
    this.documents = const [],
    this.lessons = const [],
    this.tools = const [],
  });

  factory Course.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // --- Documents (PDF) ---
    // Accepte à la fois 'documents' et 'document' (comme dans tes captures Firestore)
    final rawDocuments = (data['documents'] ?? data['document']) as List? ?? [];
    final parsedDocuments = rawDocuments
        .map((e) => Map<String, String>.from(e as Map))
        .toList();

    // --- Lessons (vidéos) ---
    // 1) Accepte à la fois 'sections' et 'section' comme champ racine
    //    sections[...].materials[...] avec materialType="video"
    final sections = (data['sections'] ?? data['section']) as List? ?? [];
    final List<Map<String, String>> parsedLessons = [];
    for (final s in sections) {
      final materials = (s is Map && s['materials'] is List)
          ? (s['materials'] as List)
          : const [];
      for (final m in materials) {
        if (m is Map && (m['materialType'] as String?)?.toLowerCase() == 'video') {
          parsedLessons.add({
            'title': (m['materialName'] ?? '') as String,
            'url': (m['url'] ?? '') as String,
          });
        }
      }
    }

    // 2) Si aucune leçon n'a été trouvée mais qu'un champ root 'url' existe,
    //    on crée au moins une leçon pour l'écran Lessons
    if (parsedLessons.isEmpty && (data['url'] as String? ?? '').isNotEmpty) {
      parsedLessons.add({
        'title': (data['sectionName'] ?? data['name'] ?? 'Introduction') as String,
        'url': data['url'] as String,
      });
    }

    // --- Tools (outils/plugins) ---
    // Champ 'tools' avec Name / Subtitle / url
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
      completedPercentage:
          (data['completedPercentage'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      documents: parsedDocuments,
      lessons: parsedLessons,
      tools: parsedTools,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'thumbnail': thumbnail,
      'author': author,
      'completedPercentage': completedPercentage,
      'category': category,
      'videoUrl': videoUrl,
      'documents': documents,
      'lessons': lessons,
      'tools': tools,
    };
  }
}
