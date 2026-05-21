import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieCard extends StatelessWidget {
  final Map movie;
  final bool isFocused;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFocused ? const Color(0xFF00D4FF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: movie['stream_icon'] != null &&
                  movie['stream_icon'].toString().isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: movie['stream_icon'],
                width: 130,
                height: 180,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 130,
                  height: 180,
                  color: const Color(0xFF1A1A1A),
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white24,
                    size: 40,
                  ),
                ),
              )
                  : Container(
                width: 130,
                height: 180,
                color: const Color(0xFF1A1A1A),
                child: const Icon(
                  Icons.movie,
                  color: Colors.white24,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Movie name
            Text(
              movie['name'] ?? '',
              style: TextStyle(
                color: isFocused ? const Color(0xFF00D4FF) : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}