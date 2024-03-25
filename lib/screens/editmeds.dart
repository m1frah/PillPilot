import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart'; // Import your SQL helper file

class EditMedsPage extends StatefulWidget {
  final Map<String, dynamic> medication;

  EditMedsPage({Key? key, required this.medication}) : super(key: key);

  @override
  _EditMedsPageState createState() => _EditMedsPageState();
}

class _EditMedsPageState extends State<EditMedsPage> {
  late TextEditingController _nameController;
  late TextEditingController _reasonController;
  late TextEditingController _daysController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing medication data
    _nameController = TextEditingController(text: widget.medication['name']);
    _reasonController = TextEditingController(text: widget.medication['reason']);
    _daysController = TextEditingController(text: widget.medication['days']);
    _timeController = TextEditingController(text: widget.medication['time']);
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _reasonController.dispose();
    _daysController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Update medication data in the database
    await SQLHelper.updateMed(
      widget.medication['id'],
      widget.medication['type'],
      _nameController.text,
      _reasonController.text,
      _daysController.text,
      _timeController.text,
    );
    // Navigate back to previous screen
    Navigator.pop(context);
  }

  Future<void> _deleteMedication() async {
    try {
      await SQLHelper.deleteMed(widget.medication['id']);
      Navigator.pop(context); // Navigate back after deletion
    } catch (err) {
      debugPrint("Error deleting medication: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Medication Name'),
            ),
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(labelText: 'Reason'),
            ),
            TextFormField(
              controller: _daysController,
              decoration: InputDecoration(labelText: 'Days'),
            ),
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _deleteMedication,
            style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
  ),
                  child: Icon(Icons.delete, color: Colors.white),
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