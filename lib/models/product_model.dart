import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String description,
    required double price,
    required int quantity,
    required String category,
    @Default('') String image,
    required String createdBy,
    required String createdAt,
    required String updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}
