import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/model.dart';
import '../../database/firebaseoperations.dart';

typedef void ReplyCallback(String commentId);
  FirebaseOperations _firebaseOperations = FirebaseOperations(); 
Widget buildCommentsList(Post post, String selectedSortOption, ReplyCallback onReply) {
  return _BuildCommentsList(post: post, selectedSortOption: selectedSortOption, onReply: onReply);
}

class _BuildCommentsList extends StatelessWidget {
  final Post post;
  final String selectedSortOption;
  final ReplyCallback onReply;
  const _BuildCommentsList({required this.post, required this.selectedSortOption, required this.onReply});

 @override
  Widget build(BuildContext context) {
    String sort = selectedSortOption == 'Top' ? 'likesCount' : 'timestamp';
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
        .collection('topics')
        .doc(post.topicId)
        .collection('posts')
        .doc(post.id)
        .collection('comments')
        .orderBy(sort, descending: true)
        .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<DocumentSnapshot<Map<String, dynamic>>> commentDocs = snapshot.data!.docs;
        if (commentDocs.isEmpty) {
          return Center(child: Text('Be the first to share your thoughts!'));
        }
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(), 
          shrinkWrap: true,
          itemCount: commentDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> commentData = commentDocs[index].data()!;
            String commentId = commentDocs[index].id;
            String commentText = commentData['commentText'] ?? '';
            String userId = commentData['userId'] ?? '';
            Timestamp timestamp = commentData['timestamp'];

            CollectionReference likesRef = FirebaseFirestore.instance
              .collection('topics')
              .doc(post.topicId)
              .collection('posts')
              .doc(post.id)
              .collection('comments')
              .doc(commentId)
              .collection('likes');

            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (userSnapshot.hasError) {
                  return Text('Error fetching username: ${userSnapshot.error}');
                }
                if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
                  _firebaseOperations.handleDeletedUserComment(post.topicId, post.id, commentId);
                  return SizedBox(); 
                }
                String username = userSnapshot.data!.data()!['username'] ?? '';
                String timeAgo = _getTimeAgo(timestamp);
                String pfp = userSnapshot.data!.data()!['pfp'] ?? '';

                return StreamBuilder<QuerySnapshot>(
                  stream: likesRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    // counts number of likes by counting docs under like subcollection
                    int likes = snapshot.data!.docs.length;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [ SizedBox(height :0),
                             Center(
  child: CircleAvatar(
    radius: 28,
    foregroundImage: AssetImage('assets/$pfp'), 
  ),
),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          username,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "- $timeAgo",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: const Color.fromARGB(255, 86, 86, 86),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(commentText),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.favorite),
                                    color: snapshot.data!.docs.any((likeDoc) => likeDoc.id == currentUserId)
                                      ? Colors.red
                                      : null,
                                    onPressed: () async {
                                      if (currentUserId == null) {
                                        // Handle if user deleted 
                                        return;
                                      }

                                      // Check if the likes subcollection exists
                                      final likesSnapshot = await likesRef.get();
                                      // Get the IDs of users who have liked the comment
                                      final likedUserIds = likesSnapshot.docs.map((doc) => doc.id).toList();
                                      // Check if the current user's ID is in the list of likedUserIds
                                      final isLiked = likedUserIds.contains(currentUserId);
                                      print(currentUserId);
                                      if (isLiked) {
                                        // User has already liked, so remove like
                                        await likesRef.doc(currentUserId).delete();
                                        
                                      } else {
                                        // User has not liked yet, so add like
                                        await likesRef.doc(currentUserId).set({'liked': true});
                                      }
                                    },
                                  ),
                                  SizedBox(width: 5),
                                  Text('$likes'),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 0),
                          Row(
                        children: [ 
  SizedBox(width: 50),
  TextButton(
    onPressed: () {
      
      onReply(commentId);
    },
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero, 
    ),
    child: Text(
      'Reply',
      style: TextStyle(fontSize: 14),
    ),
  ),
  SizedBox(width: 0),
  TextButton( 
    onPressed: () {
  _showEditPopup(context, commentId, commentText);
    },
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
    ),
    child: Text(
      'Edit',
      style: TextStyle(fontSize: 14), 
    ),
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

  //show edit dialog
   void _showEditPopup(BuildContext context, String commentId, String commentText) {
    TextEditingController controller = TextEditingController(text: commentText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Comment"),
          content: TextField(
            controller: controller,
            maxLines: null, // Allow multiple lines for editing
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveEditedComment(context, commentId, controller.text);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                _deleteComment(context, post.topicId, post.id, commentId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _saveEditedComment(BuildContext context, String commentId, String newText) async {
    try {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(post.topicId)
          .collection('posts')
          .doc(post.id)
          .collection('comments')
          .doc(commentId)
          .update({'commentText': newText});
      Navigator.pop(context); // Close the dialog
    } catch (error) {
      // Handle error
      print("Failed to save edited comment: $error");
    }
  }

  Future<void> _deleteComment(BuildContext context, String topicId, String postId, String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      Navigator.pop(context); // Close the dialog
    } catch (error) {
      // Handle error
      print("Failed to delete comment: $error");
    }
  }
}