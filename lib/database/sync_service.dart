import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sql_helper.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import '../model/model.dart';
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  SyncService._internal();

  Timer? _syncTimer;

 
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

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
      final List<Map<String, dynamic>> meds = await SQLHelper.getLocalMeds();
      await syncMedsToFirebase(meds);
        print('Error syncing data: $meds');
    } catch (e) {
      print('Error syncing data: $e');
    }
  }


  Future<void> syncMedsToFirebase(List<Map<String, dynamic>> meds) async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userUid);
    final medicineRef = userRef.collection('medicine');

    final existingMedsSnapshot = await medicineRef.get();
    final existingMedsMap = {
      for (final doc in existingMedsSnapshot.docs) doc.id: doc.data(),
    };

    for (final med in meds) {
      final medId = "FB-${med['id']}"; // Add "FB-" prefix
      final medRef = medicineRef.doc(medId);

      final existingMed = existingMedsMap[medId];
      if (existingMed != null) {
        if (!mapsAreEqual(existingMed, med)) {
          await medRef.update(med);
        }
      } else {
        await medRef.set(med);
      }
    }

    for (final existingMedId in existingMedsMap.keys) {
      if (!meds.any((med) => "FB-${med['id']}" == existingMedId)) { // Check with "FB-" prefix
        await medicineRef.doc(existingMedId).delete();
      }
    }
  }

  bool mapsAreEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }  

Future<void> loadFirebaseDataToLocal() async {
  try {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userUid);
    final medicineRef = userRef.collection('medicine');

    final existingMedsSnapshot = await medicineRef.get();

    for (final doc in existingMedsSnapshot.docs) {
final medId = int.tryParse(doc.id.substring(3)) ?? 0;

   print (medId);
      final medData = doc.data() as Map<String, dynamic>;

      final existingMedLocally = await SQLHelper.getMedById(medId);

      if (existingMedLocally == null) {
        final missingMed = Medication(
          type: medData['type'],
          name: medData['name'],
          reason: medData['reason'],
          days: medData['days'],
          time: medData['time'],
   
        );

        await SQLHelper.createFBMed(missingMed);
      }
    }
  } catch (e) {
    print('Error loading Firebase data to local: $e');
  }
}
}
void main() async {
  final syncService = SyncService();
  await syncService.initializeFirebase();


  syncService.startSync();

}