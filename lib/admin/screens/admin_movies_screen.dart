import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../widgets/admin_sidebar.dart';

class AdminMoviesScreen extends StatefulWidget {
  const AdminMoviesScreen({super.key});

  @override
  State<AdminMoviesScreen> createState() => _AdminMoviesScreenState();
}

class _AdminMoviesScreenState extends State<AdminMoviesScreen> {
  List<Map<String, dynamic>> _content = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _typeFilter = 'all'; // 'all', 'movie', 'tv'
  String _sortBy = 'favoritos'; // 'favoritos', 'rating', 'reviews'

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
      _content = await AdminService.getContent(token);
      _applyFiltersAndSort();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _filter() => _applyFiltersAndSort();

  void _applyFiltersAndSort() {
    final q = _searchCtrl.text.toLowerCase();
    var list = _content.where((c) {
      final matchText = q.isEmpty || '${c['title'] ?? ''}'.toLowerCase().contains(q);
      final matchType = _typeFilter == 'all' || c['type'] == _typeFilter;
      return matchText && matchType;
    }).toList();

    list.sort((a, b) {
      if (_sortBy == 'favoritos') {
        return ((b['total_favoritos'] as int?) ?? 0).compareTo((a['total_favoritos'] as int?) ?? 0);
      } else if (_sortBy == 'rating') {
        final ra = (a['avg_score'] as num?)?.toDouble() ?? -1;
        final rb = (b['avg_score'] as num?)?.toDouble() ?? -1;
        return rb.compareTo(ra);
      } else {
        return ((b['total_reviews'] as int?) ?? 0).compareTo((a['total_reviews'] as int?) ?? 0);
      }
    });

    setState(() { _filtered = list; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      body: Row(
        children: [
          const AdminSidebar(selectedIndex: 3),
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
    final totalMovies = _content.where((c) => c['type'] == 'movie').length;
    final totalSeries = _content.where((c) => c['type'] == 'tv').length;

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
                  const Text('Contenido',
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  Text(
                    '$totalMovies películas · $totalSeries series · ${_content.length} en total',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 24),

          // Filtros y ordenamiento
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar película o serie...',
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
              _FilterChip(
                label: 'Todo',
                selected: _typeFilter == 'all',
                onTap: () { _typeFilter = 'all'; _applyFiltersAndSort(); },
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Películas',
                selected: _typeFilter == 'movie',
                onTap: () { _typeFilter = 'movie'; _applyFiltersAndSort(); },
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Series',
                selected: _typeFilter == 'tv',
                onTap: () { _typeFilter = 'tv'; _applyFiltersAndSort(); },
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.surfaceColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: const Color(AppConstants.surfaceColor),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'favoritos', child: Text('↓ Más favoritos')),
                      DropdownMenuItem(value: 'rating', child: Text('↓ Mejor rating')),
                      DropdownMenuItem(value: 'reviews', child: Text('↓ Más reviews')),
                    ],
                    onChanged: (v) { if (v != null) { _sortBy = v; _applyFiltersAndSort(); } },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Header de tabla
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 56),
                const Expanded(flex: 4, child: Text('Título', style: TextStyle(color: Colors.grey, fontSize: 12))),
                const Expanded(flex: 1, child: Text('Tipo', style: TextStyle(color: Colors.grey, fontSize: 12))),
                const Expanded(flex: 1, child: Text('⭐ Favoritos', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
                const Expanded(flex: 1, child: Text('📝 Reviews', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
                const Expanded(flex: 1, child: Text('🎯 Avg score', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No se encontró contenido', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _ContentRow(content: _filtered[i], rank: i + 1),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(AppConstants.primaryColor).withOpacity(0.2)
              : const Color(AppConstants.surfaceColor),
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: const Color(AppConstants.primaryColor).withOpacity(0.5))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(AppConstants.primaryColor) : Colors.grey,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  final Map<String, dynamic> content;
  final int rank;

  const _ContentRow({required this.content, required this.rank});

  @override
  Widget build(BuildContext context) {
    final posterUrl = content['poster_url'] as String?;
    final title = content['title'] as String? ?? 'Sin título';
    final type = content['type'] as String? ?? '';
    final totalFav = content['total_favoritos'] as int? ?? 0;
    final totalRev = content['total_reviews'] as int? ?? 0;
    final avgScore = content['avg_score'];

    final avgScoreVal = avgScore != null ? (avgScore as num).toDouble() : null;
    final scoreColor = avgScoreVal == null
        ? Colors.grey
        : avgScoreVal >= 7
            ? Colors.green
            : avgScoreVal >= 5
                ? Colors.orange
                : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(AppConstants.surfaceColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          // Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: posterUrl != null
                ? Image.network(
                    posterUrl,
                    width: 36,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          // Título
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Tipo
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: type == 'movie'
                    ? const Color(0xFF4A90D9).withOpacity(0.15)
                    : const Color(0xFF7B68EE).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                type == 'movie' ? 'Película' : 'Serie',
                style: TextStyle(
                  color: type == 'movie' ? const Color(0xFF4A90D9) : const Color(0xFF7B68EE),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Favoritos
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, color: Color(0xFFFF6B6B), size: 14),
                const SizedBox(width: 4),
                Text('$totalFav', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Reviews
          Expanded(
            flex: 1,
            child: Text(
              '$totalRev',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),

          // Avg score
          Expanded(
            flex: 1,
            child: avgScoreVal != null
                ? Text(
                    avgScoreVal.toStringAsFixed(1),
                    style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.center,
                  )
                : const Text('—', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 36,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.movie_outlined, color: Colors.grey, size: 16),
    );
  }
}
