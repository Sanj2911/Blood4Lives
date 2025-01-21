import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationUpdater {
  final String userId;
  final String userType; // 'donors' or 'recipients'
  Timer? _timer;

  LocationUpdater(this.userId, this.userType);

  void startUpdating() {
    // Update location immediately and then every 5 minutes
    _updateLocation();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateLocation();
    });
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await FirebaseFirestore.instance.collection(userType).doc(userId).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  void stopUpdating() {
    _timer?.cancel();
  }
}
