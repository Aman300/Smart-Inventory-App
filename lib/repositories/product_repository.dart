import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DioClient _dioClient;

  ProductRepository(this._dioClient);

  // Get Products
  Future<List<ProductModel>> getProducts({String? search, String? category}) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParameters['category'] = category;
      }

      final response = await _dioClient.dio.get(
        ApiConstants.products,
        queryParameters: queryParameters,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Get Product by ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.productDetail(id));
      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Create Product
  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required int quantity,
    required String category,
    String? imagePath,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'title': title,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category': category,
      };

      if (imagePath != null && imagePath.isNotEmpty) {
        final extension = imagePath.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'png' : 'jpeg';

        dataMap['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
          contentType: MediaType('image', mimeType),
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dioClient.dio.post(
        ApiConstants.products,
        data: formData,
      );

      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Update Product
  Future<ProductModel> updateProduct(
    String id, {
    String? title,
    String? description,
    double? price,
    int? quantity,
    String? category,
    String? imagePath,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {};
      if (title != null) dataMap['title'] = title;
      if (description != null) dataMap['description'] = description;
      if (price != null) dataMap['price'] = price;
      if (quantity != null) dataMap['quantity'] = quantity;
      if (category != null) dataMap['category'] = category;

      if (imagePath != null && imagePath.isNotEmpty) {
        final extension = imagePath.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'png' : 'jpeg';

        dataMap['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
          contentType: MediaType('image', mimeType),
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dioClient.dio.put(
        ApiConstants.productDetail(id),
        data: formData,
      );

      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }

  // Delete Product
  Future<void> deleteProduct(String id) async {
    try {
      await _dioClient.dio.delete(ApiConstants.productDetail(id));
    } catch (e) {
      throw DioClient.handleError(e);
    }
  }
}
