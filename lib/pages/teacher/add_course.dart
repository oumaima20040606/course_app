// Updated AddCourseScreen with edit functionality
import 'dart:io';

import 'package:course_app/models/course.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddCourseScreen extends StatefulWidget {
  final Course? course; // For edit mode
  final bool isEditMode;

  AddCourseScreen({this.course, this.isEditMode = false});

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
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
    if (widget.isEditMode && widget.course != null) {
      _titleController.text = widget.course!.name;
      _authorController.text = widget.course!.author;
      _descriptionController.text = widget.course!.description ?? '';
      _youtubeUrlController.text = widget.course!.videoUrl;
      _selectedCategory = widget.course!.category;
      _currentImageUrl = widget.course!.thumbnail;
    }
  }

  Future<void> _submitCourse() async {
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
      final currentUser = FirebaseAuth.instance.currentUser!;
      String? thumbnailUrl = _currentImageUrl;

      // Upload new image if selected
      if (_thumbnail != null) {
        thumbnailUrl = await uploadImageToFirebase(_thumbnail!);
      }

      final Course courseData = Course(
        id: widget.isEditMode ? widget.course!.id : '', // Keep ID for edit
        name: _titleController.text,
        thumbnail: thumbnailUrl ?? '',
        author: _authorController.text.isNotEmpty
            ? _authorController.text
            : currentUser.displayName ??
                currentUser.email?.split('@').first ??
                'Unknown Author',
        authorId: currentUser.uid,
        completedPercentage:
            widget.isEditMode ? widget.course!.completedPercentage : 0.0,
        category: _selectedCategory!,
        videoUrl: _youtubeUrlController.text,
        description: _descriptionController.text,
        documents: widget.isEditMode ? widget.course!.documents : const [],
        lessons: widget.isEditMode ? widget.course!.lessons : const [],
        tools: widget.isEditMode ? widget.course!.tools : const [],
        rating: widget.isEditMode ? widget.course!.rating : 0.0,
        enrolledCount: widget.isEditMode ? widget.course!.enrolledCount : 0,
        createdAt:
            widget.isEditMode ? widget.course!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.isEditMode) {
        // Update existing course
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.course!.id)
            .update({
          ...courseData.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully!')),
        );
      } else {
        // Create new course
        await FirebaseFirestore.instance.collection('courses').add({
          ...courseData.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully!')),
        );
      }

      // Clear form and go back
      if (!widget.isEditMode) {
        _clearForm();
      }

      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
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
    if (widget.course == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Course'),
        content: Text(
            'Are you sure you want to delete "${widget.course!.name}"? This action cannot be undone.'),
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
            .doc(widget.course!.id)
            .delete();

        // Also delete associated data (enrollments, etc.)
        await _deleteCourseEnrollments(widget.course!.id);

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

  Future<void> _deleteCourseEnrollments(String courseId) async {
    // Delete all enrollments for this course
    final enrollmentsSnapshot = await FirebaseFirestore.instance
        .collection('enrollments')
        .where('courseId', isEqualTo: courseId)
        .get();

    for (var doc in enrollmentsSnapshot.docs) {
      await doc.reference.delete();
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
      return 'https://via.placeholder.com/300x200?text=Error+Uploading';
    }
  }

  void _clearForm() {
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _youtubeUrlController.clear();
    _priceController.clear();
    setState(() {
      _selectedCategory = null;
      _thumbnail = null;
      _currentImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Course' : 'Add New Course'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.isEditMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteCourse,
                ),
              ]
            : null,
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
                                Text('Tap to add thumbnail'),
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
                decoration: InputDecoration(
                  labelText: 'Author Name',
                  border: const OutlineInputBorder(),
                  hintText: 'Leave empty to use your name',
                ),
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

              // YouTube URL (optional)
              TextFormField(
                controller: _youtubeUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://youtube.com/watch?v=...',
                ),
              ),

              const SizedBox(height: 30),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitCourse,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isEditMode ? 'Update Course' : 'Create Course',
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
