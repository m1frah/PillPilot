// i shuld move firebase operations here for code 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
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

UserPfp(String userId) async {
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
  