import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMee;
  final String userImage;
  final String userId;

  const MessageBubble(this.message, this.isMee, this.userId, this.userImage,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisAlignment:
              isMee ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: 140,
              decoration: BoxDecoration(
                color: isMee ? Colors.grey.shade300 : Colors.deepPurpleAccent,
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(12),
                  topLeft: const Radius.circular(12),
                  bottomLeft: !isMee
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                  bottomRight: isMee
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              constraints: const BoxConstraints(maxWidth: 250),
              child: Column(
                crossAxisAlignment:isMee ?CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId).
                        get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Loading...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Text(
                          'Error fetching user',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        );
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text(
                          'Unknown User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                          ),
                        );
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final username = data['username'] ?? 'Unknown User';
                      return Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      );
                    },
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: isMee ? Colors.black : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: isMee ? null : 120, // Avatar on the left if not current user
          right: isMee ? 120 : null, // Avatar on the right if current user
          child: CircleAvatar(
            backgroundImage: NetworkImage(userImage), // Load the image from URL
          ),
        )
      ],
    );
  }
}
