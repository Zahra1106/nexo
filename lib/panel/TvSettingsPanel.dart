import 'package:flutter/material.dart';

class TvSettingsPanel extends StatefulWidget {
  final VoidCallback onBackPressed;
  const TvSettingsPanel({super.key, required this.onBackPressed});

  @override
  State<TvSettingsPanel> createState() => _TvSettingsPanelState();
}

class _TvSettingsPanelState extends State<TvSettingsPanel> {
  double _brightness = 0.7;
  double _contrast   = 0.6;
  double _sharpness  = 0.5;
  String _displayMode     = 'Auto';
  String _hdmiCecMode     = 'Enabled';
  bool   _hdr             = true;
  bool   _dolbyVision     = false;
  bool   _autoSleep       = true;
  int    _sleepTimer      = 30;

  final List<String> _displayModes = ['Auto', '4K HDR', '1080p', '720p'];
  final List<String> _hdmiOptions  = ['Enabled', 'Disabled'];
  final List<int>    _sleepOptions = [15, 30, 60, 120];

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

  Widget _buildSliderRow(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('${(value * 100).toInt()}%',
                  style: const TextStyle(color: Color(0xFF29B6F6), fontSize: 12)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              thumbColor: const Color(0xFF29B6F6),
              activeTrackColor: const Color(0xFF29B6F6),
              inactiveTrackColor: Colors.white12,
              overlayColor: const Color(0xFF29B6F6).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 2,
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
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

  Widget _buildChipSelector(String label, List<String> options, String selected,
      ValueChanged<String> onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.map((o) => GestureDetector(
              onTap: () => onSelected(o),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected == o
                      ? const Color(0xFFCBD5E1).withOpacity(0.85)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(o, style: TextStyle(
                  color: selected == o ? Colors.black87 : Colors.white70,
                  fontSize: 13,
                  fontWeight: selected == o ? FontWeight.bold : FontWeight.normal,
                )),
              ),
            )).toList(),
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
                child: const Text("TV Settings",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_brightness_outlined, color: Colors.white60, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Display
                _buildSectionHeader("Display"),
                const SizedBox(height: 12),
                _buildChipSelector("Display Mode", _displayModes, _displayMode,
                        (v) => setState(() => _displayMode = v)),
                _buildToggleRow("HDR", Icons.hdr_on_outlined, _hdr,
                        (v) => setState(() => _hdr = v)),
                _buildToggleRow("Dolby Vision", Icons.wb_sunny_outlined, _dolbyVision,
                        (v) => setState(() => _dolbyVision = v)),
                const SizedBox(height: 8),
                _buildSliderRow("Brightness", _brightness,
                        (v) => setState(() => _brightness = v)),
                _buildSliderRow("Contrast", _contrast,
                        (v) => setState(() => _contrast = v)),
                _buildSliderRow("Sharpness", _sharpness,
                        (v) => setState(() => _sharpness = v)),

                const SizedBox(height: 20),
                // HDMI
                _buildSectionHeader("HDMI"),
                const SizedBox(height: 12),
                _buildChipSelector("HDMI CEC", _hdmiOptions, _hdmiCecMode,
                        (v) => setState(() => _hdmiCecMode = v)),

                const SizedBox(height: 20),
                // Power
                _buildSectionHeader("Power"),
                const SizedBox(height: 12),
                _buildToggleRow("Auto Sleep", Icons.bedtime_outlined, _autoSleep,
                        (v) => setState(() => _autoSleep = v)),
                if (_autoSleep)
                  _buildChipSelector("Sleep Timer (min)",
                      _sleepOptions.map((e) => '$e').toList(),
                      '$_sleepTimer',
                          (v) => setState(() => _sleepTimer = int.parse(v))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}