import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wtms/model/user.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:wtms/view/profilescreen.dart';
import 'package:wtms/view/tasklistscreen.dart';
import 'package:wtms/view/submissionhistoryscreen.dart';
import 'package:wtms/view/viewscreen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  final List<String> _pageTitles = [
    'Home',
    'Tasks',
    'Submission History',
    'Profile',
  ];

  final List<IconData> _pageIcons = [
    Icons.home,
    Icons.list_alt,
    Icons.history,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildWelcomePage(),
      TaskListScreen(user: widget.user),
      SubmissionHistoryScreen(user: widget.user),
      ProfileViewPage(user: widget.user),
    ];
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _selectPage(int index) {
    Navigator.pop(context);
    setState(() {
      _currentIndex = index;
    });
  }

  ImageProvider<Object>? _buildProfileImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) return null;
    try {
      Uint8List imageBytes = base64Decode(base64Image);
      return MemoryImage(imageBytes);
    } catch (_) {
      return null;
    }
  }

  Widget _buildWelcomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Welcome to WTMS",
            style: TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 76, 66, 191),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Image.asset(
            "assets/images/welcome.png",
            scale: 5.5,
          ),
          const SizedBox(height: 24),
          Text(
            widget.user.userName ?? "User",
            style: const TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 76, 66, 191),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6dd5ed),
        foregroundColor: Colors.black, // Sets icon and title text color to black
        title: Row(
          children: [
            Icon(_pageIcons[_currentIndex], color: Colors.black),
            const SizedBox(width: 10),
              Text(
                _pageTitles[_currentIndex],
                style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2193b0),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.userName ?? 'Guest'),
              accountEmail: Text(widget.user.userEmail ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _buildProfileImage(widget.user.userImage),
                child: (widget.user.userImage == null || widget.user.userImage!.isEmpty)
                    ? Text(
                        widget.user.userName?.substring(0, 1).toUpperCase() ?? 'G',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => _selectPage(0),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Tasks'),
              onTap: () => _selectPage(1),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Submission History'),
              onTap: () => _selectPage(2),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile Setting'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              iconColor: Colors.red,
              title: const Text('Logout'),
              textColor: Colors.red,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
