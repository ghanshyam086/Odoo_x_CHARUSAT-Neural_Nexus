import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login.dart';
import 'home.dart'; // Import HomePage

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;
  const ProfilePage({super.key, this.initialUserData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userDataString = prefs.getString('user_data');

      if (token == null) {
        _navigateToLogin();
        return;
      }

      setState(() {
        if (widget.initialUserData != null) {
          userData = Map<String, dynamic>.from(widget.initialUserData!);
        } else if (userDataString != null && userDataString.isNotEmpty) {
          try {
            final decodedData = json.decode(userDataString);
            if (decodedData is Map) {
              userData = Map<String, dynamic>.from(decodedData);
            }
          } catch (e) {
            print('Error decoding user data: $e');
            _navigateToLogin();
            return;
          }
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToHome, // Back to Home
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData.isEmpty
          ? const Center(child: Text('No user data available'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  userData['name']?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard([
              _buildInfoRow('Name', userData['name'] ?? 'N/A'),
              _buildInfoRow('Email', userData['email'] ?? 'N/A'),
              _buildInfoRow('Mobile', userData['mobile'] ?? 'N/A'),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard([
              _buildInfoRow('Blood Group', userData['bloodGroup']?.toUpperCase() ?? 'N/A'),
              _buildInfoRow('Height', '${userData['height'] ?? 0} cm'),
              _buildInfoRow('Weight', '${userData['weight'] ?? 0} kg'),
              _buildInfoRow('Age', '${userData['age'] ?? 0} years'),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard([
              _buildInfoRow('Allergies', userData['allergies'] ?? 'None'),
              _buildInfoRow('Medical Conditions', userData['medicalConditions'] ?? 'None'),
              _buildInfoRow('Medications', userData['medications'] ?? 'None'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}