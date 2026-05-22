import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/LiveTvController.dart';
import 'EpgScreen.dart';
import 'PlayerScreen.dart';


class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  final ctrl = Get.put(LiveTvController());

  // Focus: 0=categories, 1=channels
  int focusedSection  = 1;
  int focusedCategory = 0;
  int focusedChannel  = 0;

  bool showSidebar = true;

  final catScrollCtrl = ScrollController();
  final chScrollCtrl  = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
            );
          }

          if (ctrl.errorMsg.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white38, size: 48),
                  const SizedBox(height: 12),
                  Text(ctrl.errorMsg.value,
                      style: const TextStyle(color: Colors.white38)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: ctrl.fetchAll,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              // ── Categories sidebar ───────────────────────────────────────
              if (showSidebar) _buildCategorySidebar(),

              // ── Channel list ─────────────────────────────────────────────
              _buildChannelList(),
            ],
          );
        }),
      ),
    );
  }

  // ── Category sidebar ──────────────────────────────────────────────────────
  Widget _buildCategorySidebar() {
    return Container(
      width: 180,
      color: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.live_tv,
                    color: Color(0xFF00D4FF), size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),

          // Category list
          Expanded(
            child: Obx(() => ListView.builder(
              controller: catScrollCtrl,
              itemCount: ctrl.categories.length,
              itemBuilder: (_, i) {
                final cat = ctrl.categories[i];
                final isSelected = ctrl.selectedCategoryId.value == cat.id;
                final isFocused =
                    focusedSection == 0 && focusedCategory == i;

                return GestureDetector(
                  onTap: () {
                    ctrl.selectCategory(cat.id);
                    setState(() {
                      focusedSection  = 1;
                      focusedChannel  = 0;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isFocused
                          ? const Color(0xFF00D4FF).withValues(alpha: 0.15)
                          : isSelected
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFocused
                            ? const Color(0xFF00D4FF)
                            : isSelected
                            ? Colors.white24
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        color: isFocused
                            ? const Color(0xFF00D4FF)
                            : isSelected
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  // ── Channel list ──────────────────────────────────────────────────────────
  Widget _buildChannelList() {
    return Expanded(
      child: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: const Color(0xFF111111),
            child: Row(
              children: [
                // Back
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Color(0xFF00D4FF), size: 18),
                ),
                const SizedBox(width: 12),
                Obx(() => Text(
                  ctrl.categories.isNotEmpty &&
                      focusedCategory < ctrl.categories.length
                      ? ctrl.categories
                      .firstWhere(
                        (c) =>
                    c.id == ctrl.selectedCategoryId.value,
                    orElse: () =>
                        LiveCategory(id: '', name: 'Live TV'),
                  )
                      .name
                      : 'Live TV',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const Spacer(),
                Obx(() => Text(
                  '${ctrl.filteredChannels.length} channels',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 12),
                )),
              ],
            ),
          ),

          // Channels
          Expanded(
            child: Obx(() {
              if (ctrl.filteredChannels.isEmpty) {
                return const Center(
                  child: Text('No channels',
                      style: TextStyle(color: Colors.white38)),
                );
              }

              return ListView.builder(
                controller: chScrollCtrl,
                padding: const EdgeInsets.all(8),
                itemCount: ctrl.filteredChannels.length,
                itemBuilder: (_, i) {
                  final ch = ctrl.filteredChannels[i];
                  final isFocused =
                      focusedSection == 1 && focusedChannel == i;

                  return GestureDetector(
                    onTap: () => _openChannel(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isFocused
                            ? const Color(0xFF00D4FF).withValues(alpha: 0.12)
                            : const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFocused
                              ? const Color(0xFF00D4FF)
                              : Colors.white10,
                          width: isFocused ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Channel number
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${ch.num}',
                              style: const TextStyle(
                                  color: Colors.white24, fontSize: 12),
                            ),
                          ),

                          // Logo
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ch.logoUrl.isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: ch.logoUrl,
                                fit: BoxFit.contain,
                                errorWidget: (_, __, ___) =>
                                const Icon(Icons.tv,
                                    color: Colors.white24,
                                    size: 22),
                              ),
                            )
                                : const Icon(Icons.tv,
                                color: Colors.white24, size: 22),
                          ),

                          // Name + category
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ch.name,
                                  style: TextStyle(
                                    color: isFocused
                                        ? const Color(0xFF00D4FF)
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (ch.categoryName.isNotEmpty)
                                  Text(
                                    ch.categoryName,
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11),
                                  ),
                              ],
                            ),
                          ),

                          // EPG button
                          if (isFocused)
                            GestureDetector(
                              onTap: () => _openEpg(ch),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF00D4FF)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'EPG',
                                  style: TextStyle(
                                    color: Color(0xFF00D4FF),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(width: 8),

                          // Play icon
                          if (isFocused)
                            const Icon(Icons.play_circle_filled,
                                color: Color(0xFF00D4FF), size: 22),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _openChannel(int index) {
    final ch = ctrl.filteredChannels[index];
    ctrl.selectChannel(index);
    Get.to(() => PlayerScreen(
      streamUrl:    ch.streamUrl,
      channelTitle: ch.name,   // channelName → channelTitle, logoUrl hata do
    ));
  }

  void _openEpg(LiveChannel ch) {
    Get.to(() => EpgScreen(
      streamId:    ch.streamId,
      channelName: ch.name,
    ));
  }

  // ── D-pad remote ──────────────────────────────────────────────────────────
  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    setState(() {
      if (key == LogicalKeyboardKey.arrowUp) {
        if (focusedSection == 0) {
          focusedCategory =
              (focusedCategory - 1).clamp(0, ctrl.categories.length - 1);
          _scrollCat();
        } else {
          focusedChannel =
              (focusedChannel - 1).clamp(0, ctrl.filteredChannels.length - 1);
          _scrollCh();
        }
      } else if (key == LogicalKeyboardKey.arrowDown) {
        if (focusedSection == 0) {
          focusedCategory =
              (focusedCategory + 1).clamp(0, ctrl.categories.length - 1);
          _scrollCat();
        } else {
          focusedChannel =
              (focusedChannel + 1).clamp(0, ctrl.filteredChannels.length - 1);
          _scrollCh();
        }
      } else if (key == LogicalKeyboardKey.arrowRight) {
        if (focusedSection == 0) focusedSection = 1;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        if (focusedSection == 1) focusedSection = 0;
      } else if (key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.enter) {
        if (focusedSection == 0) {
          ctrl.selectCategory(ctrl.categories[focusedCategory].id);
          focusedSection = 1;
          focusedChannel = 0;
        } else {
          _openChannel(focusedChannel);
        }
      } else if (key == LogicalKeyboardKey.goBack ||
          key == LogicalKeyboardKey.escape) {
        Get.back();
      }
    });
  }

  void _scrollCat() {
    catScrollCtrl.animateTo(
      focusedCategory * 48.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _scrollCh() {
    chScrollCtrl.animateTo(
      focusedChannel * 68.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    catScrollCtrl.dispose();
    chScrollCtrl.dispose();
    super.dispose();
  }
}