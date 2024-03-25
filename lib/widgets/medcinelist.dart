import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart'; // Import your SQL helper file
import '../screens/editmeds.dart';
class MedicationListWidget extends StatefulWidget {
  @override
  _MedicationListWidgetState createState() => _MedicationListWidgetState();
}

class _MedicationListWidgetState extends State<MedicationListWidget> {
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    List<Map<String, dynamic>> medications = await SQLHelper.getMeds();
    setState(() {
      _medications = medications;
    });
  }

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ListView.builder(
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
            onTap: () {
              // Navigate to the edit medications page passing the medication data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMedsPage(medication: medication),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: _buildIcon(medication['type']),
                title: Text(
                  medication['name'],
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  medication['reason'],
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  medication['time'], // Display the time here
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
  Widget _buildIcon(String type) {
    String imagePath;
    switch (type.toLowerCase()) {
      case 'pills':
        imagePath = 'assets/pill.png';
        break;
      case 'injection':
        imagePath = 'assets/injection_icon.png';
        break;
      case 'syrups':
        imagePath = 'assets/syrup.png';
        break;
      default:
        imagePath = 'assets/syringe.png';
    }
    return Image.asset(
      imagePath,
      width: 40,
      height: 40,
    );
  }
}