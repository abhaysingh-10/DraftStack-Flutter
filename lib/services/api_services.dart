import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServices {
  // Dio Instance
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/',
    ),
  );

  // Storage Instance
  final _storage = const FlutterSecureStorage();

  // login() fun

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'auth/login/',
        data: {
          'username': username,
          'password': password,
        },
      );
      await _storage.write(key: 'access_token', value: response.data['access']);
      await _storage.write(
          key: 'refresh_token', value: response.data['refresh']);

      return true;
    } catch (e) {
      print('login Error: $e');
      return false;
    }
  }

  // register()fun

  Future<bool> register(String username,String email,String password) async{
    try{
      await _dio.post(
        'auth/register/',
        data: {
          'username': username,
          'email':email,
          'password':password,
        },
      );
      return true;
    }
    catch(e){
      print('Register Error: $e');
      return false;
    }
  }
}
