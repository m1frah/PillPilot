import 'package:flutter/material.dart';
import '../api/notification.dart'; // Import your NotificationManager

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Test Notification'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              final now = DateTime.now();
              final scheduledDate = now.add(Duration(seconds: 5)); // 5 seconds from now
              NotificationManager.showScheduledNotification(
                title: 'Scheduled Notification',
                body: 'This is a scheduled notification!',
                scheduledDate: scheduledDate,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification scheduled for $scheduledDate'),
                ),
              );
            },
            child: Text('Schedule Notification'),
          ),
        ),
      ),
    );
  }
}