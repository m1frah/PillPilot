
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../model/model.dart';

class FirebaseOperations {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

//remove frend function
Future<void> removeFriend(String friendId) async {
  try {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('friends')
        .doc(friendId)
        .delete();
  } catch (e) {
    print('Error removing friend: $e');
  }}

//get pfp

userPfp(String userId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data();
      if (userData != null && userData.containsKey('pfp')) {
        return userData['pfp'];
      } else {
        print('User does not have a profile picture');
        return null;
      }
    } else {
      print('User not found');
      return null;
    }
  } catch (error) {
    print('Error fetching user profile picture: $error');
    return null;
  }


  
}


//if user deleted, comment deletes
Future<void> handleDeletedUserComment(String topicId, String postId, String commentId) async {
  try {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  } catch (e) {
    print('Error handling deleted user comment: $e');
  }
}            
//ensure randoma and unique friend code 
Future<String> generateFcode() async {
  String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  String fcode = '';
  bool exists = true;
  
  // Loop until a unique code is generated
  while (exists) {
    fcode = '';
    for (int i = 0; i < 8; i++) {
      fcode += chars[Random().nextInt(chars.length)];
    }

    var snapshot = await _firestore.collection('users').where('fcode', isEqualTo: fcode).get();
    if (snapshot.docs.isEmpty) {
      exists = false;
    }
  }
  return fcode;
}
//creates user
Future<void> createUser(String username, String email, String gender, String password) async {
  String pfp = gender == 'Male' ? 'm1.png' : 'f2.png';
  String fcode = await generateFcode();
  
  try {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((userCredential) {
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'gender': gender,
        'fcode': fcode,
        'pfp':pfp,
      });
    });
  } catch (error) {
    print('Error: $error');
  }
   Future<void> updateUserProfile(String newUsername, String newGender, String newpfp) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': newUsername,
        'gender': newGender,
        'pfp' :newpfp,
      });
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }}
//update likes count



  Future<void> updateLikesCountForPost(String topicId, String postId) async {
    try {
      // Reference to the comments collection under the post
      CollectionReference commentsRef = _firestore
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments');

      // Get all comments under the post
      final QuerySnapshot commentsSnapshot = await commentsRef.get();

      // Iterate through each comment
      for (final QueryDocumentSnapshot commentDoc in commentsSnapshot.docs) {
        final String commentId = commentDoc.id;

        // Reference to the likes subcollection of the comment
        CollectionReference likesRef =
            commentsRef.doc(commentId).collection('likes');

        // Get the number of likes by counting the documents in the likes subcollection
        final QuerySnapshot likesSnapshot = await likesRef.get();
        final int newLikesCount = likesSnapshot.docs.length;

        // Get the current likes count stored in the comment document
        final int currentLikesCount = commentDoc['likesCount'];

        // Only update the document if there's a difference in the likes count
        if (newLikesCount != currentLikesCount) {
          // Update the likes count in the comment document
          await commentsRef.doc(commentId).update({'likesCount': newLikesCount});
        }
      }
    } catch (error) {
     
      print('Error updating likes count for post: $error');
      throw error; 
    }
  }

  Future<void> addComment(String topicId, String postId, String commentText) async {
    try {
      // Reference to the comments collection under the post
      CollectionReference commentsRef = _firestore
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments');

      // Add comment data
      await commentsRef.add({
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'commentText': commentText,
        'timestamp': Timestamp.now(),
        'likesCount': 0,
      });
    } catch (error) {
      // Handle errors here
      print('Failed to add comment: $error');
      throw error;
    }
  }

  Future<void> deleteComment(String topicId, String postId, String commentId) async {
    try {
      // Reference to the comment document
      DocumentReference commentRef = _firestore
          .collection('topics')
          .doc(topicId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      // Delete the comment
      await commentRef.delete();
    } catch (error) {
      // Handle errors here
      print('Failed to delete comment: $error');
      throw error;
    }
  }
Future<Users> getUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _firestore.collection('users').doc(userId).get();

    return Users(
      userId: userId,
      username: userSnapshot.data()!['username'],
      gender: userSnapshot.data()!['gender'],
      pfp: userSnapshot.data()!['pfp'],
    );
  }

  Future<void> updateUserProfile(String userId, String username, String gender, String profilePictureUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'username': username,
        'gender': gender,
        'pfp': profilePictureUrl,
      });
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  Future<void> updateUserProfilePicture(String userId, String profilePictureUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'pfp': profilePictureUrl,
      });
    } catch (e) {
      print('Error updating user profile picture: $e');
      throw e;
    }
  }
  

  //fetch topics
Future<List<Topic>> fetchTopics() async {
  List<Topic> topics = [];
  QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('topics').get();

  snapshot.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data();
    topics.add(Topic(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      icon: data['icon'], 
    ));
  });

  return topics;
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
}
Future<void> sendReply(String topicId, String postId, String commentId, String replyText) async {
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
  } catch (error) {
    // Handle errors
    print('Error sending reply: $error');
  }
}


}




