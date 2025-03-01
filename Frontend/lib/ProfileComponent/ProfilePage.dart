// lib/ProfileComponent/ProfilePage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../../LoginSignupCompnent/LoginPage.dart';
import '../../MainPage/Home.dart';
import 'package:fitsync/StepCounter.dart'; // Adjust if StepCounter.dart path differs
import '../../PortSection/ConfigFile.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;
  const ProfilePage({super.key, this.initialUserData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  int streakCount = 0;
  String userId = "123456";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchStreaks();
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
          userData = Map<String, dynamic>.from(json.decode(userDataString));
        }
        userId = userData['userId'] ?? "123456";
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() { isLoading = false; });
      _navigateToLogin();
    }
  }

  Future<void> _fetchStreaks() async {
    try {
      final response = await http.get(Uri.parse('$getStreaks$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          streakCount = data['streakCount'] ?? 0;
        });
      } else {
        print('Failed to fetch streaks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching streaks: $e');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _navigateToHome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _navigateToLogin();
  }

  Future<void> _refreshData() async {
    setState(() { isLoading = true; });
    await _loadUserData();
    await _fetchStreaks();
    setState(() { isLoading = false; });
  }

  void _updateStreak(int stepsTaken) async {
    await _fetchStreaks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildProfileContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _navigateToHome,
          ),
          const Text('Profile', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _refreshData),
              IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildProfileAvatar()),
          const SizedBox(height: 20),
          StepCounter(
            userId: userId,
            onStepUpdate: _updateStreak,
            initialUserData: userData, // Pass userData (updated from initialUserData)
          ),
          const SizedBox(height: 20),
          _buildStreakSection(),
          _buildInfoSection('Personal Info', [
            _buildInfoRow('Name', userData['name'] ?? 'N/A'),
            _buildInfoRow('Email', userData['email'] ?? 'N/A'),
            _buildInfoRow('Mobile', userData['mobile'] ?? 'N/A'),
          ]),
          _buildInfoSection('Health Info', [
            _buildInfoRow('Blood Group', userData['bloodGroup']?.toUpperCase() ?? 'N/A'),
            _buildInfoRow('Height', '${userData['height'] ?? 0} cm'),
            _buildInfoRow('Weight', '${userData['weight'] ?? 0} kg'),
          ]),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 70,
      backgroundImage: userData['photo'] != null
          ? CachedNetworkImageProvider('$imageBaseUrl${userData['photo']}')
          : null,
      child: userData['photo'] == null
          ? Text(userData['name']?[0].toUpperCase() ?? 'U', style: const TextStyle(fontSize: 50, color: Colors.white))
          : null,
    );
  }

  Widget _buildStreakSection() {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Weekly Step Streaks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) => _buildStreakStar(index < streakCount)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStar(bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Icon(
          completed ? Icons.star : Icons.star_border,
          key: ValueKey(completed),
          color: completed ? Colors.yellow : Colors.grey,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}