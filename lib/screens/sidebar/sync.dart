import 'package:flutter/material.dart';
import '../../database/sync_service.dart'; 

class SyncPage extends StatelessWidget {
  final SyncService syncService = SyncService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await syncService.initializeFirebase();
                await syncService.loadFirebaseDataToLocal();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data loaded from Firebase to local!'),
                  ),
                );
              },
              child: Text('Load Data from Firebase to Local'),
            ),
            SizedBox(height: 16), 
            ElevatedButton(
              onPressed: () async {
                await syncService.initializeFirebase();
                await syncService.syncData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data synced successfully!'),
                  ),
                );
              },
              child: Text('Sync Data'),
            ),
          ],
        ),
      ),
    );
  }
}
