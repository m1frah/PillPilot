import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import 'screens/Home.dart';
import 'api/localnotifications.dart';
import 'screens/Login.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();

  var androidFlutterLocalNotificationsPlugin =
      AndroidFlutterLocalNotificationsPlugin();

  await androidFlutterLocalNotificationsPlugin.requestExactAlarmsPermission();

  await LocalNotifications.init();

  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed('/another',
          arguments: initialNotification?.notificationResponse?.payload);
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Check the authentication state
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator if the future is not resolved yet
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            // User is logged in, navigate to the home page
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Pill Pilot ',
              home: HomePage(),
            );
          } else {
            // User is not logged in, navigate to the login page
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Pill Pilot ',
              home: LoginPage(), // Replace LoginPage with your actual login page
            );
          }
        }
      },
    );
  }
}
