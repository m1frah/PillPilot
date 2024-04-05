import 'package:flutter/material.dart';
import 'package:pillapp/database/sql_helper.dart'; 
import '../screens/medcine/editmeds.dart';

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

  Widget _buildDaysHighlight(String days) {

    List<String> dayAbbreviations = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        days.length,
        (index) {
  
          if (days[index] == '1') {
            return Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                dayAbbreviations[index],
                style: TextStyle(
                  fontSize: 11,
                  color: Color.fromARGB(151, 196, 12, 12), // Highlight in red
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                dayAbbreviations[index],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey, // Inactive days in gray
                ),
              ),
            );
          }
        },  
      ),
    );
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
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        medication['name'],
        style: TextStyle(fontSize: 18),
      ),
      Text(
        medication['time'], 
        style: TextStyle(fontSize: 16, color: Color.fromARGB(143, 0, 0, 0)),
      ),
    ],
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        medication['reason'],
        style: TextStyle(fontSize: 16),
      ),
      _buildDaysHighlight(medication['days']),
    ],
  ),
),
              ),
            ),
          );
        },
      ),
    );
  }}