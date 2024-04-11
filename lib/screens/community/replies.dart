import 'package:flutter/material.dart';
import '../../widgets/replyComment.dart'; 
import '../../widgets/repliesList.dart'; 
import '../../database/firebaseoperations.dart';
  FirebaseOperations _firebaseOperations = FirebaseOperations(); 

class RepliesSection extends StatelessWidget {
  final String commentId;
  final String postId;
  final String topicId;

  RepliesSection({Key? key, required this.commentId, required this.postId, required this.topicId}) : super(key: key);

  final TextEditingController _textEditingController = TextEditingController();

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
                  SizedBox(height: 10),  
                  SizedBox(height: 10),
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
                    _firebaseOperations.sendReply(topicId, postId, commentId, _textEditingController.text);
                    _textEditingController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
