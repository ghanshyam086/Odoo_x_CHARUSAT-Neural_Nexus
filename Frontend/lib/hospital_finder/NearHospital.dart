import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitsync/PortSection/ConfigFile.dart'; // Import ConfigFile.dart

// Hospital Section Widget
class HospitalSection extends StatefulWidget {
  const HospitalSection({super.key});

  @override
  _HospitalSectionState createState() => _HospitalSectionState();
}

class _HospitalSectionState extends State<HospitalSection> {
  String? selectedCity;
  String? selectedDistrict;
  List<String> cities = [];
  List<String> districts = [];
  List<dynamic> hospitals = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse(getHospitalCities)); // Use config endpoint
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched cities: $data');
        setState(() {
          cities = List<String>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading cities: $e';
      });
    }
  }

  Future<void> _fetchDistricts(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse('$getHospitalDistricts?city=$city')); // Use config endpoint with query
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched districts for $city: $data');
        setState(() {
          districts = List<String>.from(data);
          selectedDistrict = null;
          hospitals = [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching districts: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading districts: $e';
      });
    }
  }

  Future<void> _fetchHospitals(String city, String district) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse('$getHospitals?city=$city&district=$district')); // Use config endpoint with query
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched hospitals for $city, $district: $data');
        setState(() {
          hospitals = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load hospitals: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hospitals: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading hospitals: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Hospitals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select City',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    value: selectedCity,
                    items: cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                    onChanged: (value) {
                      setState(() => selectedCity = value);
                      if (value != null) _fetchDistricts(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select District',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    value: selectedDistrict,
                    items: districts.map((district) => DropdownMenuItem(value: district, child: Text(district))).toList(),
                    onChanged: (value) {
                      setState(() => selectedDistrict = value);
                      if (selectedCity != null && value != null) _fetchHospitals(selectedCity!, value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : hospitals.isEmpty
                ? const Center(child: Text('No hospitals found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.local_hospital, color: Colors.blueAccent),
                    title: Text(hospital['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(hospital['address'] ?? 'No address available'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HospitalDetailsPage(hospital: hospital)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Hospital Details Page
class HospitalDetailsPage extends StatelessWidget {
  final dynamic hospital;
  const HospitalDetailsPage({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hospital['name'] ?? 'Unnamed Hospital', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Basic Information', [
                _buildInfoRow('Name', hospital['name']),
                _buildInfoRow('Address', hospital['address']),
                _buildInfoRow('Phone', hospital['contact']?['phone']),
                _buildInfoRow('Email', hospital['contact']?['email']),
                _buildInfoRow('Website', hospital['contact']?['website']),
                _buildInfoRow('Operating Hours', hospital['operatingHours']),
                _buildInfoRow('Emergency Services', hospital['emergencyServices']?.toString()),
              ]),
              _buildSection('Medical Services & Specialties', [
                _buildInfoRow('Departments', hospital['departments']?.join(', ')),
                _buildInfoRow('Treatments', hospital['treatments']?.join(', ')),
                _buildInfoRow('Emergency Care', hospital['emergencyCare']),
                _buildInfoRow('Specialized Units', hospital['specializedUnits']?.join(', ')),
              ]),
              _buildSection('Doctors & Staff', [
                if (hospital['doctors'] != null)
                  ...hospital['doctors'].map<Widget>((doc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${doc['name'] ?? 'Unknown'} - ${doc['specialty'] ?? 'N/A'} (${doc['experience']?.toString() ?? 'N/A'} yrs)',
                    ),
                  )).toList(),
                _buildInfoRow('Consultation Timings', hospital['consultationTimings']),
              ]),
              _buildSection('Facilities & Infrastructure', [
                _buildInfoRow('Beds', hospital['facilities']?['beds']?.toString()),
                _buildInfoRow('Pharmacy', hospital['facilities']?['pharmacy']?.toString()),
                _buildInfoRow('Diagnostics', hospital['facilities']?['diagnostics']?.join(', ')),
                _buildInfoRow('Ambulance', hospital['facilities']?['ambulance']),
              ]),
              _buildSection('Insurance & Payments', [
                _buildInfoRow('Accepted Plans', hospital['insurance']?.join(', ')),
              ]),
              _buildSection('Reviews & Ratings', [
                _buildInfoRow('Rating', hospital['rating']?.toString()),
                _buildInfoRow('Testimonials', hospital['testimonials']?.join(', ')),
              ]),
              _buildSection('Additional Features', [
                _buildInfoRow('Wellness Programs', hospital['additional']?['wellness']),
                _buildInfoRow('Blood Bank', hospital['additional']?['bloodBank']?.toString()),
                _buildInfoRow('Medical Tourism', hospital['additional']?['medicalTourism']?.toString()),
                _buildInfoRow('COVID-19 Updates', hospital['additional']?['covidUpdates']),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    String displayValue = 'N/A';
    if (value != null) {
      if (value is String) {
        displayValue = value.isEmpty ? 'N/A' : value;
      } else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else if (value is num) {
        displayValue = value.toString();
      } else if (value is List && value.isEmpty) {
        displayValue = 'None';
      } else {
        displayValue = value.toString();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}