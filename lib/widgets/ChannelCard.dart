import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChannelCard extends StatelessWidget {
  final Map channel;
  final bool isFocused;
  final VoidCallback onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isFocused
              ? const Color(0xFF00D4FF).withOpacity(0.15)
              : const Color(0xFF1A1A1A),
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
            // Channel logo
            Container(
              width: 56,
              height: 56,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: channel['stream_icon'] != null &&
                    channel['stream_icon'].toString().isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: channel['stream_icon'],
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.tv,
                    color: Colors.white24,
                    size: 28,
                  ),
                )
                    : const Icon(
                  Icons.tv,
                  color: Colors.white24,
                  size: 28,
                ),
              ),
            ),

            // Channel name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    channel['name'] ?? 'Unknown',
                    style: TextStyle(
                      color: isFocused ? const Color(0xFF00D4FF) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel['category_name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Play icon
            if (isFocused)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.play_circle_filled,
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}