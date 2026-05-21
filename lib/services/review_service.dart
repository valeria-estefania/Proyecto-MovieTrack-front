import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/review.dart';
import 'auth_service.dart';

class ReviewService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mis reseñas
  static Future<List<Review>> getMyReviews() async {
    final response = await http.get(
      Uri.parse('${AppConstants.reviewsUrl}/my'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener reseñas');
    }
  }

  // Reseñas de un contenido
  static Future<List<Review>> getReviewsByContent(int idContent) async {
    final response = await http.get(
      Uri.parse('${AppConstants.reviewsUrl}/content/$idContent'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Review.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  // Crear reseña
  static Future<void> createReview(
      int idContent, int score, String? comment) async {
    final response = await http.post(
      Uri.parse('${AppConstants.reviewsUrl}/'),
      headers: await _headers(),
      body: jsonEncode({
        'id_content': idContent,
        'score': score,
        'comment': comment,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error al crear reseña');
    }
  }

  // Editar reseña
  static Future<void> updateReview(
      int idReview, int score, String? comment) async {
    final response = await http.patch(
      Uri.parse('${AppConstants.reviewsUrl}/$idReview'),
      headers: await _headers(),
      body: jsonEncode({
        'score': score,
        'comment': comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar reseña');
    }
  }

  // Eliminar reseña
  static Future<void> deleteReview(int idReview) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.reviewsUrl}/$idReview'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar reseña');
    }
  }
}