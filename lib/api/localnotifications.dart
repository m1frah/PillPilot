import 'dart:async';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';
class LocalNotifications  {

  static  final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();


  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }


  static Future init() async {
  
      tz.initializeTimeZones();
 
   
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

  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

   static int _generateNotificationId(int medId, int i) {

    print(('$medId and $i'));

    return  int.parse('$medId$i');
  }

  // Function to schedule notifications
  static Future<void> scheduleNotifications(int medId, String days, String time, String name) async {

  ByteData iconByteData = await rootBundle.load('assets/pill.png');
  final Uint8List iconBytes = iconByteData.buffer.asUint8List();
  for (int i = 0; i < days.length; i++) {
    await _flutterLocalNotificationsPlugin.cancel(_generateNotificationId(medId, i));
  }

  for (int i = 0; i < days.length; i++) {
    if (days[i] == '1') {
      DateTime now = DateTime.now();
      int currentWeekday = now.weekday; 
      int desiredWeekday = (i + 1) % 7;
      int daysToAdd = desiredWeekday - currentWeekday;
      if (daysToAdd <= 0 || (daysToAdd == 1 && now.hour * 60 + now.minute > int.parse(time.split(':')[0]) * 60 + int.parse(time.split(':')[1]))) {
        daysToAdd += 7; 
    }
      DateTime scheduledDate = now.add(Duration(days: daysToAdd));
      scheduledDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, int.parse(time.split(':')[0]), int.parse(time.split(':')[1]));

      // Schedule weekly notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _generateNotificationId(medId, i), 
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle ,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'weekly',
      );
    }
  }
}
}