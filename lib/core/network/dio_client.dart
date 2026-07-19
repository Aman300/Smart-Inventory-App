import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class DioClient {
  final StorageService _storageService;
  late final Dio _dio;

  DioClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Dynamically resolve base URL in case host configuration changes
          final currentHost = _storageService.getHost();
          options.baseUrl = 'http://$currentHost:5001/api';

          final token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Handle unauthorized errors (e.g. token expired)
          if (error.response?.statusCode == 401) {
            _storageService.removeToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Global exception handler helper to format user-friendly messages
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet and try again.';
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          if (data is Map && data.containsKey('message')) {
            return data['message'].toString();
          }
          return 'Server error (${error.response?.statusCode ?? "Unknown"}).';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server. Ensure host IP is correct and server is running.';
        default:
          return 'An unexpected network error occurred.';
      }
    }
    return error.toString();
  }
}
