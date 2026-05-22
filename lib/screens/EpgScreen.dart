import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/EpgController.dart';


class EpgScreen extends StatefulWidget {
  final String streamId;
  final String channelName;

  const EpgScreen({
    super.key,
    required this.streamId,
    required this.channelName,
  });

  @override
  State<EpgScreen> createState() => _EpgScreenState();
}

class _EpgScreenState extends State<EpgScreen> {
  final ctrl = Get.put(EpgController());
  int focusedIndex = 0;
  final scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    ctrl.loadEpg(widget.streamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCurrentNext(),
            const SizedBox(height: 8),
            _buildDivider('Full Schedule'),
            Expanded(child: _buildProgramList()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      color: const Color(0xFF0D0D0D),
      child: Row(
        children: [
          // Back button
          Focus(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF00D4FF),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.tv, color: Color(0xFF00D4FF), size: 20),
          const SizedBox(width: 10),
          Text(
            widget.channelName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Current time
          Text(
            _currentTime(),
            style: const TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Current + Next program cards ──────────────────────────────────────────
  Widget _buildCurrentNext() {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Current
            Expanded(
              child: _buildInfoCard(
                label: 'NOW',
                program: ctrl.currentProgram.value,
                showProgress: true,
                color: const Color(0xFF00D4FF),
              ),
            ),
            const SizedBox(width: 12),
            // Next
            Expanded(
              child: _buildInfoCard(
                label: 'NEXT',
                program: ctrl.nextProgram.value,
                showProgress: false,
                color: Colors.white24,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoCard({
    required String label,
    required EpgProgram? program,
    required bool showProgress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            program?.title ?? 'No info available',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (program != null) ...[
            const SizedBox(height: 4),
            Text(
              program.timeRange,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
          // Progress bar — sirf current ke liye
          if (showProgress && program != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: program.progressPercent,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Full program list ─────────────────────────────────────────────────────
  Widget _buildProgramList() {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
        );
      }

      if (ctrl.errorMsg.value.isNotEmpty) {
        return Center(
          child: Text(
            ctrl.errorMsg.value,
            style: const TextStyle(color: Colors.white38),
          ),
        );
      }

      if (ctrl.programs.isEmpty) {
        return const Center(
          child: Text(
            'EPG data available nahi hai',
            style: TextStyle(color: Colors.white38),
          ),
        );
      }

      return ListView.builder(
        controller: scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: ctrl.programs.length,
        itemBuilder: (_, i) {
          final p = ctrl.programs[i];
          final isFocused = focusedIndex == i;
          final isLive = p.isLive;

          return GestureDetector(
            onTap: () => setState(() => focusedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isFocused
                    ? const Color(0xFF00D4FF).withValues(alpha: 0.12)
                    : isLive
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused
                      ? const Color(0xFF00D4FF)
                      : isLive
                      ? const Color(0xFF00D4FF).withValues(alpha: 0.3)
                      : Colors.white10,
                  width: isFocused ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Time column
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.timeRange,
                          style: TextStyle(
                            color: isFocused
                                ? const Color(0xFF00D4FF)
                                : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isLive) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white12,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),

                  // Program info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: TextStyle(
                            color: isFocused
                                ? const Color(0xFF00D4FF)
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: isLive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (p.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            p.description,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Progress — live program ke liye
                  if (isLive)
                    SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Text(
                            '${(p.progressPercent * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFF00D4FF),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: p.progressPercent,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF00D4FF),
                            ),
                            minHeight: 3,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildDivider(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: Colors.white12)),
        ],
      ),
    );
  }

  // ── Remote navigation ─────────────────────────────────────────────────────
  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() {
        focusedIndex =
            (focusedIndex + 1).clamp(0, ctrl.programs.length - 1);
      });
      _scrollToFocused();
    } else if (key == LogicalKeyboardKey.arrowUp) {
      setState(() {
        focusedIndex = (focusedIndex - 1).clamp(0, ctrl.programs.length - 1);
      });
      _scrollToFocused();
    } else if (key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.escape) {
      Get.back();
    }
  }

  void _scrollToFocused() {
    scrollCtrl.animateTo(
      focusedIndex * 80.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    ctrl.clear();
    super.dispose();
  }
}