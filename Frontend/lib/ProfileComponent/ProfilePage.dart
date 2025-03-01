import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../LoginSignupCompnent/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userDataString = prefs.getString('user_data');

    if (token == null) {
      _navigateToLogin();
      return;
    }

    setState(() {
      userData = userDataString != null ? json.decode(userDataString) : {};
      isLoading = false;
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Text(
                  userData['name']?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Name: ${userData['name'] ?? 'N/A'}'),
            Text('Email: ${userData['email'] ?? 'N/A'}'),
            Text('Mobile: ${userData['mobile'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
