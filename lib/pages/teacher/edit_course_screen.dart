// pages/teacher/edit_course_screen.dart
import 'dart:io';

import 'package:course_app/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;

  EditCourseScreen({required this.course});

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;
  File? _thumbnail;
  String? _currentImageUrl;

  final List<String> _categories = [
    'Backend',
    'Frontend',
    'Mobile',
    'UI/UX',
    'Database',
    'DevOps',
    'AI/ML',
    'Cloud Computing'
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.course.name;
    _authorController.text = widget.course.author;
    _descriptionController.text = widget.course.description;
    _youtubeUrlController.text = widget.course.videoUrl;
    _selectedCategory = widget.course.category;
    _currentImageUrl = widget.course.thumbnail;
  }

  Future<void> _updateCourse() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the required fields')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    try {
      String? thumbnailUrl = _currentImageUrl;

      // Upload new image if selected
      if (_thumbnail != null) {
        thumbnailUrl = await uploadImageToFirebase(_thumbnail!);
      }

      final updatedCourse = Course(
        id: widget.course.id,
        name: _titleController.text,
        thumbnail: thumbnailUrl!,
        author: _authorController.text,
        authorId: widget.course.authorId,
        completedPercentage: widget.course.completedPercentage,
        category: _selectedCategory!,
        videoUrl: _youtubeUrlController.text,
        description: _descriptionController.text,
        documents: widget.course.documents,
        lessons: widget.course.lessons,
        tools: widget.course.tools,
        rating: widget.course.rating,
        enrolledCount: widget.course.enrolledCount,
        createdAt: widget.course.createdAt,
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .update(updatedCourse.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully!')),
      );

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteCourse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Course'),
        content: Text(
            'Are you sure you want to delete "${widget.course.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.course.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Course deleted successfully!'),
              backgroundColor: Colors.green),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error deleting course: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _thumbnail = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('course_thumbnails')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return _currentImageUrl ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Course'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteCourse,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail upload section
              const Text(
                'Course Thumbnail',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickThumbnail,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: _thumbnail != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_thumbnail!, fit: BoxFit.cover),
                        )
                      : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(_currentImageUrl!,
                                  fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_photo_alternate,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to change thumbnail'),
                              ],
                            ),
                ),
              ),

              const SizedBox(height: 20),

              // Course Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Author Name
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Course Description *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // YouTube URL
              TextFormField(
                controller: _youtubeUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://youtube.com/watch?v=...',
                ),
              ),

              const SizedBox(height: 30),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Course',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
