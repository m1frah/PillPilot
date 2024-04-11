import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart';

class EditAppointmentPage extends StatefulWidget {
  final Map<String, dynamic> appointment;

  EditAppointmentPage({Key? key, required this.appointment}) : super(key: key);

  @override
  _EditAppointmentPageState createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _dateTimeController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.appointment['title']);
    _locationController = TextEditingController(text: widget.appointment['location']);
    _dateTimeController = TextEditingController(text: widget.appointment['dateTime']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    await SQLHelper.updateApp(
      widget.appointment['id'],
      _titleController.text,
      _locationController.text,
      _dateTimeController.text,
    );

    Navigator.pop(context);
  }

  Future<void> _deleteAppointment() async {
    try {
      await SQLHelper.deleteApp(widget.appointment['id']);
      Navigator.pop(context);
    } catch (err) {
      debugPrint("Error deleting appointment: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Appointment Title'),
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            TextFormField(
              controller: _dateTimeController,
              decoration: InputDecoration(labelText: 'Date and Time'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _deleteAppointment,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
