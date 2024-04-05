// should probs create classes for adding meds, appointmetts later
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;


class SQLHelper{
  static Future<void> createTables(sql.Database database) async{
  await database.execute('''
  CREATE TABLE medicine(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    type TEXT,
    name TEXT,
    reason TEXT,
    days TEXT DEFAULT 0000000, 
    time TEXT DEFAULT '00-00'
  )
''');  await database.execute('''
      CREATE TABLE IF NOT EXISTS appointment(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        location TEXT,
        dateTime TEXT
      )
    ''');
        
  }
  static Future<sql.Database> db() async{
    return sql.openDatabase('pills5.db', version:1, onCreate:(sql.Database database, int version) async{
      await createTables(database);
    },);

  } 
//add medcs
  static Future<int> createMed(String type, String name, String reason,String days, String time) async  {
    final db = await SQLHelper.db();
    final data ={'type':type,'name':name,'reason':reason,'days': days,'time': time};
    final id = await  db.insert('medicine',data ,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;

  }
  //add appointments
  static Future<int> createApp(String title, String location, String dateTime) async  {
    final db = await SQLHelper.db();
    final data ={'title':title,'location':location,'dateTime':dateTime};
    final id = await  db.insert('appointment',data ,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;

  }
//gets al meds
  static Future<List<Map<String, dynamic>>> getMeds() async{
    final db =await SQLHelper.db();
    return db.query('medicine', orderBy: "id");

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
  }
