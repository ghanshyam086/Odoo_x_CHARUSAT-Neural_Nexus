import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Doctor {
  final String id;
  final String name;
  final String specialist;
  final String clinicName;
  final String mobile;
  final String email;
  final String district;
  final String state;
  final String timeSlot;
  final String fees;
  final String description;
  final String? photo;

  Doctor({
    required this.id,
    required this.name,
    required this.specialist,
    required this.clinicName,
    required this.mobile,
    required this.email,
    required this.district,
    required this.state,
    required this.timeSlot,
    required this.fees,
    required this.description,
    this.photo,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['doctorId'].toString(),
      name: json['name'] as String,
      specialist: json['doctorSpecialist'] as String,
      clinicName: json['clinicName'] as String,
      mobile: json['mobileNumber'].toString(),
      email: json['emailId'] as String,
      district: json['district'] as String,
      state: json['state'] as String,
      timeSlot: json['timeSlot'] as String,
      fees: json['fees'].toString(),
      description: json['description'] as String,
      photo: json['photo'] as String?,
    );
  }
}

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  late Future<List<Doctor>> _doctorsFuture;
  String? _selectedCity;
  List<Doctor> _allDoctors = [];

  // List of major cities in Gujarat
  final List<String> _gujaratCities = [
    'Ahmedabad',
    'Surat',
    'Vadodara',
    'Rajkot',
    'Bhavnagar',
    'Jamnagar',
    'Junagadh',
    'Gandhinagar',
    'Anand',
    'Bharuch',
    'Nadiad',
    'Mehsana',
    'Porbandar',
    'Navsari',
    'Vapi',
  ];

  @override
  void initState() {
    super.initState();
    _doctorsFuture = fetchDoctors();
  }

  Future<List<Doctor>> fetchDoctors() async {
    final response = await http.get(Uri.parse('http://172.16.218.120:3000/doctors'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _allDoctors = data.map((json) => Doctor.fromJson(json)).toList();
      return _allDoctors;
    } else {
      throw Exception('Failed to load doctors: ${response.statusCode}');
    }
  }

  List<Doctor> _filterDoctors() {
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      return _allDoctors;
    }
    return _allDoctors
        .where((doctor) => doctor.district.toLowerCase() == _selectedCity!.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedCity,
              items: _gujaratCities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Doctor>>(
              future: _doctorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No doctors available'));
                }

                final filteredDoctors = _filterDoctors();

                if (filteredDoctors.isEmpty) {
                  return const Center(child: Text('No doctors found in selected city'));
                }

                return ListView.builder(
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = filteredDoctors[index];
                    return ListTile(
                      leading: doctor.photo != null
                          ? Image.network(
                        'http://172.16.218.120:3000/uploads/${doctor.photo}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person),
                      )
                          : const Icon(Icons.person),
                      title: Text(doctor.name),
                      subtitle: Text('${doctor.specialist} - ₹${doctor.fees}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailScreen(doctor: doctor),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  doctor.photo != null
                      ? Image.network(
                    'http://172.16.218.120:3000/uploads/${doctor.photo}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey.shade200),
                  )
                      : Container(color: Colors.grey.shade200),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.specialist,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    icon: Icons.medical_information,
                    title: 'Professional Info',
                    children: [
                      _InfoItem(
                        label: 'Doctor ID',
                        value: doctor.id,
                      ),
                      _InfoItem(
                        label: 'Clinic Name',
                        value: doctor.clinicName,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    icon: Icons.contact_phone,
                    title: 'Contact Information',
                    children: [
                      _InfoItem(
                        icon: Icons.phone,
                        label: 'Mobile',
                        value: doctor.mobile,
                      ),
                      _InfoItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: doctor.email,
                      ),
                      _InfoItem(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: '${doctor.district}, ${doctor.state}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    icon: Icons.access_time,
                    title: 'Availability',
                    children: [
                      _InfoItem(
                        label: 'Time Slot',
                        value: doctor.timeSlot,
                      ),
                      _InfoItem(
                        label: 'Consultation Fee',
                        value: '₹${doctor.fees}',
                        valueStyle: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    icon: Icons.description,
                    title: 'About',
                    children: [
                      Text(
                        doctor.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue.shade800),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoItem({
    this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: valueStyle ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DoctorScreen(),
  ));
}