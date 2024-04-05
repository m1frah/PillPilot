import 'package:flutter/material.dart';
import 'sync_service.dart'; 

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