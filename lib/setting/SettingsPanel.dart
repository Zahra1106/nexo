import 'package:flutter/material.dart';
import 'DevicePreferencesPanel.dart';
import 'VpnProxyPanel.dart'; // Import the new VPN Proxy panel layout context here

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  String _selectedSettingOption = 'Device Preferences';

  // Navigation tracking conditional states
  bool _isInsideDevicePreferences = false;
  bool _isInsideVpnProxy = false;

  final List<Map<String, dynamic>> _settingsOptions = [
    {'title': 'Device Preferences', 'icon': Icons.tune_outlined},
    {'title': 'Network & Internet', 'icon': Icons.wifi_outlined},
    {'title': 'VPN & PROXY', 'icon': Icons.grid_view_outlined},
    {'title': 'TV Settings', 'icon': Icons.settings_brightness_outlined},
    {'title': 'Remote & Accessories', 'icon': Icons.speaker_group_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left side blank space area alignment
        const Expanded(
          flex: 2,
          child: SizedBox.shrink(),
        ),

        // Right side target layout router branch logic
        Expanded(
          flex: 3,
          child: _isInsideVpnProxy
              ? VpnProxyPanel(
            onBackPressed: () {
              setState(() {
                _isInsideVpnProxy = false;
              });
            },
          )
              : _isInsideDevicePreferences
              ? DevicePreferencesPanel(
            onBackPressed: () {
              setState(() {
                _isInsideDevicePreferences = false;
              });
            },
          )
              : Container(
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
                const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "general settings",
                  style: TextStyle(
                    color: Color(0xFF29B6F6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _settingsOptions.length,
                    itemBuilder: (context, index) {
                      final option = _settingsOptions[index];
                      final bool isOptSelected = _selectedSettingOption == option['title'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSettingOption = option['title'];

                              // Dynamic view redirection layer toggles
                              if (option['title'] == 'Device Preferences') {
                                _isInsideDevicePreferences = true;
                              } else if (option['title'] == 'VPN & PROXY') {
                                _isInsideVpnProxy = true;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isOptSelected
                                  ? const Color(0xFFCBD5E1).withOpacity(0.85)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  option['icon'],
                                  color: isOptSelected ? Colors.black87 : Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  option['title'],
                                  style: TextStyle(
                                    color: isOptSelected ? Colors.black87 : Colors.white,
                                    fontSize: 15,
                                    fontWeight: isOptSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}