import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiServices {
  // Storage Instance
  final _storage = const FlutterSecureStorage();

  //helper function for token checking

  Future<bool> hasToken() async {
    String? token = await _storage.read(key: 'access_token');
    
    return token != null;
  }

  // Dio Instance
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/',
    ),
  );

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

//get Notes
  Future<Map<String, dynamic>?> getNotes({int page = 1}) async {
    try {
      final response = await _dio.get(
        'notes/',
        queryParameters: {'page': page},
      );
      return response.data;
    } catch (e) {
      print('getNotes Error: $e');
      return null;
    }
  }

  //Create New Note
  Future<bool> createNote(
      String title, String content, List<Map<String, dynamic>> subtasks) async {
    try {
      final response = await _dio.post(
        'notes/',
        data: {
          'title': title,
          'content': content,
          'subtasks': subtasks,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      print('createNote Error: $e');
      return false;
    }
  }

  //Update Notes
  Future<bool> updateNote(int id, String title, String content,
      List<Map<String, dynamic>> subtasks) async {
    try {
      final response = await _dio.put(
        'notes/$id/',
        data: {
          'title': title,
          'content': content,
          'subtasks': subtasks,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("updatedNote Error: $e");
      return false;
    }
  }

  // Toggle Subtask Completion

  Future<bool> toggleSubtask(
      int noteId, List<Map<String, dynamic>> allSubtasks) async {
    try {
      final response = await _dio.patch(
        'notes/$noteId/',
        data: {
          'subtasks': allSubtasks,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('toggleSubtask Error: $e');
      return false;
    }
  }

  //Delete Note

  Future<bool> deleteNote(int id) async {
    try {
      final response = await _dio.delete('notes/$id/');
      return response.statusCode == 204; //204 No Content
    } catch (e) {
      print("deleted: Note Error: $e ");
      return false;
    }
  }
}
