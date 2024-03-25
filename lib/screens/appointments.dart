import 'package:flutter/material.dart';
import '../widgets/appointment.dart'; // Import the file where you have defined AppointmentListWidget
import '../addappointment.dart'; // Import AddAppointmentPage

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment List'),
      ),
      body: AppointmentListWidget(), // Place AppointmentListWidget here
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddAppointmentPage when FloatingActionButton is pressed
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