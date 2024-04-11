    import 'package:flutter/material.dart';
    import 'package:sqflite/sqflite.dart' as sql;
    import '../../../database/sql_helper.dart'; // Assuming you have defined the SQLHelper class in a separate file
    import '../../../model/model.dart'; // Import the JournalEntry model
    import 'addjournal.dart';

    class EditJournalPage extends StatefulWidget {

      final JournalEntry initialJournalEntry; // Change to initialJournalEntry of type JournalEntry

      const EditJournalPage({
        Key? key,
  
        required this.initialJournalEntry, // Change to initialJournalEntry of type JournalEntry
      }) : super(key: key);

      @override
      _EditJournalPageState createState() => _EditJournalPageState();
    }

    class _EditJournalPageState extends State<EditJournalPage> {
      late TextEditingController _titleController;
      late TextEditingController _contentController;
      late String _selectedMood;

      @override
      void initState() {
        super.initState();
        // Initialize controllers with initial values from the passed JournalEntry
        _titleController = TextEditingController(text: widget.initialJournalEntry.title);
        _contentController = TextEditingController(text: widget.initialJournalEntry.content);
        _selectedMood = widget.initialJournalEntry.mood;
      }

        @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Edit Journal'),
          ),
          body: Padding(
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
                    if (constraints.maxWidth < 600) {
                      // Wrap Row in SingleChildScrollView and Wrap for smaller screens
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
                    } else {
                      // Keep the original Row for larger screens
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      );
                    }
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _deleteJournal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Background color
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 4.0),
                          Text('Delete'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _updateJournal();
                      },
                      child: Text('Update Journal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      void _updateJournal() async {
        String title = _titleController.text.trim();
        String content = _contentController.text.trim();
        String createDate = widget.initialJournalEntry.createDate; // Original create date
    print(" hellooooo    $title $content $createDate");
        JournalEntry updatedEntry = JournalEntry(
          id: widget.initialJournalEntry.id,
          title: title,
          content: content,
          createDate:widget.initialJournalEntry.createDate,
          mood: _selectedMood,
        );

    
        await SQLHelper.updateJournal(
       
    
          updatedEntry,
        );

        Navigator.of(context).pop();
      }

      void _deleteJournal() async {

        await SQLHelper.deleteJournal(widget.initialJournalEntry.id,);
     

        Navigator.of(context).pop();

    }}
