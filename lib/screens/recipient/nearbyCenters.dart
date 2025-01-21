import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class NearbyCentersPage extends StatefulWidget {
  @override
  _NearbyCentersPageState createState() => _NearbyCentersPageState();
}

class _NearbyCentersPageState extends State<NearbyCentersPage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  late List<dynamic> hospitals;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadHospitalData();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _loadHospitalData() async {
    String jsonString =
        await DefaultAssetBundle.of(context).loadString('assets/hospital_data.json');
    hospitals = json.decode(jsonString);
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _updateUserLocationMarker(position.latitude, position.longitude);
    _filterNearbyHospitals(position.latitude, position.longitude);
  }

  void _updateUserLocationMarker(double lat, double lng) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'userLocation');
      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: 'Your Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  void _filterNearbyHospitals(double userLat, double userLng) {
    const double maxDistance = 50.0; // 50km radius
    Set<Marker> newMarkers = {};

    for (var hospital in hospitals) {
      double hospitalLat = hospital['latitude'];
      double hospitalLng = hospital['longitude'];

      double distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        hospitalLat,
        hospitalLng,
      );

      if (distance <= maxDistance * 1000) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('${hospital['name']}-${hospital['contact']}'),
            position: LatLng(hospitalLat, hospitalLng),
            infoWindow: InfoWindow(
              title: hospital['name'],
            ),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 100,
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(hospital['name'], style: TextStyle(fontSize: 20)),
                          Text(hospital['contact'], style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    }

    setState(() {
      _markers.addAll(newMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Centers'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(7.8731, 80.7718), // Sri Lanka coordinates
          zoom: 7,
        ),
        markers: _markers,
      ),
    );
  }
}
