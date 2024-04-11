import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FullComment extends StatelessWidget {
  final String postId;
  final String topicId;
  final String commentId;

  const FullComment({
    Key? key,
    required this.postId,
    required this.topicId,
    required this.commentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Center(child: Text('Comment not found'));
        }
        Map<String, dynamic> commentData = snapshot.data!.data()!;
        String commentText = commentData['commentText'] ?? '';
        String userId = commentData['userId'] ?? '';
        Timestamp timestamp = commentData['timestamp'];

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
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

            CollectionReference likesRef = FirebaseFirestore.instance
                .collection('topics')
                .doc(topicId)
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .doc(commentId)
                .collection('likes');

            return StreamBuilder<QuerySnapshot>(
              stream: likesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                int likesCount = snapshot.data!.docs.length;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/$pfp'), 
                            radius: 24, 
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      username,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Increase font size
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "- ${_getTimeAgo(timestamp)}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color.fromARGB(255, 86, 86, 86),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  commentText,
                                  style: TextStyle(fontSize: 16), 
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.favorite),
                              SizedBox(width: 5),
                              Text('$likesCount'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
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