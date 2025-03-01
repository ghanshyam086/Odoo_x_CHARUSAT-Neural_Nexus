import 'package:flutter/material.dart';

void main() {
  runApp(FitSyncApp());
}

class FitSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Align with Fit Sync theme (Colors.blue.shade900)
        scaffoldBackgroundColor: Colors.blue.shade50, // Light background for Fit Sync
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    AIChatBotPage(),
    LabReportPage(),
    HealthContentsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fit Sync',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey.shade500,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "AI Chat Bot"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Lab Report"),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Health Contents"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue.shade50, // Light background for Fit Sync
        child: Column(
          children: [
            // Drawer Header
            Container(
              height: MediaQuery.of(context).size.height * 0.22,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.1,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).size.width * 0.12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    const Text(
                      'Fit Sync User',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info,
                    title: 'About Us',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutUsDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 4); // Navigate to Profile page
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsPage()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.favorite,
                    title: 'Health Tips',
                    onTap: () {
                      Navigator.pop(context);
                      _showHealthTipsDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.location_on,
                    title: 'Nearby Services',
                    onTap: () {
                      Navigator.pop(context);

                    },
                  ),
                  const Divider(color: Colors.grey),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () => _showLogoutDialog(context),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blue.shade900, size: MediaQuery.of(context).size.width * 0.07),
      title: Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      hoverColor: Colors.blue.shade100.withOpacity(0.2),
    );
  }

  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About Us'),
        content: const Text('Fit Sync is your personalized health companion, offering tools and resources to improve your well-being.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showHealthTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Health Tips'),
        content: const Text('Stay hydrated, eat a balanced diet, and exercise regularly for better health!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: Navigate to LoginPage (uncomment when implemented)
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Dashboard Page"));
  }
}

class AIChatBotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("AI Chat Bot Page"));
  }
}

class LabReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Lab Report Page"));
  }
}

class HealthContentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Health Contents Page"));
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Profile Page"));
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Settings Page"));
  }
}