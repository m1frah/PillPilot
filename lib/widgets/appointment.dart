import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart'; 
import '../screens/appointments/editappointments.dart';

class AppointmentListWidget extends StatefulWidget {
  @override
  _AppointmentListWidgetState createState() => _AppointmentListWidgetState();
}

class _AppointmentListWidgetState extends State<AppointmentListWidget> {
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    List<Map<String, dynamic>> appointments = await SQLHelper.getApps();
    setState(() {
      _appointments = appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10), 
            child: Card(
              elevation: 4,
              child: GestureDetector(
                onTap: () {
             
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAppointmentPage(appointment: appointment),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.all(16), 
                  leading: Icon(Icons.event),
                  title: Text(
                    appointment['title'],
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location: ${appointment['location']}',
                        style: TextStyle(fontSize: 16), 
                      ),
                      Text(
                        'Date and Time: ${appointment['dateTime']}',
                        style: TextStyle(fontSize: 16), 
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}