import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart';

class AddMedicinePage2 extends StatefulWidget {
  final String selectedType;
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
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Time:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
               SizedBox(height: 16),
              Text(
                ' $_selectedTime',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _showTimePicker();
                },
                icon: Icon(Icons.access_time),
                label: Text('Select Time'),
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
                },
                child: Text('Save'),
              ),
            ],
          ),
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
      case 6:
        return 'Monday';
      case 5:
        return 'Tuesday';
      case 4:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 2:
        return 'Friday';
      case 1:
        return 'Saturday';
      case 0:
        return 'Sunday';
      default:
        return '';
    }
  }

  Future<void> _saveDetails() async {
    bool isAtLeastOneDaySelected = _selectedDays.any((day) => day);
    if (!isAtLeastOneDaySelected || _selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one repetition day and a time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String days = '';
    for (int i = 6; i >= 0; i--) {
      if (_selectedDays[i]) {
        days += '1';
      } else {
        days += '0';
      }
    }
    print("days is $days");

    await SQLHelper.createMed(
      widget.selectedType,
      widget.name,
      widget.reason,
      days,
      _selectedTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medicine added successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}