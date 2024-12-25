import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() async {
    final enteredMessage = _textController.text.trim();

    if (enteredMessage.isEmpty) return;

    FocusScope.of(context).unfocus();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('User is not authenticated.');
      return;
    }

    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userData.exists) {
        print('User data does not exist.');
        return;
      }

      final userImage = userData.data()?['image_url'] as String? ?? '';
      final username = userData.data()?['username'] as String? ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': currentUser.uid,
        'userImage': userImage.isNotEmpty
            ? userImage
            : 'assets/images/default_avatar.png', // Fallback path for local image
        'username': username,
      });

      _textController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
