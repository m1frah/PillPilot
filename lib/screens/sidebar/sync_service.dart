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


  final existingMedsSnapshot = await medicineRef.get();

  final existingMedsData = existingMedsSnapshot.docs.map((doc) => doc.data()).toList();

  for (final med in meds) {

    if (!existingMedsData.contains(med)) {
      await medicineRef.add(med);
    }
  }
}




void main() async {
  final syncService = SyncService();
  await syncService.initializeFirebase();


  syncService.startSync();

}}