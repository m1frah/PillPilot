import 'package:flutter/material.dart';
import '../widgets/medcinelist.dart'; // Import the file where you have defined MedicationListWidget
import 'addmeds.dart'; // Import AddMedsPage

class MedicationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication List'),
      ),
      body: MedicationListWidget(), // Place MedicationListWidget here
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddMedsPage when FloatingActionButton is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicinePage()),
          );
        },
        tooltip: 'Add Medicine',
        child: Icon(Icons.add),
      ),
    );
  }
}