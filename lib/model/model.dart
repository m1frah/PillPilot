//sjhuld create and use models for signup as well

import 'package:cloud_firestore/cloud_firestore.dart';
class User {
  final String userId;
  final String username;
  final String gender;
  final String pfp;

  User({
    required this.userId,
    required this.username,
    required this.gender,
    required this.pfp,
  });
}
class Comment {
  final String id;
  final String userId;
  final String commentText;
  final Timestamp timestamp;
  final int likesCount;

  Comment({
    required this.id,
    required this.userId,
    required this.commentText,
    required this.timestamp,
    required this.likesCount,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      commentText: data['commentText'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likesCount: data['likesCount'] ?? 0,
    );
  }
}
class Post {
  final String id;
  final String caption;
  final String imageUrl;
  final String topicId;

  Post({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.topicId,
  });
}

class Topic {
  final String id;
  final String name;
  final String description;
   final String icon;
  Topic({
    required this.id, 
    required this.name,
    required this.description,
      required this.icon,
  });
 
  
}class JournalEntry {
   final int id;
  final String title;
  final String content;
  final String createDate;
  final String mood;

  JournalEntry({
        required this.id, 
    required this.title,
    required this.content,
    required this.createDate,
    required this.mood,
  });
}