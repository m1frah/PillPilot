import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medcine/medcinepage.dart';
import 'appointments/appointments.dart';
import 'community/community.dart';
import '../widgets/calender.dart';
import 'signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sidebar/editprofile.dart';
import 'sidebar/friends.dart';
import 'sidebar/sync.dart';
import 'test.dart';
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
    CommunityPage()
  ];

  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername(); 
  }

  Future<void> _loadUsername() async {
 
    if (FirebaseAuth.instance.currentUser != null) {

      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        setState(() {
          _username = userSnapshot.data()!['username'] ?? ''; 
        });
      }
    } else {
  
      setState(() {
        _username = 'Guest';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); 
  Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
          );
    } catch (e) {
      print("Error signing out: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255), 
                  // Add drop shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            AppBar(
              backgroundColor: Colors.transparent, 
              elevation: 0, 
              title: Row(
                children: [
                  SizedBox(width: 0), 
                  InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Icon(
                      Icons.account_circle,
                      size: 32, 
                      color: Color.fromARGB(255, 52, 48, 101), 
                    ),
                  ),
                  SizedBox(width: 10), 
              
                  Text(
                    _username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 71, 61, 110)), // Change the color of the text
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.group),
            label: 'Community',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 109, 111, 224),
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 163, 123, 255),
              ),
              child: Text(
                'Pill Pilot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  
                ),
              ),
            ),
            ListTile(
              title: Text('Edit Profile'),
             onTap: () {
           Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditProfilePage()), 
  );
},
            ),
            ListTile(
              title: Text('notification test'),
                 onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NotificationTestPage()), 
  );
},
     
            ),
            ListTile(
              title: Text('Documents'),
              onTap: () {
           
              },
            ),
            ListTile(
              title: Text('Friends'),
                           onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => FriendsPage()), 
  );
},
            ),
              ListTile(
        leading: Icon(
          Icons.logout,
           color: Colors.red,
        ),
        title: Text(
          'Log Out',
          style: TextStyle(color: Colors.red), 
        ),
        onTap: _signOut
      ),
          ],
        ),
      ),
    );
  }
}