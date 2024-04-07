import 'package:flutter/material.dart';
import '../api/notification.dart';

class NotificationTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _scheduleNotification();
          },
          child: Text('Schedule Notification'),
        ),
      ),
    );
  }

  void _scheduleNotification() {
    // Define the title and body of the notification
    String title = 'Test Notification';
    String body = 'This is a scheduled notification test.';

    // Get the current date and time
    DateTime now = DateTime.now();

    // Schedule the notification 5 seconds from now
    DateTime scheduledDate = now.add(Duration(seconds: 5));

    // Call the showScheduledNotification method from your NotificationManager
    NotificationManager.showScheduledNotification(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );

    
 
  }
}