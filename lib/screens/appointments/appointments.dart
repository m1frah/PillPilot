import 'package:flutter/material.dart';
import '../../widgets/appointmenList.dart';
import 'addappointment.dart'; 

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment List'),
      ),
      body: AppointmentListWidget(), 
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppointmentPage()),
          );
        },
        tooltip: 'Add Appointment',
        child: Icon(Icons.add),
      ),
    );
  }
}   