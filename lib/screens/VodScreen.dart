import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/vodcontroller.dart';
import 'VodDetailScreen.dart';

class VodScreen extends StatefulWidget {
  final bool isSeries;
  const VodScreen({super.key, this.isSeries = false});

  @override
  State<VodScreen> createState() => _VodScreenState();
}

class _VodScreenState extends State<VodScreen> {
  late final VodController _ctrl;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(VodController());
    if (widget.isSeries) _ctrl.toggleSeriesMode(true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    Get.delete<VodController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(ctrl: _ctrl, isSeries: widget.isSeries),
            _SearchBar(
              controller: _searchCtrl,
              onChanged: _ctrl.onSearch,
            ),
            _CategoryRow(ctrl: _ctrl),
            const SizedBox(height: 8),
            Expanded(child: _PosterGrid(ctrl: _ctrl, scrollCtrl: _scrollCtrl)),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VodController ctrl;
  final bool isSeries;
  const _TopBar({required this.ctrl, required this.isSeries});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white70, size: 20),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Text(
            isSeries ? 'Series' : 'Movies',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Movies / Series toggle
          _ToggleChip(
            label: 'Movies',
            selected: !isSeries,
            onTap: () => Get.off(() => const VodScreen(isSeries: false)),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: 'Series',
            selected: isSeries,
            onTap: () => Get.off(() => const VodScreen(isSeries: true)),
          ),
          const SizedBox(width: 8),
          // Refresh
          Obx(() => IconButton(
            icon: ctrl.isLoading.value
                ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white54, strokeWidth: 2))
                : const Icon(Icons.refresh, color: Colors.white54),
            onPressed: ctrl.refresh,
          )),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE53935) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search movies, series...',
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: const Icon(Icons.search, color: Colors.white30),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white30),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final VodController ctrl;
  const _CategoryRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Obx(() => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ctrl.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = ctrl.categories[i];
          final selected = ctrl.selectedCategory.value == cat.id;
          return GestureDetector(
            onTap: () => ctrl.selectCategory(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE53935)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFE53935)
                      : Colors.white12,
                ),
              ),
              child: Text(
                cat.name,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}

// ─── Poster Grid ──────────────────────────────────────────────────────────────

class _PosterGrid extends StatelessWidget {
  final VodController ctrl;
  final ScrollController scrollCtrl;
  const _PosterGrid({required this.ctrl, required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        );
      }
      if (ctrl.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFE53935), size: 48),
              const SizedBox(height: 12),
              Text(ctrl.errorMessage.value,
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935)),
                onPressed: ctrl.refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      if (ctrl.filteredItems.isEmpty) {
        return const Center(
          child: Text('Koi content nahi mila',
              style: TextStyle(color: Colors.white38)),
        );
      }

      return GridView.builder(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: ctrl.filteredItems.length,
        itemBuilder: (_, i) => _PosterCard(item: ctrl.filteredItems[i]),
      );
    });
  }
}

// ─── Poster Card ──────────────────────────────────────────────────────────────

class _PosterCard extends StatefulWidget {
  final VodItem item;
  const _PosterCard({required this.item});

  @override
  State<_PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<_PosterCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: GestureDetector(
        onTap: () => Get.to(() => VodDetailScreen(item: widget.item)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _focused
                  ? const Color(0xFFE53935)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: _focused
                ? [
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Poster image
                widget.item.posterUrl.isNotEmpty
                    ? Image.network(
                  widget.item.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _PlaceholderPoster(
                      name: widget.item.name),
                )
                    : _PlaceholderPoster(name: widget.item.name),

                // Bottom gradient + title
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Text(
                      widget.item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Rating badge
                if (widget.item.rating != '0' &&
                    widget.item.rating.isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFFFC107), size: 10),
                          const SizedBox(width: 2),
                          Text(
                            widget.item.rating,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPoster extends StatelessWidget {
  final String name;
  const _PlaceholderPoster({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie, color: Colors.white24, size: 36),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}