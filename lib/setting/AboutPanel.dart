import 'package:flutter/material.dart';

class AboutPanel extends StatelessWidget {
  final VoidCallback onBackPressed;

  const AboutPanel({super.key, required this.onBackPressed});

  // Helper method to build standard informational rows
  Widget _buildInfoTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'monospace', // Gives it a clean technical look for addresses
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF232526),
            Color(0xFF421E3F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header layout with click action to return back
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBackPressed,
                child: const Text(
                  "About",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white60,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Scrollable system specifications list
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // System Update actionable tile
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "System Update",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),

                _buildInfoTile("Device Name", "DVM4KA01"),
                const Divider(color: Colors.white10, height: 1),

                _buildInfoTile("IP Address", "fe80::42aa:56ff:fea8:a79f\n192.168.1.5"),
                const Divider(color: Colors.white10, height: 1),

                _buildInfoTile("Mac Address", "40:aa:56:a8:a7:9f"),
                const Divider(color: Colors.white10, height: 1),

                _buildInfoTile("Bluetooth Address", "40:aa:56:a8:a7:a0"),
                const Divider(color: Colors.white10, height: 1),

                _buildInfoTile("Model", "DVM4KA01"),
                const Divider(color: Colors.white10, height: 1),

                _buildInfoTile("Version", "Android Pie"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}