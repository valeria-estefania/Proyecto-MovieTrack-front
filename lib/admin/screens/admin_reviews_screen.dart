import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  int? _scoreFilter;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = context.read<AuthProvider>().token!;
      _reviews = await AdminService.getReviews(token);
      _filtered = List.from(_reviews);
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _reviews.where((r) {
        final comment = '${r['comment'] ?? ''}'.toLowerCase();
        final userName = '${r['user']?['name'] ?? ''}'.toLowerCase();
        final contentTitle = '${r['content']?['title'] ?? ''}'.toLowerCase();
        final matchText = q.isEmpty ||
            comment.contains(q) ||
            userName.contains(q) ||
            contentTitle.contains(q);
        final matchScore = _scoreFilter == null || r['score'] == _scoreFilter;
        return matchText && matchScore;
      }).toList();
    });
  }

  void _setScoreFilter(int? score) {
    _scoreFilter = score;
    _filter();
  }

  Future<void> _deleteReview(Map<String, dynamic> review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppConstants.surfaceColor),
        title: const Text('Eliminar review', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar la reseña de ${review['user']?['name'] ?? 'usuario'} sobre "${review['content']?['title'] ?? 'contenido'}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(AppConstants.primaryColor)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;
    try {
      final token = context.read<AuthProvider>().token!;
      await AdminService.deleteReview(token, review['id_review']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review eliminada'), backgroundColor: Colors.green),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 2),
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
          ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    double avgScore = 0;
    if (_reviews.isNotEmpty) {
      avgScore = _reviews.fold<int>(0, (s, r) => s + (r['score'] as int? ?? 0)) / _reviews.length;
    }

    return Padding(
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
                  const Text('Reviews',
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  Text(
                    '${_reviews.length} reviews · Promedio: ${avgScore.toStringAsFixed(1)}/10',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 24),

          // Filtros
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por película, usuario o comentario...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(AppConstants.surfaceColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.surfaceColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: _scoreFilter,
                    dropdownColor: const Color(AppConstants.surfaceColor),
                    hint: const Text('Score', style: TextStyle(color: Colors.grey)),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...List.generate(10, (i) => i + 1).map(
                        (s) => DropdownMenuItem(value: s, child: Text('$s / 10')),
                      ),
                    ],
                    onChanged: _setScoreFilter,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Lista de reviews
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No se encontraron reviews', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ReviewCard(
                      review: _filtered[i],
                      onDelete: () => _deleteReview(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onDelete;

  const _ReviewCard({required this.review, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final score = review['score'] as int? ?? 0;
    final scoreColor = score >= 7
        ? Colors.green
        : score >= 5
            ? Colors.orange
            : Colors.red;

    final userName = review['user']?['name'] as String? ?? 'Usuario desconocido';
    final userEmail = review['user']?['email'] as String? ?? '';
    final contentTitle = review['content']?['title'] as String? ?? 'Contenido #${review['id_content']}';
    final contentType = review['content']?['type'] as String? ?? '';
    final posterUrl = review['content']?['poster_url'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.surfaceColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster miniatura
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterUrl != null
                ? Image.network(
                    posterUrl,
                    width: 44,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _posterPlaceholder(),
                  )
                : _posterPlaceholder(),
          ),

          const SizedBox(width: 14),

          // Score badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Película/serie
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contentTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (contentType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: contentType == 'movie'
                              ? const Color(0xFF4A90D9).withOpacity(0.2)
                              : const Color(0xFF7B68EE).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          contentType == 'movie' ? 'Película' : 'Serie',
                          style: TextStyle(
                            color: contentType == 'movie'
                                ? const Color(0xFF4A90D9)
                                : const Color(0xFF7B68EE),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Usuario
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.grey, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      userName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· $userEmail',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      '${review['date'] ?? ''}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Comentario
                Text(
                  review['comment'] ?? '(sin comentario)',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                // Stars
                const SizedBox(height: 8),
                Row(
                  children: List.generate(10, (i) => Icon(
                    i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: scoreColor,
                    size: 13,
                  )),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Botón eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            onPressed: onDelete,
            tooltip: 'Eliminar review',
          ),
        ],
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 44,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.movie_outlined, color: Colors.grey, size: 20),
    );
  }
}
