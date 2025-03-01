import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? currentPosition;
  List<LatLng> nearbyHospitals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition!, 14.0),
      );
      await _fetchNearbyHospitals();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  Future<void> _fetchNearbyHospitals() async {
    if (currentPosition == null) return;

    const String apiKey = 'AIzaSyB7ETOwK6NMmiPX1HUAThIjfDbCxXq_A6c'; // Replace with your actual API key
    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${currentPosition!.latitude},${currentPosition!.longitude}&radius=5000&type=hospital&key=$apiKey';

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<LatLng> hospitals = [];
        for (var place in data['results']) {
          double lat = place['geometry']['location']['lat'];
          double lng = place['geometry']['location']['lng'];
          hospitals.add(LatLng(lat, lng));
        }
        setState(() {
          nearbyHospitals = hospitals;
        });
      } else {
        print('Failed to load hospitals: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load hospitals')),
        );
      }
    } catch (e) {
      print('Error fetching hospitals: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching hospitals: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Nearby Hospitals',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ),
      )
          : currentPosition == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Unable to get location.',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      )
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: currentPosition!,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentPosition!,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
          ),
          ...nearbyHospitals.map((latLng) => Marker(
            markerId: MarkerId(latLng.toString()),
            position: latLng,
            infoWindow: const InfoWindow(title: 'Hospital'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed),
          )),
        },
        onTap: (LatLng position) {
          // Optional: Add interaction if needed
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.my_location, color: Colors.white),
        tooltip: 'Refresh Location',
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}