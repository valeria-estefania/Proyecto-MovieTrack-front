import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';

/// Collage de fondo con posters trending de TMDB.
/// Se usa en Welcome, Login y Register.
class TmdbCollageBackground extends StatefulWidget {
  final Widget child;

  const TmdbCollageBackground({super.key, required this.child});

  @override
  State<TmdbCollageBackground> createState() => _TmdbCollageBackgroundState();
}

class _TmdbCollageBackgroundState extends State<TmdbCollageBackground> {
  List<String> _posterUrls = [];

  // Fallback por si la API tarda o falla
  static const _fallback = [
    'https://image.tmdb.org/t/p/w300/9cqNxx0GxF0bflZmeSMuL5tnchi.jpg',
    'https://image.tmdb.org/t/p/w300/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
    'https://image.tmdb.org/t/p/w300/5KCVkau1HEl7ZzSPeg2XZME5Cx9.jpg',
    'https://image.tmdb.org/t/p/w300/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
    'https://image.tmdb.org/t/p/w300/rktDFPbfHfUbArZ6OOOKsXcv0Bm.jpg',
    'https://image.tmdb.org/t/p/w300/bcCBq9N1EMo3daNIjWJ8kYvrQm6.jpg',
    'https://image.tmdb.org/t/p/w300/velWPhVMQeQKcxggNEU8YmIo52R.jpg',
    'https://image.tmdb.org/t/p/w300/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
    'https://image.tmdb.org/t/p/w300/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _posterUrls = _fallback;
    _fetchTrending();
  }

  Future<void> _fetchTrending() async {
    try {
      // Usamos el backend para no exponer la API key en el cliente
      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/content/search/movie?query=popular'),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final urls = data
            .where((item) => item['poster_url'] != null)
            .map<String>((item) => item['poster_url'] as String)
            .take(9)
            .toList();

        if (urls.length >= 6 && mounted) {
          setState(() => _posterUrls = urls);
        }
      }
    } catch (_) {
      // Mantiene el fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Collage ──────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenH * 0.52,
          child: Stack(
            children: [
              GridView.builder(
                padding: const EdgeInsets.all(6),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posterUrls.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _posterUrls[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF420D4B)),
                  ),
                ),
              ),

              // Gradiente inferior sobre el collage
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 160,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xFF210635),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Fondo sólido debajo del collage ──────────────────
        Positioned(
          top: screenH * 0.44,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(color: const Color(0xFF210635)),
        ),

        // ── Contenido encima ─────────────────────────────────
        widget.child,
      ],
    );
  }
}