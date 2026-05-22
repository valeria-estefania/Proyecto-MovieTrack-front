import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/user.dart';

class AdminService {
  // ─── Stats ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getStats(String token) async {
    final res = await http.get(
      Uri.parse('${AppConstants.adminUrl}/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Error al obtener estadísticas');
  }

  // ─── Users ───────────────────────────────────────────────────
  static Future<List<User>> getUsers(String token) async {
    final res = await http.get(
      Uri.parse('${AppConstants.adminUrl}/users'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((u) => User.fromJson(u)).toList();
    }
    throw Exception('Error al obtener usuarios');
  }

  static Future<void> deleteUser(String token, int idUser) async {
    final res = await http.delete(
      Uri.parse('${AppConstants.adminUrl}/users/$idUser'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Error al eliminar usuario');
  }

  static Future<void> changeRole(String token, int idUser, String role) async {
    final res = await http.patch(
      Uri.parse('${AppConstants.adminUrl}/users/$idUser/role?role=$role'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Error al cambiar rol');
  }

  // ─── Reviews ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getReviews(String token) async {
    final res = await http.get(
      Uri.parse('${AppConstants.adminUrl}/reviews'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al obtener reviews');
  }

  static Future<List<Map<String, dynamic>>> getRecentReviews(String token) async {
    final res = await http.get(
      Uri.parse('${AppConstants.adminUrl}/recent-reviews'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al obtener reviews recientes');
  }

  static Future<void> deleteReview(String token, int idReview) async {
    final res = await http.delete(
      Uri.parse('${AppConstants.adminUrl}/reviews/$idReview'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Error al eliminar review');
  }

  // ─── Content ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getContent(String token) async {
    final res = await http.get(
      Uri.parse('${AppConstants.adminUrl}/content'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Error al obtener contenido');
  }
}
