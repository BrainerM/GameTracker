import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Wajib ada ini
import '../models/user_game.dart';

class ApiService {
  // --- KONFIGURASI URL ---
  // Sesuaikan 10.0.2.2 jika pakai Emulator Android, atau IP Laptop jika HP Fisik
  static const String baseUrl = 'http://10.0.2.2:8091/api';
  static const String rawgBaseUrl = 'https://api.rawg.io/api';

  // --- KEAMANAN API KEY ---
  // Mengambil value dari file .env (Key: RAWG_API_KEY)
  static String get rawgApiKey => dotenv.env['RAWG_API_KEY'] ?? '';

  // --- AUTHENTICATION (BACKEND GO) ---
  static Future<bool> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Register: $e");
      return false;
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Simpan JWT Token ke memori lokal HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return token;
      }
      return null;
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // --- RAWG API FETCHING (GAMES EXPLORE & SEARCH) ---
  static Future<List<dynamic>> fetchGamesByUrl(String url) async {
    try {
      // Kita tambahkan API Key secara otomatis ke URL jika belum ada
      String finalUrl = url.contains('key=') ? url : '$url&key=$rawgApiKey';

      final response = await http.get(Uri.parse(finalUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'];
      }
      return [];
    } catch (e) {
      print("Error Fetch Games: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchGameDetails(int gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$rawgBaseUrl/games/$gameId?key=$rawgApiKey'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error Fetch Details: $e");
      return null;
    }
  }

  // --- TRACKER LOGIC (DATABASE MYSQL VIA GO) ---
  static Future<bool> addGameToTracker(int gameId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/tracker/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'game_id': gameId, 'status': status}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Add Tracker: $e");
      return false;
    }
  }

  static Future<List<UserGame>> fetchMyTrackedGames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/tracker/mygames'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => UserGame.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      print("Error Fetch My Games: $e");
      return [];
    }
  }

  static Future<bool> updateStatus(int id, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/tracker/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update Status: $e");
      return false;
    }
  }

  static Future<bool> deleteGame(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/tracker/delete/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete Game: $e");
      return false;
    }
  }
}
