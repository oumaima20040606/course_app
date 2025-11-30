import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({Key? key}) : super(key: key);

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF111827),
        body: Center(
          child: Text(
            'You must be logged in to see your chats.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final chatsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4B8B),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: chatsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFFF4B8B)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading chats',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chatDoc = docs[index];
              final data = chatDoc.data();
              final List participants = data['participants'] ?? [];

              String otherId = '';
              if (participants.length == 2) {
                otherId = participants.firstWhere(
                  (p) => p != user.uid,
                  orElse: () => '',
                );
              }

              return ListTile(
                tileColor: const Color(0xFF1F2933),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  otherId.isEmpty ? 'Conversation' : 'Chat with $otherId',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Tap to open conversation',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(chatId: chatDoc.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
