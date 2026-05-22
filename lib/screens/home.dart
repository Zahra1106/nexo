import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/HomeController.dart';
import '../setting/SettingsPanel.dart';
import '../widgets/ChannelCard.dart';
import '../widgets/MovieCard.dart';
import 'live_tv.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ctrl = Get.put(HomeController());

  String _selectedItem = 'Home';

  int focusedSection = 0;
  int focusedChannel = 0;
  int focusedMovie   = 0;

  final channelScrollCtrl = ScrollController();
  final movieScrollCtrl   = ScrollController();

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Search',     'icon': Icons.search_outlined},
    {'title': 'Home',       'icon': Icons.home_outlined},
    {'title': 'Live TV',    'icon': Icons.tv_outlined},
    {'title': 'Catch-up TV','icon': Icons.schedule_outlined},
    {'title': 'Movies',     'icon': Icons.movie_outlined},
    {'title': 'Series TV',  'icon': Icons.live_tv_outlined},
    {'title': 'My List',    'icon': Icons.add_outlined},
    {'title': 'History',    'icon': Icons.history_outlined},
    {'title': 'Settings',   'icon': Icons.settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3282FF)),
            );
          }
          return Row(
            children: [
              // ── NEXO Style Sidebar ──
              _buildSidebar(),

              // ── Main Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ctrl.channels.isNotEmpty) _buildFeaturedBanner(),
                    _buildSectionLabel('Live TV'),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        controller: channelScrollCtrl,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ctrl.channels.length,
                        itemBuilder: (_, i) => SizedBox(
                          width: 220,
                          child: ChannelCard(
                            channel: ctrl.channels[i],
                            isFocused: focusedSection == 1 && focusedChannel == i,
                            onTap: () => _openChannel(i),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Movies'),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        controller: movieScrollCtrl,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ctrl.movies.length,
                        itemBuilder: (_, i) => MovieCard(
                          movie: ctrl.movies[i],
                          isFocused: focusedSection == 2 && focusedMovie == i,
                          onTap: () => _openMovie(i),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── NEXO Wide Sidebar ──────────────────────────────────
  Widget _buildSidebar() {
    return Container(
      width: 280,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NEXO Gradient Logo
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 32, top: 8),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF3282FF), Color(0xFFB832FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'NEXO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item       = _menuItems[index];
                final isSelected = _selectedItem == item['title'];
                final isSettings = item['title'] == 'Settings';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedItem = item['title'];
                        ctrl.selectedIndex.value = index;
                      });
                      _onMenuSelect(item['title'] as String);
                    },
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        if (isSelected) ...[
                          if (isSettings)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCBD5E1).withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB832FF).withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Positioned(
                              left: -20,
                              child: Container(
                                width: 180,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB832FF).withOpacity(0.35),
                                      blurRadius: 25,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected && !isSettings
                                ? Colors.white.withOpacity(0.03)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: isSelected && isSettings
                                    ? Colors.black87
                                    : Colors.white.withOpacity(0.85),
                                size: 22,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: isSelected && isSettings
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured Banner ────────────────────────────────────
  Widget _buildFeaturedBanner() {
    final ch = ctrl.channels[0];
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF111111),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (ch['stream_icon'] != null)
              CachedNetworkImage(
                imageUrl: ch['stream_icon'],
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFF111111)),
              ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'NOW LIVE',
                    style: TextStyle(
                      color: Color(0xFF3282FF),
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ch['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 10),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF3282FF), Color(0xFFB832FF)],
        ).createShader(bounds),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ── D-pad handler ──────────────────────────────────────
  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    setState(() {
      if (key == LogicalKeyboardKey.arrowRight) {
        if (focusedSection == 0) focusedSection = 1;
        else if (focusedSection == 1) {
          focusedChannel = (focusedChannel + 1).clamp(0, ctrl.channels.length - 1);
          _scrollChannels();
        } else if (focusedSection == 2) {
          focusedMovie = (focusedMovie + 1).clamp(0, ctrl.movies.length - 1);
          _scrollMovies();
        }
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        if (focusedSection == 1 && focusedChannel == 0) focusedSection = 0;
        else if (focusedSection == 1) {
          focusedChannel = (focusedChannel - 1).clamp(0, 999);
          _scrollChannels();
        } else if (focusedSection == 2) {
          focusedMovie = (focusedMovie - 1).clamp(0, 999);
          _scrollMovies();
        }
      } else if (key == LogicalKeyboardKey.arrowDown) {
        if (focusedSection == 1) focusedSection = 2;
        else if (focusedSection == 0) {
          ctrl.selectedIndex.value = (ctrl.selectedIndex.value + 1).clamp(0, _menuItems.length - 1);
        }
      } else if (key == LogicalKeyboardKey.arrowUp) {
        if (focusedSection == 2) focusedSection = 1;
        else if (focusedSection == 0) {
          ctrl.selectedIndex.value = (ctrl.selectedIndex.value - 1).clamp(0, _menuItems.length - 1);
        }
      } else if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
        if (focusedSection == 1) _openChannel(focusedChannel);
        if (focusedSection == 2) _openMovie(focusedMovie);
      }
    });
  }

  void _scrollChannels() {
    channelScrollCtrl.animateTo(
      focusedChannel * 228.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _scrollMovies() {
    movieScrollCtrl.animateTo(
      focusedMovie * 142.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _openChannel(int index) {
    Get.snackbar(
      'Opening', ctrl.channels[index]['name'] ?? '',
      backgroundColor: const Color(0xFF3282FF).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void _openMovie(int index) {
    Get.snackbar(
      'Opening', ctrl.movies[index]['name'] ?? '',
      backgroundColor: const Color(0xFFB832FF).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void _onMenuSelect(String title) {
    switch (title) {
      case 'Settings':
        Get.to(() => const SettingsPanel());
        break;
      case 'Live TV':
        Get.to(() => const LiveTvScreen());
        break;
      case 'Movies':
      case 'Series TV':
      // VOD screen — baad mein connect karenge
        break;
    }
  }

  @override
  void dispose() {
    channelScrollCtrl.dispose();
    movieScrollCtrl.dispose();
    super.dispose();
  }
}