import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app/config.dart';

class ApiException implements Exception {
  final String message; final int? statusCode;
  ApiException(this.message,[this.statusCode]);
  @override String toString()=>message;
}
class ParseApi {
 static Future<Map<String,dynamic>> request(String method,String path,{Map<String,dynamic>? data}) async {
  final base=ParseConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'),'');
  final suffix=path.replaceAll(RegExp(r'^/+'),'');
  final uri=Uri.parse('$base/$suffix');
  final prefs=await SharedPreferences.getInstance();final token=prefs.getString('parse_access_token');
  final headers={'Accept':'application/json','Content-Type':'application/json',if(token!=null&&token.isNotEmpty)'Authorization':'Bearer $token'};
  try{
   final response=await http.Request(method,uri)..headers.addAll(headers);
   if(data!=null)response.body=jsonEncode(data);
   final streamed=await response.send().timeout(Duration(seconds:ParseConfig.requestTimeoutSeconds));
   final body=await streamed.stream.bytesToString();
   final decoded=body.isNotEmpty?jsonDecode(body):<String,dynamic>{};
   if(streamed.statusCode<200||streamed.statusCode>=300){
    final message=decoded is Map?(decoded['message']?.toString()??'درخواست ناموفق بود'):'درخواست ناموفق بود';
    throw ApiException(message,streamed.statusCode);
   }
   return decoded is Map<String,dynamic>?decoded:<String,dynamic>{};
  }on ApiException{rethrow;}catch(_){throw ApiException('ارتباط با سرور برقرار نشد. اتصال اینترنت را بررسی کنید.');}
 }
 static Future<Map<String,dynamic>> get(String path)=>request('GET',path);
 static Future<Map<String,dynamic>> post(String path,Map<String,dynamic> data)=>request('POST',path,data:data);
 static Future<void> saveToken(String token)async{final p=await SharedPreferences.getInstance();await p.setString('parse_access_token',token);}
 static Future<void> clearToken()async{final p=await SharedPreferences.getInstance();await p.remove('parse_access_token');}
}
