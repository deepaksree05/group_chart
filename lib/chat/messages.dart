import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart'; // Ensure the correct import path

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (streamSnapshot.hasError) {
          return Center(child: Text('Error: ${streamSnapshot.error}'));
        }

        final chatDocs = streamSnapshot.data?.docs;

        if (chatDocs == null || chatDocs.isEmpty) {
          return const Center(child: Text('No messages available.'));
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          return const Center(child: Text('No user is currently signed in.'));
        }

        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final chatData = chatDocs[index].data() as Map<String, dynamic>;

            final text = chatData['text'] ?? 'No message';
            final userId = chatData['userId'] ?? 'Unknown User';
            final userImage = chatData['userImage '] ?? 'default_image_url'; // Default or placeholder URL

            final isCurrentUser = userId == currentUser.uid;

            return MessageBubble(
              text,
               isCurrentUser,
              userId,
               userImage, // Pass the image URL to MessageBubble
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}




