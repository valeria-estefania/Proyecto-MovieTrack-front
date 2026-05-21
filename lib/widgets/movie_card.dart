import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/content.dart';

class MovieCard extends StatelessWidget {
  final Content content;

  const MovieCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: {
            'contentId': content.idContent,
            'tmdbId': content.tmdbId,
            'type': content.type,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: content.posterUrl != null
                    ? CachedNetworkImage(
                        imageUrl: content.posterUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFF2A2A2A),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFE50914)),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFF2A2A2A),
                          child: const Icon(Icons.movie,
                              color: Colors.grey, size: 48),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF2A2A2A),
                        child: const Icon(Icons.movie,
                            color: Colors.grey, size: 48),
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        content.rating != null
                            ? content.rating!.toStringAsFixed(1)
                            : 'N/A',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}