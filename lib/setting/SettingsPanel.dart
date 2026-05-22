import 'package:flutter/material.dart';
import '../panel/NetworkInternetPanel.dart';
import '../panel/RemoteAccessoriesPanel.dart';
import '../panel/TvSettingsPanel.dart';
import 'DevicePreferencesPanel.dart';
import 'VpnProxyPanel.dart';


class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  String _selectedSettingOption = 'Device Preferences';

  bool _isInsideDevicePreferences = false;
  bool _isInsideVpnProxy          = false;
  bool _isInsideNetwork           = false;
  bool _isInsideTvSettings        = false;
  bool _isInsideRemote            = false;

  final List<Map<String, dynamic>> _settingsOptions = [
    {'title': 'Device Preferences', 'icon': Icons.tune_outlined},
    {'title': 'Network & Internet', 'icon': Icons.wifi_outlined},
    {'title': 'VPN & PROXY',        'icon': Icons.grid_view_outlined},
    {'title': 'TV Settings',        'icon': Icons.settings_brightness_outlined},
    {'title': 'Remote & Accessories', 'icon': Icons.speaker_group_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 2, child: SizedBox.shrink()),
        Expanded(
          flex: 3,
          child: _isInsideNetwork
              ? NetworkInternetPanel(
              onBackPressed: () => setState(() => _isInsideNetwork = false))
              : _isInsideVpnProxy
              ? VpnProxyPanel(
              onBackPressed: () => setState(() => _isInsideVpnProxy = false))
              : _isInsideTvSettings
              ? TvSettingsPanel(
              onBackPressed: () => setState(() => _isInsideTvSettings = false))
              : _isInsideRemote
              ? RemoteAccessoriesPanel(
              onBackPressed: () => setState(() => _isInsideRemote = false))
              : _isInsideDevicePreferences
              ? DevicePreferencesPanel(
              onBackPressed: () => setState(() => _isInsideDevicePreferences = false))
              : Container(
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
                const Text("Settings",
                    style: TextStyle(
                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const Text("general settings",
                    style: TextStyle(color: Color(0xFF29B6F6), fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _settingsOptions.length,
                    itemBuilder: (context, index) {
                      final option = _settingsOptions[index];
                      final bool isOptSelected =
                          _selectedSettingOption == option['title'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSettingOption = option['title'];

                              if (option['title'] == 'Device Preferences') {
                                _isInsideDevicePreferences = true;
                              } else if (option['title'] == 'Network & Internet') {
                                _isInsideNetwork = true;
                              } else if (option['title'] == 'VPN & PROXY') {
                                _isInsideVpnProxy = true;
                              } else if (option['title'] == 'TV Settings') {
                                _isInsideTvSettings = true;
                              } else if (option['title'] == 'Remote & Accessories') {
                                _isInsideRemote = true;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isOptSelected
                                  ? const Color(0xFFCBD5E1).withOpacity(0.85)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(option['icon'],
                                    color: isOptSelected
                                        ? Colors.black87 : Colors.white,
                                    size: 20),
                                const SizedBox(width: 16),
                                Text(option['title'],
                                    style: TextStyle(
                                      color: isOptSelected
                                          ? Colors.black87 : Colors.white,
                                      fontSize: 15,
                                      fontWeight: isOptSelected
                                          ? FontWeight.bold : FontWeight.w500,
                                    )),
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