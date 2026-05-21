import 'package:flutter/material.dart';

class VpnProxyPanel extends StatefulWidget {
  final VoidCallback onBackPressed;

  const VpnProxyPanel({super.key, required this.onBackPressed});

  @override
  State<VpnProxyPanel> createState() => _VpnProxyPanelState();
}

class _VpnProxyPanelState extends State<VpnProxyPanel> {
  // Controllers for VPN Form fields
  final _vpnHostController = TextEditingController();
  final _vpnPortController = TextEditingController();
  final _vpnUserController = TextEditingController();
  final _vpnPassController = TextEditingController();

  // Controllers for PROXY Form fields
  final _proxyHostController = TextEditingController();
  final _proxyPortController = TextEditingController();
  final _proxyTypeController = TextEditingController();
  final _proxyUserController = TextEditingController();
  final _proxyPassController = TextEditingController();

  @override
  void dispose() {
    _vpnHostController.dispose();
    _vpnPortController.dispose();
    _vpnUserController.dispose();
    _vpnPassController.dispose();
    _proxyHostController.dispose();
    _proxyPortController.dispose();
    _proxyTypeController.dispose();
    _proxyUserController.dispose();
    _proxyPassController.dispose();
    super.dispose();
  }

  // Custom helper widget to build uniform forms inputs
  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscure = false}) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        ),
      ),
    );
  }

  // Custom helper widget to build the sub-header label bars (VPN / PROXY)
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1).withOpacity(0.85),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.black54, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold,
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
          // Header View Title Layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onBackPressed,
                child: const Text(
                  "VPN & PROXY",
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

          // Scrollable Layout Forms
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // === 1. VPN SECTION ===
                _buildSectionHeader("VPN"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_vpnHostController, "Server host")),
                    const SizedBox(width: 10),
                    Expanded(flex: 1, child: _buildTextField(_vpnPortController, "Port")),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTextField(_vpnUserController, "Username"),
                const SizedBox(height: 10),
                _buildTextField(_vpnPassController, "Password", obscure: true),

                const SizedBox(height: 24),

                // === 2. PROXY SECTION ===
                _buildSectionHeader("PROXY"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_proxyHostController, "Server host")),
                    const SizedBox(width: 10),
                    Expanded(flex: 1, child: _buildTextField(_proxyPortController, "Port")),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_proxyTypeController, "Proxy Type")),
                    const SizedBox(width: 10),
                    Container(
                      height: 38,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text("X", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_proxyUserController, "Username")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(_proxyPassController, "Password", obscure: true)),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}