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

  //Constructor Interceptor
  ApiServices() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Step 1 attach Token
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final response = await _dio.post(
                  'auth/refresh/',
                  data: {'refresh': refreshToken},
                );
                final newToken = response.data['access'];
                await _storage.write(
                  key: 'access_token',
                  value: newToken,
                );
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final retryResponse = await _dio.fetch(error.requestOptions);
                handler.resolve(retryResponse);
              } catch (e) {
                await _storage.deleteAll();
                handler.reject(error);
              }
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

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

  Future<bool> register(String username, String email, String password) async {
    try {
      await _dio.post(
        'auth/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return true;
    } catch (e) {
      print('Register Error: $e');
      return false;
    }
  }
}
