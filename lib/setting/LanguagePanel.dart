import 'package:flutter/material.dart';

class LanguagePanel extends StatefulWidget {
  final VoidCallback onBackPressed;

  const LanguagePanel({super.key, required this.onBackPressed});

  @override
  State<LanguagePanel> createState() => _LanguagePanelState();
}

class _LanguagePanelState extends State<LanguagePanel> {
  // Default selected language state matching your screenshot
  String _selectedLanguage = 'English';
  final TextEditingController _searchController = TextEditingController();

  // List of standard languages
  final List<String> _languages = [
    'French',
    'English',
    'Spain',
    'Portuguese',
    'German',
    'Belarusian',
    'Bosnian',
    'Bulgarian',
    'Croatian',
    'Czech',
    'Estonian',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF232526), // Top dark grey/black shade
            Color(0xFF421E3F), // Bottom purple-ish hue tint
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title and floating translucent gear button layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onBackPressed,
                child: const Text(
                  "Language",
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

          // Search Field Text Input Box Layout
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: Colors.white70,
              decoration: const InputDecoration(
                hintText: "SEARCH",
                hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white38, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Scrollable Languages Option List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final bool isSelected = _selectedLanguage == language;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFCBD5E1).withOpacity(0.85) // Selection track styling capsule color
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        language,
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
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