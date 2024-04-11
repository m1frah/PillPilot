import 'package:flutter/material.dart';

import 'addmeds2.dart';

class AddMedicinePage extends StatefulWidget {
  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  String _selectedType = "Pills";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medicine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              items: ['Pills', 'Injections', 'Syrups']
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                errorText: _nameController.text.trim().isEmpty && _nameController.text.isNotEmpty ? 'Name is required' : null,
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
                errorText: _reasonController.text.trim().isEmpty && _reasonController.text.isNotEmpty ? 'Reason is required' : null,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if ((_nameController.text.trim().isNotEmpty || _nameController.text.isNotEmpty) &&
                    (_reasonController.text.trim().isNotEmpty || _reasonController.text.isNotEmpty)) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddMedicinePage2(
                      selectedType: _selectedType,
                      name: _nameController.text,
                      reason: _reasonController.text,
                    )),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}









