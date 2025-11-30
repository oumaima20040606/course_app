import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LanguagePage extends StatelessWidget {
  final List<String> languages = const [
    'English',
    'Français',
    'Español',
  ];

  LanguagePage({Key? key}) : super(key: key);

  Future<void> _setLanguage(BuildContext context, String lang) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'language': lang},
      SetOptions(merge: true),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4B8B),
        elevation: 0,
        title: const Text(
          'Language',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            tileColor: const Color(0xFF1F2933),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              lang,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () => _setLanguage(context, lang),
          );
        },
      ),
    );
  }
}
