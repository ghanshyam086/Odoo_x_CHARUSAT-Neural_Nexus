import 'package:flutter/material.dart';

void main() {
  runApp(FitSyncApp());
}

class FitSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
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
    WorkoutsPage(),
    DietPlansPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fit Sync")),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workouts"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Diet Plans"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome to Fit Sync!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Your daily health companion.", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text("Health Tips:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildTipCard("Stay Hydrated", "Drink at least 8 glasses of water daily to keep your body hydrated."),
            _buildTipCard("Eat Balanced Meals", "Include proteins, carbs, and healthy fats in your meals."),
            _buildTipCard("Exercise Regularly", "Engage in at least 30 minutes of physical activity every day."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text("View More Tips"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text("Start Your Health Journey"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(description, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}

class WorkoutsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Workouts Page"));
  }
}

class DietPlansPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Diet Plans Page"));
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Profile Page"));
  }
}
