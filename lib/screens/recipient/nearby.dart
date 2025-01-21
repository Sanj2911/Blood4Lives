import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class NearbyDonorsPage extends StatefulWidget {
  @override
  _NearbyDonorsPageState createState() => _NearbyDonorsPageState();
}

class _NearbyDonorsPageState extends State<NearbyDonorsPage> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;
  String? _userRole;
  Map<String, Marker> _markers = {};
  Timer? _timer;
  Circle? _circle;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _startTimer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const updateInterval = Duration(minutes: 5); // Update every 5 minutes
    _timer = Timer.periodic(updateInterval, (timer) {
      if (_currentPosition != null) {
        _updateCurrentUserLocation(_currentPosition!);
      }
    });
  }

  Future<void> _getCurrentUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      await _getUserRole();
      await _checkLocationPermissions();
      if (_userRole == 'recipient') {
        _listenToNearbyDonors();
      }
    } else {
      _showNotLoggedInDialog();
    }
  }

  Future<void> _getUserRole() async {
    if (_currentUserId != null) {
      DocumentSnapshot donorSnapshot = await _firestore.collection('donors').doc(_currentUserId).get();
      if (donorSnapshot.exists) {
        setState(() {
          _userRole = 'donor';
        });
      } else {
        DocumentSnapshot recipientSnapshot = await _firestore.collection('recipients').doc(_currentUserId).get();
        if (recipientSnapshot.exists) {
          setState(() {
            _userRole = 'recipient';
          });
        } else {
          _showUserRoleNotFoundDialog();
        }
      }
    }
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServicesDisabledDialog();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog();
      return;
    }

    _getRealTimeLocationUpdates();
  }

  void _getRealTimeLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _updateCurrentUserLocation(position);
      });

      _controller?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ));

      _updateCirclePosition(position);
    });
  }

  void _updateCirclePosition(Position position) {
    if (_circle != null) {
      setState(() {
        _circle = _circle!.copyWith(centerParam: LatLng(position.latitude, position.longitude));
      });
    } else {
      _createCircle(position);
    }
  }

  void _createCircle(Position position) {
    setState(() {
      _circle = Circle(
        circleId: CircleId("recipientCircle"),
        center: LatLng(position.latitude, position.longitude),
        radius: 30000, // 30 km in meters
        strokeWidth: 2,
        strokeColor: const Color.fromARGB(255, 230, 116, 154).withOpacity(0.3), // Adjust the opacity and color as needed
        fillColor: const Color.fromARGB(255, 229, 86, 134).withOpacity(0.5), // Adjust the opacity and color as needed
      );
    });
  }

  Future<void> _updateCurrentUserLocation(Position position) async {
    if (_currentUserId != null && _userRole != null) {
      String collection = _userRole == 'donor' ? 'donors' : 'recipients';
      await _firestore.collection(collection).doc(_currentUserId).set(
        {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        SetOptions(merge: true),
      );
    }
  }

  void _listenToNearbyDonors() {
    _firestore.collection('donors').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        Map<String, Marker> newMarkers = {};
        snapshot.docs.forEach((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('latitude') && data.containsKey('longitude')) {
            final markerId = MarkerId(doc.id);
            final isActive = data['isActive'] as bool? ?? false;
            final marker = Marker(
              markerId: markerId,
              position: LatLng(data['latitude'], data['longitude']),
              infoWindow: InfoWindow(
                title: '${data['bloodType']}',
                snippet: '${data['fullName']}\nphone: ${data['phone']}',
                
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isActive ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
              ),
            );
            newMarkers[doc.id] = marker;
          }
        });
        setState(() {
          _markers = newMarkers;
          // Add recipient's location marker
          if (_currentPosition != null) {
            _markers[_currentUserId!] = Marker(
              markerId: MarkerId(_currentUserId!),
              position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              infoWindow: InfoWindow(title: 'Your Location'),
            );
          }
        });
      }
    });
  }

  void _showLocationServicesDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text('Please enable location services.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text('Location permission is denied. Please allow access to location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Permanently Denied'),
        content: Text('Location permission is permanently denied. Please go to settings and allow access to location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotLoggedInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Not Logged In'),
        content: Text('You need to be logged in to see nearby donors.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUserRoleNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Role Not Found'),
        content: Text('The role for the current user is not found. Please contact support.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Donors'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                _controller = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 14,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers.values.toSet(),
              circles: _circle != null ? Set.of([_circle!]) : Set(),
            ),
    );
  }
}
