// i shuld move firebase operations here for code 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

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


  