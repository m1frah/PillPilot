import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyComments extends StatelessWidget {
  final String topicId;
  final String postId;
  final String commentId;

  const ReplyComments({
    Key? key,
    required this.topicId,
    required this.postId,
    required this.commentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<DocumentSnapshot<Map<String, dynamic>>> replyDocs = snapshot.data!.docs;
        if (replyDocs.isEmpty) {
          return Center(child: Text('No replies yet'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: replyDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> replyData = replyDocs[index].data()!;
            String replyId = replyDocs[index].id;
            String replyText = replyData['commentText'] ?? '';
            String userId = replyData['userId'] ?? '';
            Timestamp? timestamp = replyData['timestamp']; // Use nullable Timestamp

            // Only show delete icon if the reply is by the current user
            bool isCurrentUserReply = userId == currentUserID;

            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (userSnapshot.hasError) {
                  return Text('Error fetching user data: ${userSnapshot.error}');
                }
                if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
                  return Text('User not found');
                }
                String username = userSnapshot.data!.data()!['username'] ?? '';
                String pfp = userSnapshot.data!.data()!['pfp'] ?? '';
                String timeAgo = timestamp != null ? _getTimeAgo(timestamp) : ''; // Check for null timestamp

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/$pfp'), // load pfp
                  ),
                  title: Row(
                    children: [
                      Text(
                        username,
                        style: TextStyle(fontWeight: FontWeight.bold), // Make username bold
                      ),
                      SizedBox(width: 8), // Add some spacing between username and time
                      Text(
                        timeAgo,
                        style: TextStyle(fontSize: 11, color: Color.fromARGB(255, 86, 86, 86)), // Customize time ago text style
                      ),
                    ],
                  ),
                  subtitle: Text(replyText),
                  trailing: isCurrentUserReply
                      ? IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteReply(topicId, postId, commentId, replyId);
                          },
                          color: Colors.red, // Make delete icon red
                        )
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _deleteReply(
    String topicId,
    String postId,
    String commentId,
    String replyId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (error) {
      print('Error deleting reply: $error');
    }
  }

  String _getTimeAgo(Timestamp timestamp) {
    DateTime postDate = timestamp.toDate();
    Duration difference = DateTime.now().difference(postDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
