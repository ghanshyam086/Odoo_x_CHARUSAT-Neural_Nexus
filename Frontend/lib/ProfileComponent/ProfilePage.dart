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
  List<Map<String, dynamic>> weeklyStreaks = List.generate(7, (index) => {'completed': false, 'steps': 0});
  String userId = "123456";
  int todaySteps = 0;

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
          // Assuming API returns a list of daily steps for the last 7 days
          List<dynamic> streakData = data['weeklyStreaks'] ?? [];
          for (int i = 0; i < 7 && i < streakData.length; i++) {
            weeklyStreaks[i] = {
              'completed': streakData[i]['steps'] >= (data['dailyStepGoal'] ?? 10000),
              'steps': streakData[i]['steps'] ?? 0,
            };
          }
          // Update today's steps if available
          if (streakData.isNotEmpty) {
            todaySteps = streakData.last['steps'] ?? 0;
          }
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

  void _updateStreak(int stepsTaken) {
    setState(() {
      todaySteps = stepsTaken;
      weeklyStreaks[6]['steps'] = stepsTaken; // Update today's steps
      weeklyStreaks[6]['completed'] = stepsTaken >= 10000; // Assuming 10k step goal
    });
    _fetchStreaks(); // Refresh streak data from server
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
            initialUserData: userData,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Weekly Step Streaks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) => _buildStreakDay(index)),
            ),
            const SizedBox(height: 10),
            Text(
              'Current Streak: ${_calculateStreak()} days',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakDay(int index) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final bool isToday = index == 6; // Assuming 6 is today
    final int steps = weeklyStreaks[index]['steps'];
    const int dailyGoal = 10000; // Replace with actual goal from server if available
    double progress = steps / dailyGoal;
    if (progress > 1) progress = 1;

    return Column(
      children: [
        Text(
          days[index],
          style: TextStyle(
            fontSize: 14,
            color: isToday ? Colors.blueAccent : Colors.grey,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  weeklyStreaks[index]['completed'] ? Colors.green : Colors.blueAccent,
                ),
                strokeWidth: 4,
              ),
              Icon(
                weeklyStreaks[index]['completed'] ? Icons.check : Icons.directions_walk,
                size: 20,
                color: weeklyStreaks[index]['completed'] ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$steps',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  int _calculateStreak() {
    int streak = 0;
    for (var day in weeklyStreaks.reversed) {
      if (day['completed']) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
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