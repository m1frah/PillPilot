import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:pillapp/database/sql_helper.dart';

class AddAppointmentPage extends StatefulWidget {
  @override
  _AddAppointmentPageState createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  DateTime? _selectedDateTime;
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  Future<void> _addAppointment() async {
    if (_selectedDateTime != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      final String formattedDateTime = formatter.format(_selectedDateTime!);

      final int id = await SQLHelper.createApp(
        _titleController.text,
        _locationController.text,
        formattedDateTime,
      );

      if (id != -1) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment added successfully'),
            backgroundColor: Colors.green,
          ),
        );

      
        _titleController.clear();
        _locationController.clear();
        setState(() {
          _selectedDateTime = null;
        });
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
   
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            DateTimeField(
              decoration: InputDecoration(
                labelText: 'Date and Time',
                border: OutlineInputBorder(),
              ),
              format: DateFormat("yyyy-MM-dd HH:mm"),
              onShowPicker: (context, currentValue) async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  return DateTimeField.combine(date, time);
                } else {
                  return currentValue;
                }
              },
              onChanged: (value) {
                setState(() {
                  _selectedDateTime = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addAppointment,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}