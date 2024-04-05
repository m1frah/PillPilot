import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addfriends.dart';
import '../../database/firebaseoperations.dart';

import 'package:flutter/material.dart';
import '../../widgets/friendsmedslist.dart'; 
class FriendsMedsPage extends StatelessWidget {
  final String friendUserId;

  const FriendsMedsPage({Key? key, required this.friendUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend\'s Medication'),
      ),
      body: FirebaseMedicationListWidget(userId: friendUserId), 
    );
  }
}