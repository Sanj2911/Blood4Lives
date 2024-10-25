import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DonationCentersPage extends StatefulWidget {
  @override
  _DonationCentersPageState createState() => _DonationCentersPageState();
}

class _DonationCentersPageState extends State<DonationCentersPage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  late List<dynamic> hospitals; // Declare the list to hold hospital data

  @override
  void initState() {
    super.initState();
    _loadHospitalData();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _loadHospitalData() async {
    String jsonString =
        await DefaultAssetBundle.of(context).loadString('assets/hospital_data.json');
    hospitals = json.decode(jsonString); // Store the hospital data in the list

    for (var hospital in hospitals) {
      _markers.add(
        Marker(
          markerId: MarkerId('${hospital['name']}-${hospital['contact']}'),
          position: LatLng(hospital['latitude'], hospital['longitude']),
          infoWindow: InfoWindow(
            title: hospital['name'],
          ),
          onTap: () {
            // Display hospital information when marker is tapped
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
