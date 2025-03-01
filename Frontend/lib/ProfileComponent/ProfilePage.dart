import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart'; // For loading network images
import '../LoginSignupCompnent/LoginPage.dart';
import '../MainPage/Home.dart'; // Import HomePage

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

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadUserData();
  }

  void _editProfile() {
    // Placeholder for edit functionality - you can implement a form here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToHome,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : userData.isEmpty
            ? const Center(child: Text('No user data available'))
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildProfileAvatar(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoSection('Personal Info', [
                _buildInfoRow('Name', userData['name'] ?? 'N/A'),
                _buildInfoRow('Email', userData['email'] ?? 'N/A'),
                _buildInfoRow('Mobile', userData['mobile'] ?? 'N/A'),
              ]),
              const SizedBox(height: 16),
              _buildInfoSection('Health Info', [
                _buildInfoRow('Blood Group',
                    userData['bloodGroup']?.toUpperCase() ?? 'N/A'),
                _buildInfoRow('Height', '${userData['height'] ?? 0} cm'),
                _buildInfoRow('Weight', '${userData['weight'] ?? 0} kg'),
                _buildInfoRow('Age', '${userData['age'] ?? 0} years'),
              ]),
              const SizedBox(height: 16),
              _buildInfoSection('Medical Details', [
                _buildInfoRow('Allergies', userData['allergies'] ?? 'None'),
                _buildInfoRow('Medical Conditions',
                    userData['medicalConditions'] ?? 'None'),
                _buildInfoRow('Medications', userData['medications'] ?? 'None'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () {
        // Add functionality to view full image or update photo
        if (userData['photo'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo viewing coming soon!')),
          );
        }
      },
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: userData['photo'] != null
            ? CachedNetworkImageProvider(
          'http://localhost:3000/${userData['photo']}',
        ) // Adjust URL based on your backend
            : null,
        child: userData['photo'] == null
            ? Text(
          userData['name']?[0].toUpperCase() ?? 'U',
          style: const TextStyle(fontSize: 40, color: Colors.white),
        )
            : null,
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return AnimatedOpacity(
      opacity: isLoading ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(height: 20),
              ...children,
            ],
          ),
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