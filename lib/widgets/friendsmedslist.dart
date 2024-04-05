import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMedicationListWidget extends StatelessWidget {
  final String userId;

  const FirebaseMedicationListWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('medicine').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<QueryDocumentSnapshot<Map<String, dynamic>>> medDocs = snapshot.data!.docs;
        if (medDocs.isEmpty) {
          return Center(child: Text('No meds for this friend'));
        }
        return ListView.builder(
          itemCount: medDocs.length,
          itemBuilder: (context, index) {
            final medication = medDocs[index].data();
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: () {
                  // Add navigation to edit medication page here if needed
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
        );
      },
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
  }}