// refresh_token_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';

class RefreshTokenResponse {
  final String access;

  RefreshTokenResponse({required this.access});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      access: json['access'],
    );
  }
}

class RefreshTokenService {
  static const String baseUrl =
      'https://api.iqmath.uz/api/v1/auth/token/refresh/';

  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = sl<LocalSource>().getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Refresh token topilmadi');
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'refresh': refreshToken,
        }),
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tokenResponse = RefreshTokenResponse.fromJson(data);

        // Yangi access token'ni saqlash
        sl<LocalSource>().setAccessToken('Bearer ${tokenResponse.access}');

        debugPrint('✅ Access token yangilandi');
        return tokenResponse.access;
      } else {
        debugPrint('❌ Token yangilashda xatolik: ${response.statusCode}');
        throw Exception('Token yangilashda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Refresh token xatolik: $e');
      throw Exception('Refresh token xatolik: $e');
    }
  }

  // Refresh token mavjudligini tekshirish
  bool hasRefreshToken() {
    final refreshToken = sl<LocalSource>().getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }
}
