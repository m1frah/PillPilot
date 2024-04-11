import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart';

class EditMedsPage extends StatefulWidget {
  final Map<String, dynamic> medication;

  EditMedsPage({Key? key, required this.medication}) : super(key: key);

  @override
  _EditMedsPageState createState() => _EditMedsPageState();
}

class _EditMedsPageState extends State<EditMedsPage> {
  late TextEditingController _nameController;
  late TextEditingController _reasonController;
  late TextEditingController _timeController;

  List<bool> _selectedDays = [false, false, false, false, false, false, false];
  List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.medication['name']);
    _reasonController = TextEditingController(text: widget.medication['reason']);
    _timeController = TextEditingController(text: widget.medication['time']);
    _selectedDays = widget.medication['days'].toString().split('').map((e) => e == '1').toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    String days = _selectedDays.map((selected) => selected ? '1' : '0').join('');
    String time = _timeController.text; 

    await SQLHelper.updateMed(
      widget.medication['id'],
      widget.medication['type'],
      _nameController.text,
      _reasonController.text,
      days,
      time,
    );

    Navigator.pop(context, true);
  }

  Future<void> _deleteMedication() async {
    try {
      await SQLHelper.deleteMed(widget.medication['id']);
      Navigator.pop(context, true);
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
            SizedBox(height: 20),
            Text('Days'),
            SizedBox(height: 10),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: List.generate(
                _daysOfWeek.length,
                (index) => ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDays[index] = !_selectedDays[index];
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey; // Disabled color
                        }
                        return _selectedDays[index] ? Colors.blue : Colors.grey;
                      },
                    ),
                  ),
                  child: Text(
                    _daysOfWeek[index],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _timeController,
              readOnly: true, // Make the field read-only
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(_timeController.text.split(':')[0]),
                    minute: int.parse(_timeController.text.split(':')[1]),
                  ),
                );
                if (pickedTime != null) {
                  setState(() {
                    _timeController.text = '${pickedTime.hour}:${pickedTime.minute}';
                  });
                }
              },
              decoration: InputDecoration(labelText: 'Time'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _deleteMedication(),
                  icon: Icon(Icons.delete, color: Colors.white),
label: Text(
    'Delete',
    style: TextStyle(color: Colors.white),
  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _saveChanges(),
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
