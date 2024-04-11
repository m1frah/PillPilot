import 'package:flutter/material.dart';
import '../../../database/sql_helper.dart';
import 'addjournal.dart';
import 'jounalitems.dart';
import '../../../model/model.dart';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<JournalEntry> journals = [];

  @override
  void initState() {
    super.initState();

    fetchJournals();
  }

void fetchJournals() async {
  List<Map<String, dynamic>> fetchedJournals = await SQLHelper.getJournals();


  List<JournalEntry> journalEntries = fetchedJournals.map((journalMap) {

  
    return JournalEntry(
     id:journalMap['id'],
      title: journalMap['title'],
      content: journalMap['content'],
      createDate: journalMap['createDate'],
      mood: journalMap['mood'],
    );
  }).toList();

  setState(() {
    journals = journalEntries;
  });

 
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Page'),
      ),
      body: ListView.builder(  
        itemCount: journals.length,
        itemBuilder: (context, index) {
          return JournalItem(

            journalEntry: journals[index], 
          
          );
        },
      ),
     floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddJournalPage()),
    ).then((_) {
    
      fetchJournals();
    });
  },
  child: Icon(Icons.add),
),
    );
  }
}
