import 'package:flutter/material.dart';
import '../../model/model.dart';
import '../../widgets/commentList.dart';
import 'replies.dart';
import '../../../database/firebaseoperations.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;

  const PostDetailsPage({required this.post});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late TextEditingController _commentController;
  String _selectedSortOption = 'Newest';
  bool _updatingLikes = false;
  FirebaseOperations _firebaseOperations = FirebaseOperations(); 

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
      body: Column(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: [
                Text(
                  'Comments -',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' Sort by:',
                  style: TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 39, 39, 39)),
                ),
                SizedBox(width: 8.0),
                DropdownButton<String>(
                  style: TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 39, 39, 39)),
                  value: _selectedSortOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSortOption = newValue!;
                      _firebaseOperations.updateLikesCountForPost(widget.post.topicId, widget.post.id);
                    });
                  },
                  items: <String>['Newest', 'Top'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _updatingLikes
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 6.0),
                        buildCommentsList(widget.post, _selectedSortOption, (commentId) {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                constraints: BoxConstraints(
                                  minWidth: double.infinity, 
                                ),
                                child: RepliesSection(commentId: commentId, topicId: widget.post.topicId, postId: widget.post.id),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
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
                _firebaseOperations.addComment(widget.post.topicId, widget.post.id, _commentController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}