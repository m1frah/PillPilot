import 'package:flutter/material.dart';
import 'medcinepage.dart';
import 'appointments.dart';
import 'test.dart';
import '../widgets/calender.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CalendarWidget(),
    MedicationPage(),
    AppointmentPage(),
    TestApp()
    
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PilPilot'),
      ),
      
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(type : BottomNavigationBarType.fixed,
        
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_rounded),
            label: 'Medicine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dangerous),
            label: 'Test',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 109, 111, 224),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:  Text('Home Page Content'),
    );
  }
}


