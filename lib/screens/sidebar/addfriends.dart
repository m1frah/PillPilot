import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFriendsPage extends StatefulWidget {
  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _currentUserFcode = ''; 
  String _friendFcode = ''; 

  @override
  void initState() {
    super.initState();
    _getCurrentUserFcode(); 
  }


  void _getCurrentUserFcode() async {
    try {

      String userId = _auth.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        setState(() {
          
          _currentUserFcode = userSnapshot.data()!['fcode'] ?? '';
          print(_currentUserFcode);
        });
      }
    } catch (error) {
      print('Error fetching current user fcode: $error');
    }
  }

  // Method to add friend
 void _addFriend() async {
  try {
    // Check if the entered fcode is the same as the current user's fcode
    if (_friendFcode == _currentUserFcode) {
      // Show a snackbar indicating that the user cannot add themselves as a friend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot add yourself as a friend'),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Exit the method
    }

    // Query Firestore to find the user with the entered fcode
    QuerySnapshot<Map<String, dynamic>> usersSnapshot = await _firestore
        .collection('users')
        .where('fcode', isEqualTo: _friendFcode)
        .get();


    if (usersSnapshot.docs.isNotEmpty) {
 
      String friendUserId = usersSnapshot.docs.first.id;


      await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('friends').doc(friendUserId).set({
        'fcode': _friendFcode,
      });


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No user found with the entered fcode'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (error) {
    print('Error adding friend: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue, 
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Your fcode: $_currentUserFcode',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Friend\'s fcode',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _friendFcode = value.trim();
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _addFriend();
              },
              child: Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}