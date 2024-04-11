import 'dart:ffi';

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
        });
      }
    } catch (error) {
      print('Error fetching current user fcode: $error');
    }
  }

  void _addFriend() async {
    try {
      if (_friendFcode == _currentUserFcode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You cannot add yourself as a friend'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      QuerySnapshot<Map<String, dynamic>> usersSnapshot = await _firestore
          .collection('users')
          .where('fcode', isEqualTo: _friendFcode)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        String friendUserId = usersSnapshot.docs.first.id;

        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('friends')
            .doc(friendUserId)
            .set({'fcode': _friendFcode});

        await _firestore
            .collection('users')
            .doc(friendUserId)
            .collection('friends')
            .doc(_auth.currentUser!.uid)
            .set({'fcode': _currentUserFcode});

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
     double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              SizedBox(height: 50),
            Center(
              child: Text(
                "Your FriendCode:",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color:  Color.fromARGB(255, 53, 53, 53))
              ),
            ),
                       SizedBox(height: 50),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 221, 226, 255),
                  borderRadius: BorderRadius.circular(16),
                ),
               padding: EdgeInsets.symmetric(
            vertical: 40.0,
            horizontal: screenWidth * 0.33,
          ),
                child: Text(
                  _currentUserFcode,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,      color: Color.fromARGB(142, 44, 51, 173),),
                ),
              ),
            ),
             SizedBox(height: 50),
            Center(
              child: Text(
                "Enter a friend code to add friends!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400 , color: Color.fromARGB(255, 74, 74, 74)),
              ),
            ),
            SizedBox(height: 50),Center(
         child: Container(
  width: screenWidth * 0.8, // Adjust the percentage as per your requirement
  child: TextField(
    decoration: InputDecoration(
      labelText: 'Enter Friend\'s Friend Code',
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Colors.black),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
    style: TextStyle(color: Colors.black),
    onChanged: (value) {
      _friendFcode = value.trim();
    },
  ),
),
                ),    SizedBox(height: 100),
       Center(
  child: SizedBox(
    width: screenWidth * 0.6, 
    child: ElevatedButton.icon(
      onPressed: _addFriend,
      icon: Icon(Icons.person_add),
      label: Text('Add Friend'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 159, 168, 255),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20.0), 
      ),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}