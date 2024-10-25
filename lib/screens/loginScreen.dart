import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savelives/screens/admin/adminLogin.dart';
import 'package:savelives/screens/donor/donorProfile.dart';
import 'package:savelives/screens/recipient/recipientProfile.dart';
import 'package:savelives/screens/reset_password.dart'; // Import the reset password screen
import 'package:geolocator/geolocator.dart';
import 'package:savelives/screens/location_updater.dart'; // Import the LocationUpdater class

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn(BuildContext context, String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Get the user's ID from the authentication result
      String userId = userCredential.user!.uid;

      await _updateUserLocation(userId);

      // Check if the user is in the donors collection
      var donorSnapshot = await FirebaseFirestore.instance.collection('donors').doc(userId).get();
      if (donorSnapshot.exists) {
        // User is a donor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DonorProfileScreen()),
        );
        return;
      }

      // Check if the user is in the recipients collection
      var recipientSnapshot = await FirebaseFirestore.instance.collection('recipients').doc(userId).get();
      if (recipientSnapshot.exists) {
        // User is a recipient
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RecipientProfileScreen()),
        );
        return;
      }

      // Handle the case where the user is not found in either collection
      setState(() {
        _errorMessage = 'User not found in donor or recipient collection.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _errorMessage = 'The email address is badly formatted.';
            break;
          case 'user-not-found':
            _errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            _errorMessage = 'Incorrect password provided.';
            break;
          default:
            _errorMessage = 'Failed to sign in. Please check your credentials.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserLocation(String userId) async {
    try {
      // Get current user's position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Check if user is donor or recipient
      var donorSnapshot = await FirebaseFirestore.instance.collection('donors').doc(userId).get();
      if (donorSnapshot.exists) {
        // Update donor's location
        await FirebaseFirestore.instance.collection('donors').doc(userId).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }, SetOptions(merge: true));
        // Start updating location periodically for donors
        LocationUpdater locationUpdater = LocationUpdater(userId, 'donors');
        locationUpdater.startUpdating();

      } else {
        var recipientSnapshot = await FirebaseFirestore.instance.collection('recipients').doc(userId).get();
        if (recipientSnapshot.exists) {
          // Update recipient's location
          await FirebaseFirestore.instance.collection('recipients').doc(userId).set({
            'latitude': position.latitude,
            'longitude': position.longitude,
          }, SetOptions(merge: true));
           // Start updating location periodically for recipients
          LocationUpdater locationUpdater = LocationUpdater(userId, 'recipients');
          locationUpdater.startUpdating();
        }
      }
    } catch (e) {
      print('Error updating user location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginScreen()), // Navigate to home screen
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffB81736), Color(0xff281537)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Welcome to SaveLives',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/2.png',
                              height: 200,
                              width: 200,
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              obscureText: !_passwordVisible,
                              validator: (value) {
                                if (value == null || value.trim().length < 6                                  ) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xffB81736), Color(0xff281537)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: MaterialButton(
                                  onPressed: _isLoading ? null : () {
                                    if (_formKey.currentState!.validate()) {
                                      signIn(context, _emailController.text, _passwordController.text);
                                    }
                                  },
                                  child: _isLoading
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              if (_errorMessage.isNotEmpty)
                                Text(
                                  _errorMessage,
                                  style: TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

