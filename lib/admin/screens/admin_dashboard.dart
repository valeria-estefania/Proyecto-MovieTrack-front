import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/stat_card.dart';
import 'admin_reviews_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentReviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = context.read<AuthProvider>().token!;
      final results = await Future.wait([
        AdminService.getStats(token),
        AdminService.getRecentReviews(token),
      ]);
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _recentReviews = (results[1] as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 0),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(AppConstants.primaryColor)))
                : _error != null
                    ? _buildError()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStats, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final s = _stats!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Resumen general de la plataforma',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                onPressed: _loadStats,
                icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                tooltip: 'Actualizar',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Stat cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StatCard(
                title: 'Usuarios',
                value: '${s['total_usuarios'] ?? 0}',
                icon: Icons.people_rounded,
                color: const Color(0xFF4A90D9),
              ),
              StatCard(
                title: 'Películas/Series',
                value: '${s['total_contenido'] ?? 0}',
                icon: Icons.movie_rounded,
                color: const Color(0xFF7B68EE),
              ),
              StatCard(
                title: 'Reviews',
                value: '${s['total_reviews'] ?? 0}',
                icon: Icons.rate_review_rounded,
                color: const Color(AppConstants.primaryColor),
              ),
              StatCard(
                title: 'Favoritos',
                value: '${s['total_favoritos'] ?? 0}',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFFF6B6B),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Fila: Watch status + Reviews recientes
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Watch status (izquierda)
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.surfaceColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado del contenido',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _StatusIndicator(
                            label: 'Visto',
                            count: s['contenido_visto'] ?? 0,
                            color: Colors.green,
                            icon: Icons.check_circle_rounded,
                          ),
                          const SizedBox(width: 32),
                          _StatusIndicator(
                            label: 'Pendiente',
                            count: s['contenido_pendiente'] ?? 0,
                            color: Colors.orange,
                            icon: Icons.schedule_rounded,
                          ),
                          const SizedBox(width: 32),
                          _StatusIndicator(
                            label: 'Total estados',
                            count: (s['contenido_visto'] ?? 0) + (s['contenido_pendiente'] ?? 0),
                            color: Colors.blue,
                            icon: Icons.list_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildProgressBar(
                        visto: s['contenido_visto'] ?? 0,
                        pendiente: s['contenido_pendiente'] ?? 0,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Reviews recientes (derecha)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.surfaceColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reviews recientes',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const AdminReviewsScreen(),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(opacity: anim, child: child),
                                transitionDuration: const Duration(milliseconds: 200),
                              ),
                            ),
                            child: const Text('Ver todas →', style: TextStyle(color: Color(AppConstants.primaryColor))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_recentReviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('Sin reviews aún', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      else
                        ...(_recentReviews.map((r) => _RecentReviewItem(review: r))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({required int visto, required int pendiente}) {
    final total = visto + pendiente;
    if (total == 0) return const SizedBox();
    final ratio = visto / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vistos ${(ratio * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text('Pendientes ${((1 - ratio) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.orange.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.green),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatusIndicator({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _RecentReviewItem extends StatelessWidget {
  final Map<String, dynamic> review;

  const _RecentReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final score = review['score'] as int? ?? 0;
    final scoreColor = score >= 7
        ? Colors.green
        : score >= 5
            ? Colors.orange
            : Colors.red;

    final userName = review['user']?['name'] as String? ?? 'Usuario';
    final contentTitle = review['content']?['title'] as String? ?? 'Contenido desconocido';
    final comment = review['comment'] as String? ?? '';
    final date = review['date'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contentTitle,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'por $userName',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    comment,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
