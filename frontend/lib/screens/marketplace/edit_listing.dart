import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimates/constants/app_constants.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';

/// Edit Listing Screen - Phase 3B
/// Allows sellers to edit existing marketplace listings

class EditListingScreen extends StatefulWidget {
  final MarketplaceItem listing;

  const EditListingScreen({
    super.key,
    required this.listing,
  });

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _exchangeTermsController;

  // Form state
  late ListingType _selectedType;
  late String _selectedCategory;
  late String _selectedCondition;
  // Existing image URLs from the listing (can be removed)
  final List<String> _existingImageUrls = [];
  // Newly picked local files (not yet uploaded)
  final List<XFile> _newImages = [];
  bool _isUploadingImages = false;

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
    _initializeFromListing();
  }

  void _initializeFromListing() {
    _selectedType = widget.listing.type;
    _selectedCategory = widget.listing.category;
    _selectedCondition = 'Like New'; // Default, could be enhanced

    _titleController = TextEditingController(text: widget.listing.title);
    _descriptionController =
        TextEditingController(text: widget.listing.description);
    _priceController = TextEditingController(
      text: widget.listing.price?.toStringAsFixed(0) ?? '',
    );
    _exchangeTermsController =
        TextEditingController(text: widget.listing.exchangeTerms ?? '');

    _existingImageUrls.addAll(widget.listing.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _exchangeTermsController.dispose();
    super.dispose();
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedListing = MarketplaceItem(
        id: widget.listing.id,
        userId: widget.listing.userId,
        sellerName: widget.listing.sellerName,
        sellerImage: widget.listing.sellerImage,
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrls: _existingImageUrls, // new images appended after upload
        category: _selectedCategory,
        type: _selectedType,
        price: _selectedType == ListingType.sell
            ? double.tryParse(_priceController.text)
            : null,
        exchangeTerms: _selectedType == ListingType.exchange
            ? _exchangeTermsController.text
            : null,
        createdAt: widget.listing.createdAt,
        isSold: widget.listing.isSold,
        rating: widget.listing.rating,
        reviewsCount: widget.listing.reviewsCount,
      );

      // Upload any newly picked images
      List<String> allImageUrls = List.from(_existingImageUrls);
      if (_newImages.isNotEmpty) {
        setState(() => _isUploadingImages = true);
        try {
          for (final xfile in _newImages) {
            final url = await MockApiService.instance.uploadImage(
              xfile.path,
              folder: 'marketplace',
            );
            allImageUrls.add(url);
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

      final success = await MockApiService.instance.updateMarketplaceListing(
        listingId: widget.listing.id,
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
        imageUrls: allImageUrls,
        condition: _selectedCondition,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, updatedListing);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update listing'),
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
    final totalImages = _existingImageUrls.length + _newImages.length;
    if (totalImages >= 5) return;
    final picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty && mounted) {
      setState(() {
        _newImages.addAll(picked);
        final overflow = _existingImageUrls.length + _newImages.length - 5;
        if (overflow > 0) _newImages.removeRange(_newImages.length - overflow, _newImages.length);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _existingImageUrls.length) {
        _existingImageUrls.removeAt(index);
      } else {
        _newImages.removeAt(index - _existingImageUrls.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
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
                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Note: Some fields may be restricted after creation',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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
                        onPressed: (_existingImageUrls.length + _newImages.length >= 5)
                            ? null
                            : _addImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: Text(
                          (_existingImageUrls.length + _newImages.length >= 5)
                              ? 'Max 5 photos'
                              : 'Add Photo',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isUploadingImages) ? null : _updateListing,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: (_isLoading || _isUploadingImages)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_isUploadingImages ? 'Uploading...' : 'Saving...'),
                                  ],
                                )
                              : const Text(
                                  'Update Listing',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Listing Info
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Listing Information',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Created', _formatDate(widget.listing.createdAt)),
                          _buildInfoRow('ID', widget.listing.id),
                          _buildInfoRow(
                              'Status', widget.listing.isSold ? 'Sold' : 'Active'),
                          _buildInfoRow('Views', '${widget.listing.reviewsCount}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
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
    final totalImages = _existingImageUrls.length + _newImages.length;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalImages,
      itemBuilder: (context, index) {
        final isExisting = index < _existingImageUrls.length;
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isExisting
                    ? Image.network(
                        _existingImageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Image.file(
                        File(_newImages[index - _existingImageUrls.length].path),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
