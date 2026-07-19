import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import 'core_providers.dart';

class ProductState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String categoryFilter;

  ProductState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.categoryFilter = 'All',
  });

  ProductState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Standard: resets error message on update requests unless explicitly set
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _productRepository;

  ProductNotifier(this._productRepository) : super(ProductState()) {
    fetchProducts();
  }

  // Fetch product list with active search/category filters
  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _productRepository.getProducts(
        search: state.searchQuery,
        category: state.categoryFilter,
      );
      state = state.copyWith(products: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Set Search Query
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    fetchProducts();
  }

  // Set Category Filter
  void updateCategory(String category) {
    state = state.copyWith(categoryFilter: category);
    fetchProducts();
  }

  // Create Product
  Future<bool> createProduct({
    required String title,
    required String description,
    required double price,
    required int quantity,
    required String category,
    String? imagePath,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _productRepository.createProduct(
        title: title,
        description: description,
        price: price,
        quantity: quantity,
        category: category,
        imagePath: imagePath,
      );
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // Update Product
  Future<bool> updateProduct(
    String id, {
    String? title,
    String? description,
    double? price,
    int? quantity,
    String? category,
    String? imagePath,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _productRepository.updateProduct(
        id,
        title: title,
        description: description,
        price: price,
        quantity: quantity,
        category: category,
        imagePath: imagePath,
      );
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // Delete Product
  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _productRepository.deleteProduct(id);
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

// Global Product State Provider
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return ProductNotifier(productRepository);
});
