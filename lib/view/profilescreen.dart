import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wtms/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/mainscreen.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  File? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/php/get_profile.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"worker_id": widget.user.userId ?? ""},
      );

      if (response.statusCode == 200) {
        final jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          final data = jsondata['data'];
          setState(() {
            idController.text = data['worker_id'].toString();
            nameController.text = data['full_name'] ?? "";
            emailController.text = data['email'] ?? "";
            phoneController.text = data['phone'] ?? "";
            addressController.text = data['address'] ?? "";
            widget.user.userImage = data['profile_image_base64'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsondata['message'] ?? "Failed to load profile")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> profileImage;

    if (_image != null) {
      profileImage = FileImage(_image!) as ImageProvider<Object>;
    } else if (widget.user.userImage != null && widget.user.userImage!.isNotEmpty) {
      try {
        final decoded = base64Decode(widget.user.userImage!);
        profileImage = MemoryImage(decoded);
      } catch (_) {
        profileImage = const AssetImage("assets/images/profile.png");
      }
    } else {
      profileImage = const AssetImage("assets/images/profile.png");
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // BACK BUTTON REMOVED HERE - only text remains
                          const Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            color: Colors.white.withOpacity(0.95),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 10,
                            margin: const EdgeInsets.all(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: _selectImage,
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: profileImage,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildFormField(
                                      "Worker ID",
                                      controller: idController,
                                      icon: Icons.badge,
                                      enabled: false,
                                      validator: (_) => null,
                                    ),
                                    _buildFormField(
                                      "Name",
                                      controller: nameController,
                                      icon: Icons.person,
                                      validator: (val) => val!.trim().isEmpty ? 'Name is required' : null,
                                    ),
                                    _buildFormField(
                                      "Email",
                                      controller: emailController,
                                      icon: Icons.email,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Email is required';
                                        final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                        return regex.hasMatch(val) ? null : 'Invalid email format';
                                      },
                                    ),
                                    _buildFormField(
                                      "Phone",
                                      controller: phoneController,
                                      icon: Icons.phone,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Phone is required';
                                        final regex = RegExp(r'^[0-9+\- ]{9,15}$');
                                        return regex.hasMatch(val) ? null : 'Invalid phone number';
                                      },
                                    ),
                                    _buildFormField(
                                      "Address",
                                      controller: addressController,
                                      icon: Icons.home,
                                      maxLines: 3,
                                      validator: (val) => val!.trim().isEmpty ? 'Address is required' : null,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => _showSaveConfirmationDialog(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2193b0),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => _showCancelConfirmationDialog(context),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFormField(String label,
      {required TextEditingController controller,
      required IconData icon,
      required String? Function(String?) validator,
      bool enabled = true,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Changes?"),
          content: const Text("Are you sure you want to save your changes?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _saveProfile(); // Proceed with saving
              },
            ),
          ],
        );
      },
    );
  }

  void _saveProfile() async {
    // form is already validated in dialog before calling this
    String fullName = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    String? base64Image;
    if (_image != null) {
      List<int> imageBytes = await _image!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    http.post(Uri.parse("${MyConfig.myurl}/wtms/php/update_profile.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "worker_id": widget.user.userId ?? "",
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "address": address,
        "image": base64Image ?? "",
      },
    ).then((response) {
      if (response.statusCode == 200 && response.body.contains('status')) {
        Map<String, dynamic> jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Profile updated successfully"),
          ));
          setState(() {
            widget.user.userName = fullName;
            widget.user.userEmail = email;
            widget.user.userPhone = phone;
            widget.user.userAddress = address;
            if (base64Image != null) {
              widget.user.userImage = base64Image;
            }
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(user: widget.user)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsondata['message'] ?? "Update failed"),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid response from server"),
        ));
      }
    }).catchError((error) {
      print("HTTP error: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connection failed"),
      ));
    });
  }
}

void _showCancelConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Discard Changes?"),
        content: const Text("Are you sure you want to cancel and discard your changes?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Navigate back
            },
          ),
        ],
      );
    },
  );
}
