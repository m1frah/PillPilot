import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/model.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import '../../database/firebaseoperations.dart'; 

class PostDetailsPage extends StatefulWidget {
  final Post post;

  const PostDetailsPage({required this.post});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Post Details'),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Image.network(
                widget.post.imageUrl,
                fit: BoxFit.cover,
                height: 300,
                width: double.infinity,
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              Positioned(
                left: 16.0,
                bottom: 16.0,
                child: Text(
                  widget.post.caption,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Comments Section
          _buildCommentsList(),
        ],
      ),
    ),
    bottomNavigationBar: Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _addComment(widget.post.id, _commentController.text);
            },
          ),
        ],
      ),
    ),
  );
}


  void _addComment(String postId, String commentText) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      CollectionReference commentsRef = FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.post.topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments');

      commentsRef
          .add({
            'userId': userId,
            'commentText': commentText,
            'timestamp': Timestamp.now(),
          })
          .then((DocumentReference commentDoc) {
            commentDoc.collection('likes').doc(userId).set({
              'liked': true,
            });
            _commentController.clear();
          })
          .catchError((error) {
            print('Failed to add comment: $error');
          });
    } else {
      print('User is not authenticated.');
    }
  }

  Widget _buildCommentsList() {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.post.topicId)
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
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
            int likesCount = commentData['likes'] ?? 0;

            CollectionReference likesRef = FirebaseFirestore.instance
                .collection('topics')
                .doc(widget.post.topicId)
                .collection('posts')
                .doc(widget.post.id)
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
                 
                  _handleDeletedUserComment(commentId);
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

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/$pfp'), // load pfp
                      ), 
                      title: Row(
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
                      subtitle: Row(
                        children: [
                          Expanded(child: Text(commentText)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite),
                                color: snapshot.data!.docs.any((likeDoc) => likeDoc.id == currentUserId)
                                    ? Colors.red
                                    : null,
                                onPressed: () async {
                                  // Get current user id
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

  void _handleDeletedUserComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.post.topicId)
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print('Error handling deleted user comment: $e');
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

