import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtms/model/user.dart';
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/mainscreen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
     Future.delayed(const Duration(seconds: 3), () {
       loadUserCredentials();
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:[
            Color(0xFF2193b0),
            Color(0xFF6dd5ed), 
          ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/wtms.png", scale: 3.5),
              const CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 7, 139, 255)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserCredentials() async {
    print("HELLOOO");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    bool rem = (prefs.getBool('remember')) ?? false;

    print("EMAIL: $email");
    print("PASSWORD: $password");
    print("ISCHECKED: $rem");
    if (rem == true) {
      http.post(Uri.parse("${MyConfig.myurl}/wtms/php/login_worker.php"), body: {
        "email": email,
        "password": password,
      }).then((response) {
        print(response.body);
        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata['status'] == 'success') {
            var userdata = jsondata['data'];
            User user = User.fromJson(userdata[0]);
            print(user.userName);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          } else {
            User user = User(
              userId: "0",
              userName: "Guest",
              userEmail: "",
              userPhone: "",
              userAddress: "",
              userPassword: "",
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          }
        }
      });
    } else {
      User user = User(
        userId: "0",
        userName: "Guest",
        userEmail: "",
        userPhone: "",
        userAddress: "",
        userPassword: "",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(user: user)),
      );
    }
  }
}