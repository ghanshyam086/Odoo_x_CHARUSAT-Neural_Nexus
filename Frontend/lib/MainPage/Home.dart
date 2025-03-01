import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../MainPage/HomeComponents/aichatbot.dart';
import '../ProfileComponent/ProfilePage.dart';
import '../MainPage/HomeComponents/articles.dart';
import 'HomeComponents/news.dart';
import 'HomeComponents/content.dart'; // Uncommented
import 'HomeComponents/labreport.dart'; // Uncommented
import 'HomeComponents/NearHospitals.dart'; // Uncommented, renamed to DoctorScreen for consistency
import 'HomeComponents/Aboutus.dart';
import 'HomeComponents/settings.dart';
import 'package:fitsync/Step_Counter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Ensure this is properly declared as an int variable

  final List<Widget> _pages = [
    const HomeContent(),
    const AIChatbotPage(),
    const ProfilePage(),
    const ContentPage(), // Uncommented
    const LabReportPage(), // Uncommented
  ];

  List<Article> _homeArticles = [];
  List<News> _homeNews = [];
  bool _isLoadingArticles = true;
  bool _isLoadingNews = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchHomeArticles();
    _fetchHomeNews();
  }

  Future<void> _fetchHomeArticles() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://newsapi.org/v2/everything?q=health+articles&language=en&sortBy=publishedAt&apiKey=8ee2794cd73a41b68c8d3c399d5710c4'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        setState(() {
          _homeArticles = articles.take(3).toList(); // Limit to 2–3 articles
          _isLoadingArticles = false;
        });
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingArticles = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching articles: $e')),
      );
    }
  }

  Future<void> _fetchHomeNews() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://newsapi.org/v2/everything?q=health&language=en&sortBy=publishedAt&apiKey=8ee2794cd73a41b68c8d3c399d5710c4'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final news = (data['articles'] as List)
            .map((article) => News.fromJson(article))
            .toList();
        setState(() {
          _homeNews = news.take(3).toList(); // Limit to 2–3 news items
          _isLoadingNews = false;
        });
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingNews = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching news: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent exiting the app directly; return to home instead
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Prevent back navigation
        }
        return true; // Allow app exit from home
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Fit Sync',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade900,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.article, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesPage())),
              tooltip: 'View Articles',
            ),
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorScreen())),
              tooltip: 'Nearby Doctors',
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: SafeArea(child: _pages[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "AI Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Content"),
            BottomNavigationBarItem(icon: Icon(Icons.report), label: "Lab Reports"),
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
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue.shade50,
        child: Column(
          children: [
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
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.chat,
                    title: 'AI Chat',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.video_library,
                    title: 'Content',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.report,
                    title: 'Lab Reports',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 4;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.article,
                    title: 'Articles',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesPage()));
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.newspaper,
                    title: 'News',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsPage()));
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.location_on,
                    title: 'Nearby Doctors',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info,
                    title: 'About Us',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()));
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                    },
                  ),
                  Divider(color: Colors.grey),
                  // Removed logout-related code
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
        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045, color: color ?? Colors.black87, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      hoverColor: Colors.blue.shade100.withOpacity(0.2),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    _fetchHomeArticles();
    _fetchHomeNews();
  }

  Future<void> _fetchHomeArticles() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://newsapi.org/v2/everything?q=health+articles&language=en&sortBy=publishedAt&apiKey=8ee2794cd73a41b68c8d3c399d5710c4'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        setState(() {
          _homeArticles = articles.take(3).toList();
          _isLoadingArticles = false;
        });
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingArticles = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching articles: $e')),
      );
    }
  }

  Future<void> _fetchHomeNews() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://newsapi.org/v2/everything?q=health&language=en&sortBy=publishedAt&apiKey=8ee2794cd73a41b68c8d3c399d5710c4'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final news = (data['articles'] as List)
            .map((article) => News.fromJson(article))
            .toList();
        setState(() {
          _homeNews = news.take(3).toList();
          _isLoadingNews = false;
        });
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingNews = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching news: $e')),
      );
    }
  }

  List<Article> _homeArticles = [];
  List<News> _homeNews = [];
  bool _isLoadingArticles = true;
  bool _isLoadingNews = true;

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
                        _buildHealthButton(context, "Profile", Icons.person, Colors.blue.shade300, 1),
                        _buildHealthButton(context, "Content", Icons.video_library, Colors.green.shade300, 2),
                        _buildHealthButton(context, "Lab Reports", Icons.report, Colors.blue.shade300, 3),
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Health News with Fetched Articles (Images Included)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health News",
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
                _isLoadingNews
                    ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                    : _homeNews.isEmpty
                    ? const Center(child: Text('No health news available'))
                    : Column(
                  children: _homeNews.map((news) {
                    return _buildNewsCard(context, news);
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Featured Articles with Fetched Articles (Text Only)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Featured Articles",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.purple.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                _isLoadingArticles
                    ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                    : _homeArticles.isEmpty
                    ? const Center(child: Text('No articles available'))
                    : Column(
                  children: _homeArticles.map((article) {
                    return _buildArticleCard(context, article);
                  }).toList(),
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
    bool isSelected = _selectedIndex == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade900 : color,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02,
          horizontal: MediaQuery.of(context).size.width * 0.02,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: isSelected ? Colors.blue.shade200 : Colors.transparent, width: 1),
        ),
        elevation: isSelected ? 8 : 4,
      ),
      onPressed: () {
        // setState(() {
        //   _selectedIndex = index;
        // });
        switch (label) {
          case "AI Chat":
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatbotPage()));
            break;
          case "Profile":
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
          case "Content":
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentPage()));
            break;
          case "Lab Reports":
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LabReportPage()));
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: MediaQuery.of(context).size.width * 0.07,
            color: isSelected ? Colors.white : Colors.black87,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.0075),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
              shadows: [
                Shadow(
                  color: isSelected ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
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

  Widget _buildArticleCard(BuildContext context, Article article) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ArticlesPage()),
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      color: Colors.purple.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  shadows: [
                    Shadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, News news) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewsPage()),
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: news.urlToImage != null && news.urlToImage!.isNotEmpty
                    ? Image.network(
                  news.urlToImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                )
                    : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.health_and_safety, color: Colors.blue, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            color: Colors.blue.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        shadows: [
                          Shadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (news.publishedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Published: ${_formatDate(news.publishedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return 'Unknown';
    }
  }
}

class _selectedIndex {
}

class Article {
  final String title;
  final String description;
  final String url;

  Article({required this.title, required this.description, required this.url});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? '',
    );
  }
}

class News {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String? publishedAt;

  News({required this.title, required this.description, required this.url, this.urlToImage, this.publishedAt});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description available',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
    );
  }
}