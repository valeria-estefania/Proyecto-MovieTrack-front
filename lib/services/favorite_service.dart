import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/favorite.dart';
import 'auth_service.dart';

class FavoriteService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Ver favoritos
  static Future<List<Favorite>> getFavorites() async {
    final response = await http.get(
      Uri.parse(AppConstants.favoritesUrl),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Favorite.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener favoritos');
    }
  }

  // Agregar favorito
  static Future<void> addFavorite(int idContent) async {
    final response = await http.post(
      Uri.parse('${AppConstants.favoritesUrl}/'),
      headers: await _headers(),
      body: jsonEncode({'id_content': idContent}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error al agregar favorito');
    }
  }

  // Eliminar favorito
  static Future<void> deleteFavorite(int idFavorite) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.favoritesUrl}/$idFavorite'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar favorito');
    }
  }
}