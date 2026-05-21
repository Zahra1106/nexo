import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexo/screens/home.dart';
import '../../core/storage/local_storage.dart';
import 'login.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> {
  bool showBottomText = false;

  @override
  void initState() {
    super.initState();

    // 5 sec baad version text show hoga
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showBottomText = true;
        });
      }
    });

    // 10 sec baad check karo — login hua tha ya nahi
    Timer(const Duration(seconds: 10), () {
      if (LocalStorage.isLoggedIn()) {
        // Pehle se logged in — seedha home
        Get.off(() => const HomeScreen());
      } else {
        // Pehli baar — login screen
        Get.off(() => const Login());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF00BFA5),
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            // NEXO logo — center
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF00CFFF),
                    Color(0xFF6A5CFF),
                    Color(0xFFFF00CC),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: const Text(
                  "NEXO",
                  style: TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),

            // Bottom version + copyright
            if (showBottomText)
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Column(
                  children: const [
                    Text(
                      "V1.0.0",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Copyright © NEXO TV, All Rights Reserved.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}