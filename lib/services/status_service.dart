import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/display_status.dart';
import 'auth_service.dart';

class StatusService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Ver mis estados
  static Future<List<DisplayStatus>> getMyStatus() async {
    final response = await http.get(
      Uri.parse(AppConstants.statusUrl),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => DisplayStatus.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener estados');
    }
  }

  // Agregar o actualizar estado
  static Future<void> setStatus(int idContent, String status) async {
    final response = await http.post(
      Uri.parse('${AppConstants.statusUrl}/'),
      headers: await _headers(),
      body: jsonEncode({
        'id_content': idContent,
        'status': status,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error al actualizar estado');
    }
  }

  // Eliminar estado
  static Future<void> deleteStatus(int idStatus) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.statusUrl}/$idStatus'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar estado');
    }
  }
}