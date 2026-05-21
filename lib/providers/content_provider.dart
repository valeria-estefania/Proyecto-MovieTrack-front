import 'package:flutter/material.dart';
import '../models/content.dart';
import '../services/content_service.dart';

class ContentProvider extends ChangeNotifier {
  List<Content> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _searchType = 'movie';

  List<Content> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchType => _searchType;

  void setSearchType(String type) {
    _searchType = type;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_searchType == 'movie') {
        _searchResults = await ContentService.searchMovies(query);
      } else {
        _searchResults = await ContentService.searchTv(query);
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filter({String? type, String? genre, String? platform}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await ContentService.filterContent(
        type: type,
        genre: genre,
        platform: platform,
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }
}