import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimates/constants/app_constants.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';

/// Create Listing Screen - Phase 3B
/// Allows sellers to create new marketplace listings

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUploadingImages = false;

  bool get _hasContent =>
      _titleController.text.isNotEmpty ||
      _descriptionController.text.isNotEmpty ||
      _priceController.text.isNotEmpty;

  Future<bool> _showDiscardDialog() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard listing?'),
        content: const Text('Your changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _exchangeTermsController;

  // Form state
  ListingType _selectedType = ListingType.sell;
  String _selectedCategory = 'Electronics';
  String _selectedCondition = 'Like New';
  final List<XFile> _selectedImages = [];

  // Category options
  final List<String> _categories = [
    'Electronics',
    'Books',
    'Furniture',
    'Clothing',
    'Sports',
    'Textbooks',
    'Accessories',
    'Other'
  ];

  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair', 'Used'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _exchangeTermsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _exchangeTermsController.dispose();
    super.dispose();
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

      // Upload images first
      List<String> uploadedUrls = [];
      if (_selectedImages.isNotEmpty) {
        setState(() => _isUploadingImages = true);
        try {
          for (final xfile in _selectedImages) {
            final url = await MockApiService.instance.uploadImage(
              xfile.path,
              folder: 'marketplace',
            );
            uploadedUrls.add(url);
          }
        } catch (e) {
          if (mounted) {
            setState(() { _isLoading = false; _isUploadingImages = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image upload failed: $e'), backgroundColor: Colors.red),
            );
          }
          return;
        }
        if (mounted) setState(() => _isUploadingImages = false);
      }

    try {
      // Create listing object
      final newListing = MarketplaceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id',
        sellerName: 'Current User',
        sellerImage: null,
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrls: uploadedUrls,
        category: _selectedCategory,
        condition: _selectedCondition,
        type: _selectedType,
        price: _selectedType == ListingType.sell
            ? double.tryParse(_priceController.text)
            : null,
        exchangeTerms: _selectedType == ListingType.exchange
            ? _exchangeTermsController.text
            : null,
        createdAt: DateTime.now(),
        isSold: false,
        rating: 5.0,
        reviewsCount: 0,
      );

      // Call service to create listing
      final success = await MockApiService.instance.createMarketplaceListing(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        type: _selectedType,
        price: _selectedType == ListingType.sell
            ? double.tryParse(_priceController.text)
            : null,
        exchangeTerms: _selectedType == ListingType.exchange
            ? _exchangeTermsController.text
            : null,
        imageUrls: uploadedUrls,
        condition: _selectedCondition,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, newListing);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create listing'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addImage() async {
    if (_selectedImages.length >= 5) return;
    final picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty && mounted) {
      setState(() {
        _selectedImages.addAll(picked);
        if (_selectedImages.length > 5) {
          _selectedImages.removeRange(5, _selectedImages.length);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasContent,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final should = await _showDiscardDialog();
        if (should && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Listing'),
          centerTitle: true,
          elevation: 0,
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Listing Type Selection
                    Text(
                      'Listing Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildListingTypeSelector(),
                    const SizedBox(height: 24),

                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Item Title *',
                        hintText: 'E.g., Laptop, Physics Textbook',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Title is required';
                        }
                        if (value!.length < 5) {
                          return 'Title must be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Selection
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Condition Selection
                    Text(
                      'Condition',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.info),
                      ),
                      items: _conditions
                          .map((cond) => DropdownMenuItem(
                                value: cond,
                                child: Text(cond),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCondition = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price Field (for sell/buy types)
                    if (_selectedType == ListingType.sell ||
                        _selectedType == ListingType.buy)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: _selectedType == ListingType.sell
                                  ? 'Asking Price (₹) *'
                                  : 'Budget (₹) *',
                              hintText: 'E.g., 5000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.currency_rupee),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Price is required';
                              }
                              if (double.tryParse(value!) == null) {
                                return 'Enter a valid price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Exchange Terms (for exchange type)
                    if (_selectedType == ListingType.exchange)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _exchangeTermsController,
                            decoration: InputDecoration(
                              labelText: 'What you want in exchange *',
                              hintText: 'E.g., Looking for a physics book',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.compare_arrows),
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Exchange terms are required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Describe your item in detail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Description is required';
                        }
                        if (value!.length < 20) {
                          return 'Description must be at least 20 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Images Section
                    Text(
                      'Photos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildImageGrid(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: (_isLoading || _selectedImages.length >= 5) ? null : _addImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(_selectedImages.length >= 5 ? 'Max 5 photos' : 'Add Photo'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createListing,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isUploadingImages ? 'Uploading photos...' : 'Create Listing',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      ), // Scaffold
    ); // PopScope
  }

  Widget _buildListingTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ListingType.values.map((type) {
          final isSelected = _selectedType == type;
          final label = type.toString().split('.').last.toUpperCase();

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedType = type);
              },
              avatar: Icon(_getListingTypeIcon(type)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_selectedImages[index].path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[400],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getListingTypeIcon(ListingType type) {
    switch (type) {
      case ListingType.buy:
        return Icons.shopping_cart;
      case ListingType.sell:
        return Icons.sell;
      case ListingType.borrow:
        return Icons.card_giftcard;
      case ListingType.exchange:
        return Icons.compare_arrows;
    }
  }
}
