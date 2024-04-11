import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert'; // For JSON encoding and decoding

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // Initialize the plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Initialize the notification plugin
    initializeNotifications();
  }

  // Initialize notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Print scheduled notifications
 // Print scheduled notifications
Future<void> printScheduledNotifications() async {
  final List<PendingNotificationRequest> pendingNotifications =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  print('List of scheduled notifications:');
  for (final notification in pendingNotifications) {
    print('Notification ID: ${notification.id}');
    print('Notification Title: ${notification.title}');
    print('Notification Body: ${notification.body}');
    final Map<String, dynamic> payloadData = json.decode(notification.payload!);
    final int medicineId = payloadData['medicineId'];
    print('Medicine ID: $medicineId');
    final String? title = notification.title;
    
    print('----------------------');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            printScheduledNotifications();
          },
          child: Text('Print Scheduled Notifications'),
        ),
      ),
    );
  }
}
