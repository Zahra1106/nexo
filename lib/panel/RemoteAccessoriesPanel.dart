import 'package:flutter/material.dart';

class RemoteAccessoriesPanel extends StatefulWidget {
  final VoidCallback onBackPressed;
  const RemoteAccessoriesPanel({super.key, required this.onBackPressed});

  @override
  State<RemoteAccessoriesPanel> createState() => _RemoteAccessoriesPanelState();
}

class _RemoteAccessoriesPanelState extends State<RemoteAccessoriesPanel> {
  bool _bluetoothEnabled = true;
  bool _remoteVibration  = true;
  bool _remoteSound      = false;
  String _selectedRemoteType = 'Firestick Remote';

  final List<Map<String, dynamic>> _pairedDevices = [
    {'name': 'Firestick Remote',   'icon': Icons.settings_remote_outlined, 'battery': 85},
    {'name': 'Bluetooth Headset',  'icon': Icons.headphones_outlined,       'battery': 62},
  ];

  final List<String> _remoteTypes = [
    'Firestick Remote', 'Alexa Voice Remote', 'Game Controller',
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
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF29B6F6)),
        ],
      ),
    );
  }

  Widget _buildBatteryBar(int percent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48, height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                color: percent > 50
                    ? const Color(0xFF29B6F6)
                    : percent > 20
                    ? Colors.amber
                    : Colors.redAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('$percent%', style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
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
                child: const Text("Remote & Accessories",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), shape: BoxShape.circle,
                ),
                child: const Icon(Icons.speaker_group_outlined, color: Colors.white60, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Bluetooth
                _buildSectionHeader("Bluetooth"),
                const SizedBox(height: 12),
                _buildToggleRow("Bluetooth", Icons.bluetooth_outlined, _bluetoothEnabled,
                        (v) => setState(() => _bluetoothEnabled = v)),

                if (_bluetoothEnabled) ...[
                  const SizedBox(height: 12),
                  const Text("Paired Devices",
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 8),
                  ..._pairedDevices.map((d) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(d['icon'], color: const Color(0xFF29B6F6), size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(d['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 14))),
                        _buildBatteryBar(d['battery']),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Color(0xFF29B6F6), size: 16),
                          SizedBox(width: 6),
                          Text("Pair New Device",
                              style: TextStyle(color: Color(0xFF29B6F6), fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                // Remote Settings
                _buildSectionHeader("Remote Settings"),
                const SizedBox(height: 12),
                const Text("Remote Type",
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 8),
                ..._remoteTypes.map((r) => GestureDetector(
                  onTap: () => setState(() => _selectedRemoteType = r),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedRemoteType == r
                          ? const Color(0xFFCBD5E1).withOpacity(0.85)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.settings_remote_outlined,
                            color: _selectedRemoteType == r ? Colors.black54 : Colors.white38,
                            size: 18),
                        const SizedBox(width: 12),
                        Text(r, style: TextStyle(
                          color: _selectedRemoteType == r ? Colors.black87 : Colors.white,
                          fontSize: 14,
                          fontWeight: _selectedRemoteType == r ? FontWeight.bold : FontWeight.normal,
                        )),
                        const Spacer(),
                        if (_selectedRemoteType == r)
                          const Icon(Icons.check_circle, color: Color(0xFF29B6F6), size: 16),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 12),
                _buildToggleRow("Vibration", Icons.vibration_outlined, _remoteVibration,
                        (v) => setState(() => _remoteVibration = v)),
                _buildToggleRow("Button Sounds", Icons.volume_up_outlined, _remoteSound,
                        (v) => setState(() => _remoteSound = v)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}