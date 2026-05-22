import 'package:flutter/material.dart';

class NetworkInternetPanel extends StatefulWidget {
  final VoidCallback onBackPressed;
  const NetworkInternetPanel({super.key, required this.onBackPressed});

  @override
  State<NetworkInternetPanel> createState() => _NetworkInternetPanelState();
}

class _NetworkInternetPanelState extends State<NetworkInternetPanel> {
  bool _wifiEnabled = true;
  bool _ethernetEnabled = false;
  bool _autoConnect = true;
  bool _hotspotEnabled = false;
  String _selectedNetwork = 'Home_WiFi_5G';

  final List<Map<String, dynamic>> _networks = [
    {'name': 'Home_WiFi_5G',    'signal': 4, 'locked': true},
    {'name': 'Home_WiFi_2.4G',  'signal': 3, 'locked': true},
    {'name': 'Office_Network',  'signal': 2, 'locked': true},
    {'name': 'Guest_Network',   'signal': 1, 'locked': false},
  ];

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
          Text(title, style: const TextStyle(
            color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, color: Colors.white60, size: 18),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ]),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF29B6F6),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalIcon(int bars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) => Container(
        width: 4, height: 4.0 + (i * 3),
        margin: const EdgeInsets.only(right: 2),
        color: i < bars ? const Color(0xFF29B6F6) : Colors.white24,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF232526), Color(0xFF421E3F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onBackPressed,
                child: const Text("Network & Internet",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_outlined, color: Colors.white60, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // WiFi Section
                _buildSectionHeader("Wi-Fi"),
                const SizedBox(height: 12),
                _buildToggleRow("Wi-Fi", Icons.wifi_outlined, _wifiEnabled,
                        (v) => setState(() => _wifiEnabled = v)),
                _buildToggleRow("Auto-connect", Icons.autorenew_outlined, _autoConnect,
                        (v) => setState(() => _autoConnect = v)),

                if (_wifiEnabled) ...[
                  const SizedBox(height: 12),
                  const Text("Available Networks",
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 8),
                  ..._networks.map((n) => GestureDetector(
                    onTap: () => setState(() => _selectedNetwork = n['name']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedNetwork == n['name']
                            ? const Color(0xFFCBD5E1).withOpacity(0.85)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          _buildSignalIcon(n['signal']),
                          const SizedBox(width: 12),
                          Expanded(child: Text(n['name'],
                            style: TextStyle(
                              color: _selectedNetwork == n['name'] ? Colors.black87 : Colors.white,
                              fontSize: 14,
                            ),
                          )),
                          if (n['locked'])
                            Icon(Icons.lock_outline, size: 14,
                                color: _selectedNetwork == n['name'] ? Colors.black54 : Colors.white38),
                          if (_selectedNetwork == n['name'])
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.check_circle, color: Color(0xFF29B6F6), size: 16),
                            ),
                        ],
                      ),
                    ),
                  )),
                ],

                const SizedBox(height: 20),
                // Ethernet Section
                _buildSectionHeader("Ethernet"),
                const SizedBox(height: 12),
                _buildToggleRow("Ethernet", Icons.cable_outlined, _ethernetEnabled,
                        (v) => setState(() => _ethernetEnabled = v)),
                if (_ethernetEnabled)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(label: "IP Address",  value: "192.168.1.105"),
                        _InfoRow(label: "Gateway",     value: "192.168.1.1"),
                        _InfoRow(label: "DNS",         value: "8.8.8.8"),
                        _InfoRow(label: "MAC Address", value: "A4:C3:F0:XX:XX:XX"),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                // Hotspot Section
                _buildSectionHeader("Hotspot"),
                const SizedBox(height: 12),
                _buildToggleRow("Mobile Hotspot", Icons.wifi_tethering_outlined, _hotspotEnabled,
                        (v) => setState(() => _hotspotEnabled = v)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text(value,  style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}