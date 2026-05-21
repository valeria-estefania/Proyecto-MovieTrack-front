import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';

class AuthService {
  // Guarda el token en el dispositivo
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Lee el token guardado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Elimina el token al cerrar sesión
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Registro
  static Future<User> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(AppConstants.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error al registrarse');
    }
  }

  // Login
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(AppConstants.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      await saveToken(token);
      return token;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Credenciales incorrectas');
    }
  }

  // Ver perfil
  static Future<User> getMe() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(AppConstants.meUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener perfil');
    }
  }

  // Logout
  static Future<void> logout() async {
    await deleteToken();
  }
}