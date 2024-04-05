import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/model.dart';
import 'postdetails.dart';
class TopicPostsPage extends StatelessWidget {
  final Topic topic;

  const TopicPostsPage({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${topic.name} Community'),
      ),
      body: FutureBuilder(
        future: fetchPosts(topic.id), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<Post> posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(child: Text('No posts available'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(context, posts[index]);
            },
          );
        },
      ),
    );
  }

Widget _buildPostCard(BuildContext context, Post post) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailsPage(post: post),
        ),
      );
    },
    child: Center(
      child: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Container(
          width: MediaQuery.of(context).size.width * (9 / 10), 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0), 
            child: Stack(
              children: [
                // Background Image
                Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, 
                ),
      
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6), 
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        post.caption,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0, // Adjust font size
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Future<List<Post>> fetchPosts(String topicId) async {
  List<Post> posts = [];
  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('topics')
      .doc(topicId)
      .collection('posts')
      .get();

  snapshot.docs.forEach((doc) {
    var data = doc.data();
    posts.add(Post(
      id: doc.id,
      caption: data['Caption'],
      imageUrl: data['ImageURL'],
      topicId: topicId, 
    ));
  });

  return posts;
}}
