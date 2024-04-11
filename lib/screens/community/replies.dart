import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/replyComment.dart'; 
import '../../widgets/repliesList.dart'; 
class RepliesSection extends StatelessWidget {
  final String commentId;
  final String postId;
  final String topicId;

   RepliesSection({Key? key, required this.commentId, required this.postId, required this.topicId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Replies'),
        
      ),
      body: Column(
        
        crossAxisAlignment: CrossAxisAlignment.stretch,
        
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  FullComment(
                    postId: postId,
                    topicId: topicId,
                    commentId: commentId,
                  ),
                  Divider(), 
                  SizedBox(height: 10),  SizedBox(height: 10),
               
                  ReplyComments(
                    topicId: topicId,
                    postId: postId,
                    commentId: commentId,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
     
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendReply(_textEditingController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendReply(String replyText) async {
    try {
    
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;


      CollectionReference replyCollection = FirebaseFirestore.instance
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies');

    
      await replyCollection.add({
        'userId': currentUserId,
        'commentText': replyText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      
      _textEditingController.clear();

    } catch (error) {
      // Handle errors
      print('Error sending reply: $error');
 
    }
  }

  final TextEditingController _textEditingController = TextEditingController();
}