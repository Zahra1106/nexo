import 'package:flutter/material.dart';
import 'AboutPanel.dart';
import 'LanguagePanel.dart'; // Import the new language file component here

class DevicePreferencesPanel extends StatefulWidget {
  final VoidCallback onBackPressed;

  const DevicePreferencesPanel({super.key, required this.onBackPressed});

  @override
  State<DevicePreferencesPanel> createState() => _DevicePreferencesPanelState();
}

class _DevicePreferencesPanelState extends State<DevicePreferencesPanel> {
  String _selectedSubOption = 'Device Preferences';

  // State navigation toggles
  bool _isInsideAbout = false;
  bool _isInsideLanguage = false;

  final List<Map<String, dynamic>> _subOptions = [
    {'title': 'About', 'icon': Icons.info_outline},
    {'title': 'Date & Time', 'icon': Icons.schedule_outlined},
    {'title': 'Language', 'icon': Icons.language_outlined},
    {'title': 'Keyboard', 'icon': Icons.keyboard_alt_outlined},
    {'title': 'Sound', 'icon': Icons.volume_up_outlined},
    {'title': 'Storage', 'icon': Icons.folder_open_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Check if sub-panel state layer requires rendering LanguagePanel
    if (_isInsideLanguage) {
      return LanguagePanel(
        onBackPressed: () {
          setState(() {
            _isInsideLanguage = false;
          });
        },
      );
    }

    // 2. Check if sub-panel state layer requires rendering AboutPanel
    if (_isInsideAbout) {
      return AboutPanel(
        onBackPressed: () {
          setState(() {
            _isInsideAbout = false;
          });
        },
      );
    }

    // 3. Fallback to normal default view list container branch
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onBackPressed,
                child: const Text(
                  "Device Preferences",
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
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _subOptions.length,
              itemBuilder: (context, index) {
                final option = _subOptions[index];
                final bool isSelected = _selectedSubOption == option['title'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSubOption = option['title'];

                        // Handles explicit layout branches
                        if (option['title'] == 'About') {
                          _isInsideAbout = true;
                        } else if (option['title'] == 'Language') {
                          _isInsideLanguage = true;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFCBD5E1).withOpacity(0.85)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected ? Colors.black87 : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            option['title'],
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.white,
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
    );
  }
}