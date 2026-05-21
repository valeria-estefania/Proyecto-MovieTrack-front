import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../models/display_status.dart';
import '../models/review.dart';
import '../services/favorite_service.dart';
import '../services/status_service.dart';
import '../services/review_service.dart';

class UserProvider extends ChangeNotifier {
  List<Favorite> _favorites = [];
  List<DisplayStatus> _statuses = [];
  List<Review> _myReviews = [];
  bool _isLoading = false;

  List<Favorite> get favorites => _favorites;
  List<DisplayStatus> get statuses => _statuses;
  List<Review> get myReviews => _myReviews;
  bool get isLoading => _isLoading;

  // Verifica si un contenido es favorito
  bool isFavorite(int idContent) {
    return _favorites.any((f) => f.idContent == idContent);
  }

  // Obtiene el id del favorito por idContent
  int? getFavoriteId(int idContent) {
    try {
      return _favorites.firstWhere((f) => f.idContent == idContent).idFavorite;
    } catch (e) {
      return null;
    }
  }

  // Obtiene el estado de un contenido
  String? getStatus(int idContent) {
    try {
      return _statuses.firstWhere((s) => s.idContent == idContent).status;
    } catch (e) {
      return null;
    }
  }

  // Obtiene el id del estado por idContent
  int? getStatusId(int idContent) {
    try {
      return _statuses.firstWhere((s) => s.idContent == idContent).idStatus;
    } catch (e) {
      return null;
    }
  }

  // Carga todos los datos del usuario
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await FavoriteService.getFavorites();
      _statuses = await StatusService.getMyStatus();
      _myReviews = await ReviewService.getMyReviews();
    } catch (e) {
      print('Error cargando datos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Favoritos
  Future<void> toggleFavorite(int idContent) async {
    if (isFavorite(idContent)) {
      final id = getFavoriteId(idContent);
      if (id != null) {
        await FavoriteService.deleteFavorite(id);
        _favorites.removeWhere((f) => f.idContent == idContent);
      }
    } else {
      await FavoriteService.addFavorite(idContent);
      _favorites = await FavoriteService.getFavorites();
    }
    notifyListeners();
  }

  // Estados
  Future<void> setStatus(int idContent, String status) async {
    await StatusService.setStatus(idContent, status);
    _statuses = await StatusService.getMyStatus();
    notifyListeners();
  }

  Future<void> deleteStatus(int idContent) async {
    final id = getStatusId(idContent);
    if (id != null) {
      await StatusService.deleteStatus(id);
      _statuses.removeWhere((s) => s.idContent == idContent);
      notifyListeners();
    }
  }

  // Reseñas
  Future<void> createReview(int idContent, int score, String? comment) async {
    await ReviewService.createReview(idContent, score, comment);
    _myReviews = await ReviewService.getMyReviews();
    notifyListeners();
  }

  Future<void> updateReview(int idReview, int score, String? comment) async {
    await ReviewService.updateReview(idReview, score, comment);
    _myReviews = await ReviewService.getMyReviews();
    notifyListeners();
  }

  Future<void> deleteReview(int idReview) async {
    await ReviewService.deleteReview(idReview);
    _myReviews.removeWhere((r) => r.idReview == idReview);
    notifyListeners();
  }

  void clear() {
    _favorites = [];
    _statuses = [];
    _myReviews = [];
    notifyListeners();
  }
}