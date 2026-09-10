import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_notification.dart';
import '../models/tracked_vehicle.dart';
import '../models/vehicle_match.dart';
import '../models/vehicle_search.dart';
import '../models/vehicle_tracking.dart';

class ApiClient {
  // AWS'teki Docker Compose backend'ine işaret ediyor (infra/backend-stack.yaml
  // ile CfnLauncher üzerinden deploy edildi) — API portu 5202. Local
  // geliştirmeye dönmek istersen 'http://localhost:5202' yap.
  static const String baseUrl = 'http://13.60.174.208:5202';

  Future<int> registerUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/User'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 409) {
      throw Exception('Bu e-posta zaten kayıtlı.');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Kayıt oluşturulamadı: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['id'] as int;
  }

  Future<int> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/User/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 401) {
      throw Exception('E-posta veya şifre hatalı.');
    }

    if (response.statusCode != 200) {
      throw Exception('Giriş yapılamadı: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['id'] as int;
  }

  Future<VehicleSearch> createVehicleSearch({
    required int userId,
    required String brand,
    required String model,
    required int minYear,
    required int maxYear,
    int? maxMileage,
    double? maxPrice,
    String? fuelType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/VehicleSearch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'brand': brand,
        'model': model,
        'minYear': minYear,
        'maxYear': maxYear,
        'maxMileage': maxMileage,
        'maxPrice': maxPrice,
        'fuelType': fuelType,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Arama oluşturulamadı: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return VehicleSearch.fromJson(json);
  }

  Future<List<VehicleMatch>> getMatches(int searchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/VehicleMatch/search/$searchId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Eşleşmeler alınamadı: ${response.statusCode} ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => VehicleMatch.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<TrackedVehicle>> getTrackedVehicles(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/VehicleTracking/user/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Takip edilenler alınamadı: ${response.statusCode} ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => TrackedVehicle.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<VehicleTracking> getTracking(int searchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/VehicleTracking/$searchId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Takip durumu alınamadı: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return VehicleTracking.fromJson(json);
  }

  Future<VehicleTracking> setTracking(int searchId, bool isActive) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/VehicleTracking/$searchId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isActive': isActive}),
    );

    if (response.statusCode != 200) {
      throw Exception('Takip durumu güncellenemedi: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return VehicleTracking.fromJson(json);
  }

  Future<List<AppNotification>> getNotifications(int searchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Notification/search/$searchId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Bildirimler alınamadı: ${response.statusCode} ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}


