  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'home.dart';
  import 'login.dart'; 
import 'dart:math';
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _password = '';
  String _username = '';
  String _gender = '';

  void _submitForm() async {
    String fcode = await generateFcode();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {

        await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        ).then((userCredential) {
          _firestore.collection('users').doc(userCredential.user!.uid).set({
            'username': _username,
            'email': _email,
            'gender': _gender,
            'fcode': fcode,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      } catch (error) {

        print('Error: $error');
      }
    }
  }

  // Generate a random fcode
 Future<String> generateFcode() async {
  String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  String fcode = '';
  bool exists = true;
  
  // Loop until a unique code is generated
  while (exists) {
    fcode = '';
    for (int i = 0; i < 8; i++) {
      fcode += chars[Random().nextInt(chars.length)];
    }

    var snapshot = await _firestore.collection('users').where('fcode', isEqualTo: fcode).get();
    if (snapshot.docs.isEmpty) {
      exists = false;
    }
  }
  return fcode;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your gender';
                  }
                  return null;
                },
                onSaved: (value) {
                  _gender = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Sign Up'),
              ),
              SizedBox(height: 10), 
              TextButton(
                onPressed: () {
 
                Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoginPage()),
);
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
