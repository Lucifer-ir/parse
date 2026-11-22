import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app/config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override String toString() => message;
}

class ParseApi {
  static Future<Map<String,dynamic>> post(String path, Map<String,dynamic> data) async {
    final uri = Uri.parse('${ParseConfig.apiBaseUrl}/${path.replaceFirst(RegExp(r'^/'), '')}');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('parse_access_token');
    try {
      final response = await http.post(uri,
        headers: {'Accept':'application/json','Content-Type':'application/json', if(token!=null) 'Authorization':'Bearer $token'},
        body: jsonEncode(data)).timeout(Duration(seconds:ParseConfig.requestTimeoutSeconds));
      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : <String,dynamic>{};
      if(response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map ? (decoded['message']?.toString() ?? 'درخواست ناموفق بود') : 'درخواست ناموفق بود';
        throw ApiException(message,response.statusCode);
      }
      return decoded is Map<String,dynamic> ? decoded : <String,dynamic>{};
    } on ApiException { rethrow; }
      catch(e) { throw ApiException('ارتباط با سرور برقرار نشد. اتصال اینترنت را بررسی کنید.'); }
  }
  static Future<void> saveToken(String token) async {
    final prefs=await SharedPreferences.getInstance(); await prefs.setString('parse_access_token',token);
  }
  static Future<void> clearToken() async {
    final prefs=await SharedPreferences.getInstance(); await prefs.remove('parse_access_token');
  }
}
