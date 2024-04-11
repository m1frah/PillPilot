import 'package:flutter/material.dart';


import '../../../widgets/friendsmedicineList.dart';

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