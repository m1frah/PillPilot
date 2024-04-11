import 'package:flutter/material.dart';
import '../../database/firebaseoperations.dart';
import 'pfpselector.dart';
import '../../model/model.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Users _user;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  bool _isLoading = true; 
  FirebaseOperations _firebaseOperations = FirebaseOperations();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Users userData = await _firebaseOperations.getUserData();
      setState(() {
        _user = userData;
        _usernameController.text = userData.username;
        _genderController.text = _user.gender;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _saveChanges() async {
    try {
      await _firebaseOperations.updateUserProfile(_user.userId, _user.username, _user.gender, _user.pfp);
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
          imageNames: ['m1.png', 'm2.png', 'm3.png', 'm4.png', 'f1.png', 'f2.png', 'f3.png', 'a1.png', 'a2.png', 'a3.png', 'a4.png', 'a5.png'],
          onImageSelected: (imageName) {
            Navigator.pop(context, imageName);
          },
        ),
      ),
    );

    if (selectedImage != null) {
      try {
        await _firebaseOperations.updateUserProfilePicture(_user.userId, selectedImage);
        setState(() {
          _user.pfp = selectedImage;
        });
      } catch (e) {
        print('Error changing profile picture: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
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
                        child: _user.pfp != null
                            ? Image.asset(
                                'assets/${_user.pfp}',
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
                    Text(
                      'Username:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _usernameController,
                      onChanged: (value) {
                        setState(() {
                          _user.username = value;
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
                          _user.gender = value;
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
