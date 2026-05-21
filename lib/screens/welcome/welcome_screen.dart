import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/content_service.dart';
import '../../models/content.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Content> _contents = [];
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Verifica auth en paralelo con la carga de posters
    final authFuture = _checkAuth();
    final posterFuture = _loadPosters();
    await Future.wait([posterFuture]);
    await authFuture;
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final isAuthenticated = await authProvider.checkAuth();
    if (!mounted) return;
    if (isAuthenticated) {
      await userProvider.loadUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _checking = false);
    }
  }

  Future<void> _loadPosters() async {
    try {
      final contents = await ContentService.getAllContent();
      if (mounted) {
        setState(() => _contents = contents..shuffle(Random()));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_checking && _contents.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE50914)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Stack(
        children: [
          // Grid de posters de fondo
          if (_contents.isNotEmpty)
            Positioned.fill(
              child: _PosterGrid(contents: _contents),
            ),

          // Gradiente oscuro encima
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.95),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Contenido
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Logo
                    const Text(
                      'MOVIETRACK',
                      style: TextStyle(
                        color: Color(0xFFE50914),
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tu app de películas y series',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Botón iniciar sesión
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón registrarse
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white54, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

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

class _PosterGrid extends StatelessWidget {
  final List<Content> contents;

  const _PosterGrid({required this.contents});

  @override
  Widget build(BuildContext context) {
    final posters = contents
        .where((c) => c.posterUrl != null)
        .take(12)
        .toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posters.length,
      itemBuilder: (context, index) {
        return Image.network(
          posters[index].posterUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A2A2A)),
        );
      },
    );
  }
}