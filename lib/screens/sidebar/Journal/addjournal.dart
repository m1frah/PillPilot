import 'package:flutter/material.dart';
import '../../../database/sql_helper.dart';
import '../../../model/model.dart';

class AddJournalPage extends StatefulWidget {
  @override
  _AddJournalPageState createState() => _AddJournalPageState();
}

final List<Map<String, dynamic>> moodList = [
  {'label': 'Happy', 'color': Colors.amber},
  {'label': 'Sad', 'color': Colors.indigo},
  {'label': 'Angry', 'color': Colors.red},
  {'label': 'Calm', 'color': Colors.green},
  {'label': 'Scared', 'color': Colors.purple},
  {'label': 'Tired', 'color': Colors.blueGrey},
  {'label': 'Energetic', 'color': Colors.orange},
  {'label': 'Shy', 'color': Colors.pink},
  {'label': 'Confident', 'color': Colors.teal},
];

class _AddJournalPageState extends State<AddJournalPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String _selectedMood = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Journal'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                ),
                maxLines: null,
              ),
              SizedBox(height: 16.0),
              Text('Select Mood:', style: TextStyle(fontSize: 16.0)),
              SizedBox(height: 8.0),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: moodList.map((mood) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedMood = mood['label'];
                                });
                              },
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedMood == mood['label'] ? mood['color'].shade800 : Colors.transparent,
                                    width: 2.0,
                                  ),
                                  color: mood['color'],
                                ),
                                child: Icon(
                                  Icons.circle,
                                  color: _selectedMood == mood['label'] ? mood['color'].shade800 : Colors.white,
                                  size: 30.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: 14.0,
                                color: _selectedMood == mood['label'] ? mood['color'].shade800 : Colors.grey,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  saveJournal();
                },
                child: Text('Save Journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveJournal() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    String createDate = DateTime.now().toString();

    JournalEntry entry = JournalEntry(
      id: 0,
      title: title,
      content: content,
      createDate: createDate,
      mood: _selectedMood,
    );

    await SQLHelper.insertJournal(entry);

    Navigator.of(context).pop(); 
  }
}