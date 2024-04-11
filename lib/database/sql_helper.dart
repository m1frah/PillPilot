// should probs create classes for adding meds, appointmetts later
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import '../api/localnotifications.dart'; 
import '../model/model.dart';
class SQLHelper{
  static Future<void> createTables(sql.Database database) async{
  await database.execute('''
  CREATE TABLE medicine(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    type TEXT,
    name TEXT,
    reason TEXT,
    days TEXT DEFAULT 0000000, 
    time TEXT DEFAULT '00-00',
    local TEXT DEFAULT 'True'
  )
''');  await database.execute('''
      CREATE TABLE IF NOT EXISTS appointment(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        location TEXT,
        dateTime TEXT
      )
    ''');
  
  await database.execute('''
      CREATE TABLE IF NOT EXISTS journal(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        content TEXT,
        createDate TEXT,
        mood TEXT
        )
    ''');
        
  }
  static Future<sql.Database> db() async{
    return sql.openDatabase('pillsV4.db', version:1, onCreate:(sql.Database database, int version) async{
      await createTables(database);
    },);

  } 
//add medcs
static Future<int> createMed(String type, String name, String reason, String days, String time) async {
  final db = await SQLHelper.db();
  final data = {'type': type, 'name': name, 'reason': reason, 'days': days, 'time': time};
  final  id = await db.insert('medicine', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

  // Call scheduleNotifications to schedule notifications for the new medicine
  await LocalNotifications.scheduleNotifications(id, days, time, name);

  return id;
}

//addfbase meds
static Future<int> createFBMed(missingMed) async {

  final db = await SQLHelper.db();
  final data = {'type': missingMed.type, 'name': missingMed.name, 'reason': missingMed.reason, 'days': missingMed.days, 'time': missingMed.time, 'local': 'False'};
  final id =await db.insert('medicine', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

  // Call scheduleNotifications to schedule notifications for the new medicine
  // await LocalNotifications.scheduleNotifications(int.parse(missingMed.id), days, time, name);

  return id;
}
  //add appointments  
 static Future<int> createApp(String title, String location, String dateTime) async {
  final db = await SQLHelper.db();
  final data = {'title': title, 'location': location, 'dateTime': dateTime};
  final id = await db.insert('appointment', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

  // Parse dateTime to a DateTime object
  DateTime appointmentDateTime = DateTime.parse(dateTime);

  // Schedule notification
  await LocalNotifications.showScheduleNotification(
    title: 'Appointment Reminder: $title',
    body: 'You have an appointment at $location at ${appointmentDateTime.hour}:${appointmentDateTime.minute}',
    payload: id.toString(), // Associating appointment id with notification id
  );

  return id;
}//get med by id
 static Future<Map<String, dynamic>?> getMedById(int id) async {
    final db = await SQLHelper.db();
    final result = await db.query('medicine', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
//gets al meds
  static Future<List<Map<String, dynamic>>> getMeds() async{
    final db =await SQLHelper.db();
    return db.query('medicine', orderBy: "id");

  }
  static Future<List<Map<String, dynamic>>> getLocalMeds() async {
  final db = await SQLHelper.db();
  return db.query('medicine', where: 'local = ?', whereArgs: ['True'], orderBy: "id");
}
//getsall appointments
   static Future<List<Map<String, dynamic>>> getApps() async{
    final db =await SQLHelper.db();
    return db.query('appointment', orderBy: "id");

  }
 //get appointments for specific day for calender
static Future<List<Map<String, dynamic>>> getAppsForDay(String date) async {
  final db = await SQLHelper.db();
  final appointments = await db.query(
    'appointment',
    where: "DATE(dateTime) = DATE(?)",
    whereArgs: [date],
    limit: 100,
  );
  return appointments;
}
//get medcines based on what weekday its is 
static Future<List<Map<String, dynamic>>> getMedicinesForDay(int dayOfWeek) async {
  final db = await SQLHelper.db();
  final medicines = await db.rawQuery(
    'SELECT * FROM medicine WHERE SUBSTR(days, ?, 1) = "1"',
    [(dayOfWeek)],
  );
  print('Medicines for day: $medicines');
  return medicines;
}
//gets single med
    static Future<List<Map<String, dynamic>>> getMed(int id) async{
    final db =await SQLHelper.db();
    return db.query('medicine', where: "id = ?", whereArgs: [id],limit: 1);

  }
// update med 
static Future<int> updateMed(int id, String type, String name, String reason,String days, String time) async{
    final db =await SQLHelper.db();
    final data ={'type':type,'name':name,'reason':reason,'days': days,'time': time};
  final result = await db.update('medicine', data, where: "id = ?", whereArgs: [id]);
  return result;

    }
    
static Future<void> deleteMed(int id) async{
    final db =await SQLHelper.db();
try{
    await db.delete('medicine',where: "id = ?", whereArgs: [id]);
 }catch(err){
 debugPrint("something went wrong: $err");
}
    }

  static Future<void> deleteNonLocalMeds() async {
  try {
    final db = await SQLHelper.db();
    await db.delete('medicine', where: 'local = ?', whereArgs: ['False']);
  } catch (err) {
    debugPrint("Something went wrong: $err");
  }
}


    // update appointments 
static Future<int> updateApp(int id, String title, String location, String dateTime) async{
    final db =await SQLHelper.db();
final data ={'title':title,'location':location,'dateTime':dateTime};
  final result = await db.update('appointment', data, where: "id = ?", whereArgs: [id]);
  return result;

    }
    // del appoinmets
static Future<void> deleteApp(int id) async{
    final db =await SQLHelper.db();
try{
      await db.delete('appointment',where: "id = ?", whereArgs: [id]);
 }catch(err){
 debugPrint("something went wrong: $err");
}
    }


    //Journal related sql
  //create journal
// Insert a journal entry into the database

static Future<int> insertJournal(JournalEntry entry) async {
  final db = await SQLHelper.db();
  final data = {'title': entry.title, 'createDate': entry.createDate, 'mood': entry.mood, 'content': entry.content};
  final id = await db.insert('journal', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

  return id;
}
// Update a journal entry in the database

static Future<int> updateJournal(JournalEntry entry) async{
    final db =await SQLHelper.db();
final data ={'title': entry.title,  'mood': entry.mood, 'content': entry.content};;
  final result = await db.update('journal', data, where: "id = ?", whereArgs: [entry.id]);
  return result;

    }
// Fetch all journal entries from the database


  // Delete a journal
 static Future<List<Map<String, dynamic>>> getJournals() async{
    final db =await SQLHelper.db();
    return db.query('journal', orderBy: "id");

  }
  
  //get all jounals
static Future<void> deleteJournal(int id) async{
    final db =await SQLHelper.db();
try{
      await db.delete('journal',where: "id = ?", whereArgs: [id]);
 }catch(err){
 debugPrint("something went wrong: $err");
}
    }
}
  
