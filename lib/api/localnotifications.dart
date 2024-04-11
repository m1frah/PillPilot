import 'dart:async';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';
class LocalNotifications  {
    static late final tz.Location _local; 
  static  final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

// on tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }

// initialize the local notifications
  static Future init() async {
  
      tz.initializeTimeZones();
  _local = tz.local;
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const  AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) =>null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final  InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    // request notification permissions 
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // show a simple notification
  static Future showSimpleNotification({
    required  String title,
    required  String body,
    required  String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  // to show periodic notification at regular interval
  static Future showPeriodicNotifications({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
  const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.periodicallyShow(
        1, title, body, RepeatInterval.everyMinute, notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle ,
        payload: payload);
  }

  // to schedule a local notification
  static Future showScheduleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    tz.initializeTimeZones();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  // close a specific channel notification
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // close all the notifications available
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

   static int _generateNotificationId(int medId, int i) {
    // Example of how you might generate a unique ID
    print(('$medId and $i'));
    // You can adjust this based on your actual implementation
    return  int.parse('$medId$i');
  }

  // Function to schedule notifications
  static Future<void> scheduleNotifications(int medId, String days, String time, String name) async {
  // Cancel existing notifications associated with the medicine ID
  ByteData iconByteData = await rootBundle.load('assets/pill.png');
  final Uint8List iconBytes = iconByteData.buffer.asUint8List();
  for (int i = 0; i < days.length; i++) {
    await _flutterLocalNotificationsPlugin.cancel(_generateNotificationId(medId, i));
  }

  // Parse days string to determine which days to repeat
  for (int i = 0; i < days.length; i++) {
    if (days[i] == '1') {
      DateTime now = DateTime.now();
      int currentWeekday = now.weekday; // Get the current weekday (1 for Monday, 7 for Sunday)
      int desiredWeekday = (i + 1) % 7; // Adjust the desired weekday index to match DateTime's weekday (1 for Monday, 7 for Sunday)
      int daysToAdd = desiredWeekday - currentWeekday; // Calculate the number of days to add to get to the desired weekday
      if (daysToAdd <= 0 || (daysToAdd == 1 && now.hour * 60 + now.minute > int.parse(time.split(':')[0]) * 60 + int.parse(time.split(':')[1]))) {
        daysToAdd += 7; // If the desired weekday is before the current weekday or the scheduled time has passed for today, add 7 days to get to the next occurrence If the desired weekday is before the current weekday, add 7 days to get to the next occurrencehe desired weekday is before the current weekday, add 7 days to get to the next occurrence
    }
      DateTime scheduledDate = now.add(Duration(days: daysToAdd));
      scheduledDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, int.parse(time.split(':')[0]), int.parse(time.split(':')[1]));

      // Schedule weekly notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _generateNotificationId(medId, i), // Generate unique notification ID
        'Medication Reminder',
        'Remember to take your $name.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel desc',
            importance: Importance.max,
            priority: Priority.high,
            // icon: BitmapAndroidIcon(iconBytes),
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'weekly',
      );
    }
  }
}
}