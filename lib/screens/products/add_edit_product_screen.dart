import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/product_provider.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedImagePath;
  String? _existingImageUrl;
  bool _isEditMode = false;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Food',
    'Home',
    'Office',
    'Sports',
    'Other'
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;
    if (_isEditMode) {
      _loadProductData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Pre-populate fields in edit mode
  void _loadProductData() {
    final productState = ref.read(productProvider);
    final productIndex = productState.products.indexWhere((p) => p.id == widget.productId);
    if (productIndex != -1) {
      final product = productState.products[productIndex];
      _titleController.text = product.title;
      _priceController.text = product.price.toString();
      _quantityController.text = product.quantity.toString();
      _descriptionController.text = product.description;
      _selectedCategory = product.category;
      _existingImageUrl = product.image;
    }
  }

  // Pick new image
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final quantity = int.parse(_quantityController.text.trim());
    final description = _descriptionController.text.trim();
    final category = _selectedCategory!;

    bool success = false;

    if (_isEditMode) {
      success = await ref.read(productProvider.notifier).updateProduct(
            widget.productId!,
            title: title,
            price: price,
            quantity: quantity,
            description: description,
            category: category,
            imagePath: _selectedImagePath,
          );
    } else {
      success = await ref.read(productProvider.notifier).createProduct(
            title: title,
            price: price,
            quantity: quantity,
            description: description,
            category: category,
            imagePath: _selectedImagePath,
          );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Product updated successfully' : 'Product created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(); // Go back
      } else {
        final error = ref.read(productProvider).errorMessage ?? 'An error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add New Product'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product image picker area
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF1E2623)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: _buildImageSelector(theme),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price and Quantity Fields (Row)
                  Row(
                    children: [
                      // Price
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Price (\$)',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter price';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Quantity
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter quantity';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity < 0) {
                              return 'Invalid qty';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Product Description',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 56.0),
                        child: Icon(Icons.description_outlined),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Save Button
                  ElevatedButton(
                    onPressed: productState.isLoading ? null : _submit,
                    child: const Text('Save Product'),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (productState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSelector(ThemeData theme) {
    // If a new local image is chosen
    if (_selectedImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.25)),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 36),
                  SizedBox(height: 6),
                  Text('Change Product Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      );
    }

    // If edit mode and existing network image is present
    if (_isEditMode && _existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network('${ApiConstants.uploadsUrl}$_existingImageUrl', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.25)),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 36),
                  SizedBox(height: 6),
                  Text('Change Product Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      );
    }

    // Default empty placeholder state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            'Upload Product Image',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Tap to select from gallery', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
