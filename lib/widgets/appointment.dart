import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart'; // Import your SQL helper file
import '/screens/editappointments.dart'; // Import your edit appointment page

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
      padding: const EdgeInsets.symmetric(horizontal: 16), // Add horizontal padding
      child: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10), // Increase vertical padding between items
            child: Card(
              elevation: 4, // Add shadow effect
              child: GestureDetector(
                onTap: () {
                  // Navigate to edit appointment page when appointment item is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAppointmentPage(appointment: appointment),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.all(16), // Increase content padding
                  leading: Icon(Icons.event), // You can change the icon as needed
                  title: Text(
                    appointment['title'],
                    style: TextStyle(fontSize: 18), // Increase font size of title
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location: ${appointment['location']}',
                        style: TextStyle(fontSize: 16), // Increase font size of subtitle
                      ),
                      Text(
                        'Date and Time: ${appointment['dateTime']}',
                        style: TextStyle(fontSize: 16), // Increase font size of subtitle
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