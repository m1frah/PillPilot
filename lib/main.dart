import 'package:flutter/material.dart';
import 'screens/home.dart'; // Import your home page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(), // Redirect to MainScreen
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Redirect to your home page
    return HomePage();
  }
}