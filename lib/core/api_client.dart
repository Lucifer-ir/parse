import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../app/config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ParseApi {
  static const Duration _requestTimeout =
      Duration(seconds: ParseConfig.requestTimeoutSeconds);

  static String _errorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map) {
      for (final key in ['message', 'detail', 'error']) {
        final value = decoded[key];

        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }

        if (value is Map) {
          final nested = value['message'] ?? value['detail'];
          if (nested is String && nested.trim().isNotEmpty) {
            return nested.trim();
          }
        }
      }
    }

    return 'درخواست با خطای سرور مواجه شد (HTTP $statusCode).';
  }

  static Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final base =
          ParseConfig.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      if (base.isEmpty) {
        throw ApiException('آدرس اتصال به سرور تنظیم نشده است.');
      }

      final suffix = path.replaceAll(RegExp(r'^/+'), '');
      final uri = Uri.parse('$base/$suffix');
      if (!uri.hasAuthority ||
          (uri.scheme != 'https' && uri.scheme != 'http')) {
        throw ApiException('آدرس سرور معتبر نیست.');
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('parse_access_token');
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Parse-Platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      final request = http.Request(method, uri)..headers.addAll(headers);
      if (data != null) {
        request.body = jsonEncode(data);
      }

      final response = await request.send().timeout(_requestTimeout);
      final body =
          await response.stream.bytesToString().timeout(_requestTimeout);

      dynamic decoded = <String, dynamic>{};
      if (body.trim().isNotEmpty) {
        try {
          decoded = jsonDecode(body);
        } on FormatException {
          throw ApiException(
            'پاسخ سرور قابل‌خواندن نیست (HTTP ${response.statusCode}).',
            response.statusCode,
          );
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(decoded, response.statusCode),
          response.statusCode,
        );
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'پاسخ سرور بیش از حد طول کشید. اتصال اینترنت را بررسی و دوباره تلاش کنید.',
      );
    } catch (_) {
      throw ApiException(
        'ارتباط با سرور Parse برقرار نشد. اتصال اینترنت یا آدرس API را بررسی کنید.',
      );
    }
  }

  static Future<Map<String, dynamic>> get(String path) =>
      request('GET', path);

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) =>
      request('POST', path, data: data);

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parse_access_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parse_access_token');
  }
}
