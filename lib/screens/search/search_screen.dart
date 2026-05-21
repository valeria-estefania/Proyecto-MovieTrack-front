import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<ContentProvider>().search(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = context.watch<ContentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      context.read<ContentProvider>().setSearchType('movie'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: contentProvider.searchType == 'movie'
                          ? const Color(0xFFE50914)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Películas',
                        style:
                            TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<ContentProvider>().setSearchType('tv'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: contentProvider.searchType == 'tv'
                          ? const Color(0xFFE50914)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Series',
                        style:
                            TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: _onSearch,
              autofocus: true,
              decoration: InputDecoration(
                hintText: contentProvider.searchType == 'movie'
                    ? 'Buscar películas...'
                    : 'Buscar series...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ContentProvider>().clearResults();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: contentProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFE50914)))
                : contentProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                color: Colors.grey, size: 64),
                            const SizedBox(height: 16),
                            Text(contentProvider.error!,
                                style:
                                    const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : contentProvider.searchResults.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search,
                                    color: Colors.grey, size: 64),
                                SizedBox(height: 16),
                                Text('Escribe algo para buscar',
                                    style:
                                        TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount:
                                contentProvider.searchResults.length,
                            itemBuilder: (context, index) {
                              final content =
                                  contentProvider.searchResults[index];
                              return MovieCard(content: content);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}