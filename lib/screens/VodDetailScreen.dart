import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vodcontroller.dart';
import 'PlayerScreen.dart';


class VodDetailScreen extends StatelessWidget {
  final VodItem item;
  const VodDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Background blurred poster ──────────────────────────────────
          if (item.posterUrl.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                item.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC0A0A0F),
                    Color(0xEE0A0A0F),
                    Color(0xFF0A0A0F),
                  ],
                  stops: [0.0, 0.4, 0.7],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white70),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    // ── Main layout: poster + info ─────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster
                        _DetailPoster(posterUrl: item.posterUrl),
                        const SizedBox(width: 20),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Meta row
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  if (item.year.isNotEmpty)
                                    _MetaChip(
                                        icon: Icons.calendar_today,
                                        label: item.year),
                                  if (item.duration.isNotEmpty)
                                    _MetaChip(
                                        icon: Icons.timer,
                                        label: item.duration),
                                  if (item.rating != '0' &&
                                      item.rating.isNotEmpty)
                                    _MetaChip(
                                        icon: Icons.star,
                                        label: item.rating,
                                        iconColor: const Color(0xFFFFC107)),
                                  if (item.genre.isNotEmpty)
                                    _MetaChip(
                                        icon: Icons.local_movies,
                                        label: item.genre),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Play button
                              _PlayButton(item: item),
                              const SizedBox(height: 12),

                              // Watchlist button
                              _WatchlistButton(item: item),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Plot ──────────────────────────────────────────
                    if (item.plot.isNotEmpty) ...[
                      const Text(
                        'Story',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ExpandablePlot(plot: item.plot),
                      const SizedBox(height: 28),
                    ],

                    // ── Details table ─────────────────────────────────
                    _DetailsTable(item: item),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Poster ───────────────────────────────────────────────────────────────────

class _DetailPoster extends StatelessWidget {
  final String posterUrl;
  const _DetailPoster({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 130,
        height: 190,
        child: posterUrl.isNotEmpty
            ? Image.network(posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.white10,
              child: const Icon(Icons.movie,
                  color: Colors.white24, size: 48),
            ))
            : Container(
          color: Colors.white10,
          child: const Icon(Icons.movie,
              color: Colors.white24, size: 48),
        ),
      ),
    );
  }
}

// ─── Meta Chip ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  const _MetaChip(
      {required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor ?? Colors.white38, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

// ─── Play Button ──────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  final VodItem item;
  const _PlayButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          elevation: 4,
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 24),
        label: const Text(
          'Play Now',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          if (item.streamUrl.isEmpty) {
            Get.snackbar(
              'Error',
              'Stream URL nahi mili',
              backgroundColor: const Color(0xFFE53935),
              colorText: Colors.white,
            );
            return;
          }
          Get.to(() => PlayerScreen(
            streamUrl: item.streamUrl,
            channelTitle: item.name,
          ));
        },
      ),
    );
  }
}

// ─── Watchlist Button ─────────────────────────────────────────────────────────

class _WatchlistButton extends StatefulWidget {
  final VodItem item;
  const _WatchlistButton({required this.item});

  @override
  State<_WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends State<_WatchlistButton> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(
          _added ? Icons.bookmark : Icons.bookmark_border,
          size: 18,
          color: _added ? const Color(0xFFE53935) : Colors.white54,
        ),
        label: Text(
          _added ? 'Watchlist mein hai' : 'Watchlist mein add karo',
          style: const TextStyle(fontSize: 13),
        ),
        onPressed: () {
          setState(() => _added = !_added);
          Get.snackbar(
            _added ? 'Added!' : 'Removed',
            _added
                ? '${widget.item.name} watchlist mein add ho gaya'
                : '${widget.item.name} watchlist se hata diya',
            backgroundColor:
            _added ? const Color(0xFFE53935) : Colors.white24,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
      ),
    );
  }
}

// ─── Expandable Plot ──────────────────────────────────────────────────────────

class _ExpandablePlot extends StatefulWidget {
  final String plot;
  const _ExpandablePlot({required this.plot});

  @override
  State<_ExpandablePlot> createState() => _ExpandablePlotState();
}

class _ExpandablePlotState extends State<_ExpandablePlot> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.plot,
            maxLines: _expanded ? null : 3,
            overflow:
            _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _expanded ? 'Kam dikhao ▲' : 'Zyada dikhao ▼',
            style: const TextStyle(
                color: Color(0xFFE53935),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Details Table ────────────────────────────────────────────────────────────

class _DetailsTable extends StatelessWidget {
  final VodItem item;
  const _DetailsTable({required this.item});

  @override
  Widget build(BuildContext context) {
    final rows = <Map<String, String>>[
      if (item.genre.isNotEmpty) {'Genre': item.genre},
      if (item.year.isNotEmpty) {'Year': item.year},
      if (item.duration.isNotEmpty) {'Duration': item.duration},
      if (item.rating != '0' && item.rating.isNotEmpty)
        {'Rating': '⭐ ${item.rating} / 10'},
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              final key = row.keys.first;
              final value = row.values.first;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: i < rows.length - 1
                      ? const Border(
                      bottom: BorderSide(color: Colors.white10))
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(key,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(value,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}