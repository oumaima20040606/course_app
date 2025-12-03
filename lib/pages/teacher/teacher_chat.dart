import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeacherChatScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  TeacherChatScreen({required this.studentId, required this.studentName});

  @override
  _TeacherChatScreenState createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  String? _chatId;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final teacherId = _auth.currentUser!.uid;
      final studentId = widget.studentId;

      // Create a sorted chat ID to ensure same chat for both users
      final participants = [teacherId, studentId]..sort();
      _chatId = participants.join('_');

      // Check if chat exists, if not create it
      final chatDoc = await _firestore.collection('chats').doc(_chatId).get();

      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(_chatId).set({
          'participants': participants,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'participantNames': {
            teacherId: 'Teacher',
            studentId: widget.studentName,
          },
        });
      }

      setState(() {
        _isLoading = false;
      });

      // Scroll to bottom after a short delay
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize chat')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final messageText = _messageController.text.trim();
      final currentUserId = _auth.currentUser!.uid;

      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(_chatId!)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update chat document with last message info
      await _firestore.collection('chats').doc(_chatId!).update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': currentUserId,
      });

      _messageController.clear();

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Stream<QuerySnapshot> _getMessagesStream() {
    if (_chatId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chats')
        .doc(_chatId!)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Widget _buildMessageBubble(DocumentSnapshot messageDoc) {
    final message = messageDoc.data() as Map<String, dynamic>;
    final text = message['text'] ?? '';
    final senderId = message['senderId'] ?? '';
    final timestamp = message['timestamp'] as Timestamp?;
    final isMe = senderId == _auth.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                widget.studentName[0].toUpperCase(),
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[600] : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft:
                            isMe ? Radius.circular(16) : Radius.circular(4),
                        bottomRight:
                            isMe ? Radius.circular(4) : Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  if (timestamp != null)
                    Text(
                      _formatMessageTime(timestamp.toDate()),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.blue[800],
              ),
            ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (today == messageDate) {
      return DateFormat('h:mm a').format(date);
    } else if (today.difference(messageDate).inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentName,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Student',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Show chat options
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages area
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getMessagesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading messages'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data?.docs ?? [];

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Send a message to start the conversation',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        );
                      }

                      // Scroll to bottom when new messages arrive
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(messages[index]);
                        },
                      );
                    },
                  ),
                ),

                // Message input area
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              maxLines: null,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: IconButton(
                          icon: _isSending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Icon(Icons.send, color: Colors.white),
                          onPressed: _isSending ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
