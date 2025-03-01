import 'package:flutter/material.dart';
import 'HomeComponents/aichatbot.dart';
import '../MainPage/HomeComponents/aichatbot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const AIChatbotPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fit Sync',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "AI Chat"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey.shade500,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/homepage_bg.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '        Welcome to Fit Sync         ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.025),
            // Health Summary with Premium Card Design
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.blue.shade100, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.035),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryItem(context, "Appointments", "2", Icons.calendar_today),
                    _buildSummaryItem(context, "Medications", "3", Icons.medication),
                    _buildSummaryItem(context, "Tests", "1", Icons.science),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Healthcare Services with 3x2 Grid
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Health",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.blue.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.035),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: MediaQuery.of(context).size.width * 0.025,
                      mainAxisSpacing: MediaQuery.of(context).size.height * 0.015,
                      childAspectRatio: 0.9,
                      children: [
                        _buildHealthButton(context, "AI Chat", Icons.chat, Colors.green.shade300, 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Daily Health Tips
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Tips",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.green.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTip(context, "Stay hydrated: Drink 8 glasses of water daily!", Colors.green.shade700),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        _buildTip(context, "Exercise 30 minutes daily for better health!", Colors.green.shade700),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        _buildTip(context, "Get 7-9 hours of quality sleep each night!", Colors.green.shade700),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                        _buildTip(context, "Eat a balanced diet rich in fruits and vegetables!", Colors.green.shade700),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: MediaQuery.of(context).size.width * 0.07, color: Colors.blue.shade900),
        SizedBox(height: MediaQuery.of(context).size.height * 0.0075),
        Text(
          value,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            shadows: [
              Shadow(
                color: Colors.blue.withOpacity(0.2),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.grey.shade600,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthButton(BuildContext context, String label, IconData icon, Color color, int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade300,
        foregroundColor: Colors.black87,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02,
          horizontal: MediaQuery.of(context).size.width * 0.02,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.green.shade200, width: 1),
        ),
        elevation: 4,
      ),
      onPressed: () {
        if (label == "AI Chat") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatbotPage()));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: MediaQuery.of(context).size.width * 0.07,
            color: Colors.black87,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.0075),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text, Color iconColor) {
    return Row(
      children: [
        Icon(Icons.lightbulb_outline, color: iconColor, size: MediaQuery.of(context).size.width * 0.06),
        SizedBox(width: MediaQuery.of(context).size.width * 0.025),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.045,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}