import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nexo/screens/home.dart';
import 'package:video_player/video_player.dart';
import '../../core/storage/local_storage.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> with TickerProviderStateMixin {
  // Video
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;
  bool _videoFinished = false;

  // Splash
  bool _showSplash = false;
  bool _showBottomText = false;

  // User state
  late bool _isLoggedIn;

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _logoController;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = LocalStorage.isLoggedIn(); // pehle check kar lo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _setupAnimations();
    _initVideo();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/splash.mp4');

    try {
      await _videoController.initialize();
      if (mounted) {
        setState(() => _videoInitialized = true);
        _videoController.play();

        Timer(const Duration(seconds: 9), () {
          if (!_videoFinished) {
            _videoFinished = true;
            _onVideoComplete();
          }
        });
      }
    } catch (e) {
      _onVideoComplete();
    }
  }

  void _onVideoComplete() {
    if (!_isLoggedIn) {
      // New user: seedha login page
      _fadeController.forward().then((_) {
        _navigateNext();
      });
      return;
    }

    // Registered user: splash screen dikhao pehle
    _fadeController.forward().then((_) {
      if (mounted) {
        setState(() => _showSplash = true);
        _logoController.forward();

        Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showBottomText = true);
        });

        // 5 sec baad navigate to home
        Timer(const Duration(seconds: 5), _navigateNext);
      }
    });
  }

  void _navigateNext() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => _isLoggedIn
            ? const HomeScreen()
            : const Login(),
      ),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    _logoController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. VIDEO LAYER ──
          if (_videoInitialized && !_showSplash)
            Positioned.fill(
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0)
                    .animate(_fadeAnimation),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
              ),
            ),

          // Loading spinner
          if (!_videoInitialized && !_showSplash)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00CFFF),
              ),
            ),

          // ── 2. SPLASH LAYER (sirf logged in users ke liye) ──
          if (_showSplash)
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black,
                  child: Container(
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
                        // NEXO Logo
                        Center(
                          child: AnimatedBuilder(
                            animation: _logoController,
                            builder: (_, __) => Opacity(
                              opacity: _logoFadeAnim.value,
                              child: Transform.scale(
                                scale: _logoScaleAnim.value,
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
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
                            ),
                          ),
                        ),

                        // Bottom version + copyright
                        if (_showBottomText)
                          const Positioned(
                            bottom: 25,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}