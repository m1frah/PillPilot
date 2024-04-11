import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../database/firebaseoperations.dart';
import 'pfpselector.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _email;
  String? _username;
  String? _gender;
  String? _profilePictureUrl;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      setState(() {

        _username = userSnapshot.data()!['username'];
        _gender = userSnapshot.data()!['gender'];
        _profilePictureUrl = userSnapshot.data()!['pfp'];
        _usernameController.text = _username!;
        _genderController.text = _gender!;
      });
    }
  }

  static Future<void> updateUserProfilePicture(String profilePictureUrl) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'pfp': profilePictureUrl,
      });
    } catch (e) {
      print('Error updating user profile picture: $e');
      throw e;
    }
  }

  Future<void> _changePassword() async {
  //add this if have time
  }

  Future<void> _saveChanges() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'username': _username,
        'gender': _gender,
        'pfp': _profilePictureUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Changes saved')));
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save changes: $e')));
    }
  }

  Future<void> _changeProfilePicture() async {
    final selectedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageSelectionPage(
          imageNames: ['m1.png', 'm2.png', 'm3.png', 'm4.png', 'f1.png', 'f2.png', 'f3.png'],
          onImageSelected: (imageName) {
            Navigator.pop(context, imageName);
          },
        ),
      ),
    );

    if (selectedImage != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'pfp': selectedImage,
      });

      setState(() {
        _profilePictureUrl = selectedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 32),
        
              GestureDetector(
                onTap: _changeProfilePicture,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50), 
                  child: _profilePictureUrl != null
                      ? Image.asset(
                          'assets/$_profilePictureUrl',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey, 
                          child: Icon(Icons.add_a_photo, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: 16),
            
             
              SizedBox(height: 16),
              Text(
                'Username:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _usernameController,
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'Gender:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _genderController,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
