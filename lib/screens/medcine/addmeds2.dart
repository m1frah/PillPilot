import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart';
import 'addmeds.dart';

class AddMedicinePage2 extends StatefulWidget { final String selectedType;
  final String name;
  final String reason;

  const AddMedicinePage2({
    required this.selectedType,
    required this.name,
    required this.reason,
  });
  @override
  _AddMedicinePage2State createState() => _AddMedicinePage2State();
}

class _AddMedicinePage2State extends State<AddMedicinePage2> {
  
  String _selectedTime = '';
  List<bool> _selectedDays = [false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Repetition Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            ElevatedButton(
              onPressed: () { //maybe change the time picker to better design
                _showTimePicker();
              },
              child: Text('Select Time'),
            ),
            SizedBox(height: 16),
            Text(
              'Select Repetition Days:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
        
            for (int i = 0; i < 7; i++)
              CheckboxListTile(
                title: Text(_getDayName(i)),
                value: _selectedDays[i],
                onChanged: (value) {
                  setState(() {
                    _selectedDays[i] = value!;
                  });
                },
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
          
                await _saveDetails();
        
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime.format(context);
      });
    }
  }

  String _getDayName(int index) {
    switch (index) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return '';
    }
  }

Future<void> _saveDetails() async {

String days = '';
for (int i = 6; i >= 0; i--) {
  if (_selectedDays[i]) {
    days += '1';
  } else {
    days += '0';
  }
}
print("days is $days");

    await SQLHelper.createMed(widget.selectedType,
      widget.name,
      widget.reason,
      days,
      _selectedTime,
    );
  }
}