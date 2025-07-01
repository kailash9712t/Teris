import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RequestOperation {
  static Future<Map<String,String>> getHeader() async {
    String? token = await getTokens("accessToken");
    return {"authorization": "bearer $token", "Content-Type" : "application/json"};
  }

  static Future<String?> getTokens(String tokenType) async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: tokenType);
    if (accessToken != null) {
      return accessToken;
    }
    return null;
  }
}
