import 'package:flutter/material.dart';
import '../../widgets/medicineList.dart';
import 'addmeds.dart';
class MedicationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication List'),
      ),
      body: MedicationListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
   
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicinePage())
          );
        },
        tooltip: 'Add Medicine',
        child: Icon(Icons.add),
      ),
    );
  }
}