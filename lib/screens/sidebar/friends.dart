import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addfriends.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
void _removeFriend(String friendId) async {
  try {
    // Remove the friend from the friends list in the database
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('friends')
        .doc(friendId)
        .delete();
  } catch (e) {
    print('Error removing friend: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('users').doc(_auth.currentUser!.uid).collection('friends').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<QueryDocumentSnapshot<Map<String, dynamic>>> friendDocs = snapshot.data!.docs;
          if (friendDocs.isEmpty) {
            return Center(child: Text('No friends added yet'));
          }
          return Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40.0), 
                  child:ListView.builder(
  itemCount: friendDocs.length,
  itemBuilder: (context, index) {
    String friendId = friendDocs[index].id;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4.0,
        child: ListTile(
          leading: CircleAvatar(), 
          title: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: _firestore.collection('users').doc(friendId).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...');
              }
              if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
          
                _removeFriend(friendId);
                return SizedBox(); 
              }
              String friendUsername = userSnapshot.data!.data()!['username'] ?? '';
              return Text(friendUsername);
            },
          ),
        ),
      ),
    );
  },
),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFriendsPage()),
                  );
                },
                child: Text('Add Friends'),
              ),
            ],
          );
        },
      ),
    );
  }
}