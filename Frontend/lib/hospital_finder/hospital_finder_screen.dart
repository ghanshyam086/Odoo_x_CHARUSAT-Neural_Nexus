import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Hospital {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String placeId;

  Hospital({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.placeId,
  });
}

class HospitalFinderScreen extends StatefulWidget {
  @override
  _HospitalFinderScreenState createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  List<Hospital> _hospitals = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
      });

      await _fetchNearbyHospitals(position.latitude, position.longitude);

    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog('Location permissions are permanently denied');
      return false;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _showErrorDialog('Location permissions are denied');
        return false;
      }
    }
    return true;
  }

  Future<void> _fetchNearbyHospitals(double lat, double lng) async {
    const apiKey = 'YOUR_GOOGLE_API_KEY';
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
            'location=$lat,$lng&radius=5000&type=hospital&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Hospital> hospitals = [];
      Set<Marker> markers = {};

      for (var result in data['results']) {
        final hospital = Hospital(
          name: result['name'],
          address: result['vicinity'],
          lat: result['geometry']['location']['lat'],
          lng: result['geometry']['location']['lng'],
          placeId: result['place_id'],
        );

        hospitals.add(hospital);
        markers.add(
          Marker(
            markerId: MarkerId(hospital.placeId),
            position: LatLng(hospital.lat, hospital.lng),
            infoWindow: InfoWindow(
              title: hospital.name,
              snippet: hospital.address,
              onTap: () => _showHospitalDetails(hospital),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(175),
          ),
        );
      }

      setState(() {
        _hospitals = hospitals;
        _markers = markers;
      });
    }
  }

  void _showHospitalDetails(Hospital hospital) async {
    try {
      final details = await _fetchHospitalDetails(hospital.placeId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HospitalDetailScreen(
            hospital: hospital,
            details: details,
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<Map<String, dynamic>> _fetchHospitalDetails(String placeId) async {
    const apiKey = 'YOUR_GOOGLE_API_KEY';
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?'
            'place_id=$placeId&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['result'];
    }
    throw Exception('Failed to load hospital details');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
        title: Text('Nearby Hospitals'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) => mapController = controller,
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _hospitals.length,
              itemBuilder: (context, index) => HospitalListItem(
                hospital: _hospitals[index],
                currentPosition: _currentPosition!,
                onTap: () => _showHospitalDetails(_hospitals[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HospitalListItem extends StatelessWidget {
  final Hospital hospital;
  final Position currentPosition;
  final VoidCallback onTap;

  const HospitalListItem({
    required this.hospital,
    required this.currentPosition,
    required this.onTap,
  });

  double get distance => Geolocator.distanceBetween(
    currentPosition.latitude,
    currentPosition.longitude,
    hospital.lat,
    hospital.lng,
  ) / 1000;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.local_hospital, color: Colors.red),
      title: Text(hospital.name),
      subtitle: Text(hospital.address),
      trailing: Text('${distance.toStringAsFixed(1)} km'),
      onTap: onTap,
    );
  }
}

class HospitalDetailScreen extends StatelessWidget {
  final Hospital hospital;
  final Map<String, dynamic> details;

  const HospitalDetailScreen({
    required this.hospital,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hospital.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _DetailItem(icon: Icons.location_on, text: hospital.address),
            if (details['formatted_phone_number'] != null)
              _DetailItem(
                icon: Icons.phone,
                text: details['formatted_phone_number'],
              ),
            if (details['website'] != null)
              _DetailItem(
                icon: Icons.language,
                text: details['website'],
              ),
            if (details['rating'] != null)
              _DetailItem(
                icon: Icons.star,
                text: 'Rating: ${details['rating']}',
              ),
            if (details['opening_hours']?['weekday_text'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Opening Hours:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...details['opening_hours']['weekday_text']
                      .map<Widget>((hour) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(hour),
                  ))
                      .toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          SizedBox(width: 16),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}