import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../database/sql_helper.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  SyncService._internal();

  Timer? _syncTimer;

  // Initialize Firebase
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Start periodic synchronization
  void startSync({Duration interval = const Duration(hours: 1)}) {
    _syncTimer = Timer.periodic(interval, (timer) {
      syncData();
    });
  }


  void stopSync() {
    _syncTimer?.cancel();
  }


  Future<void> syncData() async {
    try {

      final List<Map<String, dynamic>> meds = await SQLHelper.getMeds();

      await syncMedsToFirebase(meds);
    } catch (e) {
      print('Error syncing data: $e');
    }
  }


Future<void> syncMedsToFirebase(List<Map<String, dynamic>> meds) async {
  final userUid = FirebaseAuth.instance.currentUser!.uid;
  final userRef = FirebaseFirestore.instance.collection('users').doc(userUid);
  final medicineRef = userRef.collection('medicine');

  // Get existing medicine documents
  final existingMedsSnapshot = await medicineRef.get();

  // Map existing medicine documents by ID
  final existingMedsMap = {
    for (final doc in existingMedsSnapshot.docs) doc.id: doc.data(),
  };

  // Sync medicine records
  for (final med in meds) {
    final medId = med['id'].toString(); // Assuming 'id' is the field in SQL representing the medicine ID
    final medRef = medicineRef.doc(medId);

    // Check if a similar record already exists
    final existingMed = existingMedsMap[medId];
    if (existingMed != null) {
      // Check if the record in Firestore differs from the record in SQL
      if (!mapsAreEqual(existingMed, med)) {
        // Update existing document
        await medRef.update(med);
      }
    } else {
      // Add new document
      await medRef.set(med);
    }
  }

  // Delete documents in Firestore that don't exist in SQL
  for (final existingMedId in existingMedsMap.keys) {
    if (!meds.any((med) => med['id'].toString() == existingMedId)) {
      await medicineRef.doc(existingMedId).delete();
    }
  }
}

// Utility function to check if two maps are equal
bool mapsAreEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
  if (map1.length != map2.length) return false;
  for (final key in map1.keys) {
    if (map1[key] != map2[key]) return false;
  }
  return true;
}

  
}




void main() async {
  final syncService = SyncService();
  await syncService.initializeFirebase();


  syncService.startSync();

}