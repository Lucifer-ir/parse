import 'dart:convert';
import 'dart:typed_data';
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
  static Uri uri(String path) {
    final base = ParseConfig.apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final suffix = path.replaceFirst(RegExp(r'^/+'), '');
    return Uri.parse('$base/$suffix');
  }

  static Future<Map<String, String>> authHeaders({bool jsonContent = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('parse_access_token');
    return {
      'Accept': 'application/json',
      if (jsonContent) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _decodeJson(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};
    } catch (_) {
      throw ApiException('پاسخ سرور JSON معتبر نیست.', response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? (decoded['message']?.toString() ?? decoded['detail']?.toString() ?? 'درخواست ناموفق بود')
          : 'درخواست ناموفق بود';
      throw ApiException(message, response.statusCode);
    }
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await http.get(uri(path), headers: await authHeaders())
          .timeout(Duration(seconds: ParseConfig.requestTimeoutSeconds));
      return _decodeJson(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('ارتباط با سرور برقرار نشد. اتصال اینترنت را بررسی کنید.');
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        uri(path),
        headers: await authHeaders(jsonContent: true),
        body: jsonEncode(data),
      ).timeout(Duration(seconds: ParseConfig.requestTimeoutSeconds));
      return _decodeJson(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('ارتباط با سرور برقرار نشد. اتصال اینترنت را بررسی کنید.');
    }
  }

  static Future<Uint8List> getBytes(String path) async {
    try {
      final response = await http.get(uri(path), headers: await authHeaders())
          .timeout(const Duration(seconds: 90));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        var message = 'دریافت فایل ناموفق بود.';
        try {
          final payload = jsonDecode(response.body);
          if (payload is Map) {
            message = (payload['message'] ?? payload['detail'] ?? message).toString();
          }
        } catch (_) {}
        throw ApiException(message, response.statusCode);
      }
      return response.bodyBytes;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('دریافت فایل از سرور انجام نشد.');
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parse_access_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parse_access_token');
  }
}
