import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value is Map) {
          final nested = value['message'] ?? value['detail'];
          if (nested is String && nested.trim().isNotEmpty) return nested.trim();
        }
      }
    }
    return 'درخواست با خطای سرور مواجه شد (HTTP $statusCode).';
  }

  static Uri uri(String path) {
    final base = ParseConfig.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (base.isEmpty) throw ApiException('آدرس اتصال به سرور تنظیم نشده است.');
    final suffix = path.replaceAll(RegExp(r'^/+'), '');
    final result = Uri.parse('$base/$suffix');
    if (!result.hasAuthority ||
        (result.scheme != 'https' && result.scheme != 'http')) {
      throw ApiException('آدرس سرور معتبر نیست.');
    }
    return result;
  }

  static Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('parse_access_token');
    return <String, String>{
      'X-Parse-Platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final requestUri = uri(path);
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...await authHeaders(),
      };
      final request = http.Request(method, requestUri)..headers.addAll(headers);
      if (data != null) request.body = jsonEncode(data);
      final response = await request.send().timeout(_requestTimeout);
      final body = await response.stream.bytesToString().timeout(_requestTimeout);
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
        throw ApiException(_errorMessage(decoded, response.statusCode), response.statusCode);
      }
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('پاسخ سرور بیش از حد طول کشید. اتصال اینترنت را بررسی و دوباره تلاش کنید.');
    } catch (_) {
      throw ApiException('ارتباط با سرور Parse برقرار نشد. اتصال اینترنت یا آدرس API را بررسی کنید.');
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String path, {
    required Uint8List bytes,
    required String filename,
    String fieldName = 'audio',
  }) async {
    if (bytes.isEmpty) throw ApiException('فایل صوتی خالی است.');
    if (bytes.length > 15 * 1024 * 1024) {
      throw ApiException('حجم فایل صوتی نباید بیشتر از ۱۵ مگابایت باشد.');
    }
    try {
      final request = http.MultipartRequest('POST', uri(path));
      request.headers.addAll(await authHeaders());
      request.headers['Accept'] = 'application/json';
      request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: filename));
      final streamed = await request.send().timeout(_requestTimeout);
      final body = await streamed.stream.bytesToString().timeout(_requestTimeout);
      dynamic decoded = <String, dynamic>{};
      if (body.trim().isNotEmpty) {
        try { decoded = jsonDecode(body); }
        on FormatException {
          throw ApiException('پاسخ سرور قابل‌خواندن نیست (HTTP ${streamed.statusCode}).', streamed.statusCode);
        }
      }
      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw ApiException(_errorMessage(decoded, streamed.statusCode), streamed.statusCode);
      }
      return decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('زمان بارگذاری فایل صوتی تمام شد. دوباره تلاش کنید.');
    } catch (_) {
      throw ApiException('بارگذاری فایل صوتی به سرور انجام نشد.');
    }
  }

  static Future<Map<String, dynamic>> get(String path) => request('GET', path);
  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) =>
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
