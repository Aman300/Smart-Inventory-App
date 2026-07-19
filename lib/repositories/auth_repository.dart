import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  // Login
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Register
  Future<UserModel> register(
    String name,
    String email,
    String password, {
    String? profileImagePath,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'name': name,
        'email': email,
        'password': password,
      };

      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        final extension = profileImagePath.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'png' : 'jpeg';
        
        dataMap['profileImage'] = await MultipartFile.fromFile(
          profileImagePath,
          filename: profileImagePath.split('/').last,
          contentType: MediaType('image', mimeType),
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: formData,
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Get Profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profile);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Update Profile
  Future<UserModel> updateProfile(
    String name, {
    String? profileImagePath,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'name': name,
      };

      if (password != null && password.isNotEmpty) {
        dataMap['password'] = password;
      }

      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        final extension = profileImagePath.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'png' : 'jpeg';

        dataMap['profileImage'] = await MultipartFile.fromFile(
          profileImagePath,
          filename: profileImagePath.split('/').last,
          contentType: MediaType('image', mimeType),
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dioClient.dio.put(
        ApiConstants.profile,
        data: formData,
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
