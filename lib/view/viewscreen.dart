import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wtms/model/user.dart';
import 'package:wtms/view/profilescreen.dart';

class ProfileViewPage extends StatelessWidget {
  final User user;
  const ProfileViewPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Determine profile image
    ImageProvider<Object> profileImage;

    if (user.userImage != null && user.userImage!.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(user.userImage!));
      } catch (_) {
        profileImage = const AssetImage("assets/images/profile.png");
      }
    } else {
      profileImage = const AssetImage("assets/images/profile.png");
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: profileImage,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 24),
                      _buildIconRow(Icons.badge, "ID", user.userId ?? "-"),
                      const SizedBox(height: 12),
                      _buildIconRow(Icons.person, "Name", user.userName ?? "-"),
                      const SizedBox(height: 12),
                      _buildIconRow(Icons.email, "Email", user.userEmail ?? "-"),
                      const SizedBox(height: 12),
                      _buildIconRow(Icons.phone, "Phone", user.userPhone ?? "-"),
                      const SizedBox(height: 12),
                      _buildIconRow(Icons.home, "Address", user.userAddress ?? "-"),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Profile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2193b0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2193b0)),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2193b0),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
