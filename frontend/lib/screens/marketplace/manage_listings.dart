import 'package:flutter/material.dart';
import 'package:unimates/constants/app_constants.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/screens/marketplace/create_listing.dart';
import 'package:unimates/screens/marketplace/edit_listing.dart';

/// Manage Listings Screen - Phase 3B
/// Displays seller's current listings and allows editing/deletion

class ManageListingsScreen extends StatefulWidget {
  const ManageListingsScreen({super.key});

  @override
  State<ManageListingsScreen> createState() => _ManageListingsScreenState();
}

class _ManageListingsScreenState extends State<ManageListingsScreen> {
  late Future<List<MarketplaceItem>> _listingsFuture;
  String _filterStatus = 'All'; // All, Active, Sold

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  void _loadListings() {
    _listingsFuture = MockApiService.instance.getSellerListings();
  }

  Future<void> _deleteListing(String listingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      final success =
          await MockApiService.instance.deleteMarketplaceListing(listingId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadListings();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete listing'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _markAsSold(MarketplaceItem listing) async {
    final success = await MockApiService.instance.markListingAsSold(listing.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing marked as sold'),
            backgroundColor: Colors.green,
          ),
        );
        _loadListings();
        setState(() {});
      }
    }
  }

  List<MarketplaceItem> _filterListings(List<MarketplaceItem> listings) {
    switch (_filterStatus) {
      case 'Active':
        return listings.where((item) => !item.isSold).toList();
      case 'Sold':
        return listings.where((item) => item.isSold).toList();
      default:
        return listings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newListing = await Navigator.push<MarketplaceItem>(
            context,
            MaterialPageRoute(builder: (context) => const CreateListingScreen()),
          );

          if (newListing != null) {
            _loadListings();
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
      body: FutureBuilder<List<MarketplaceItem>>(
        future: _listingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _loadListings();
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final listings = snapshot.data ?? [];
          final filteredListings = _filterListings(listings);

          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No listings yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first listing to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final newListing = await Navigator.push<MarketplaceItem>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateListingScreen()),
                      );

                      if (newListing != null) {
                        _loadListings();
                        setState(() {});
                      }
                    },
                    child: const Text('Create Listing'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter Chips
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Active', 'Sold'].map((status) {
                      final isSelected = _filterStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _filterStatus = status);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Listings Count
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredListings.length} ${_filterStatus.toLowerCase()} listing${filteredListings.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Total: ${listings.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Listings List
              Expanded(
                child: filteredListings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list_off,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'No ${_filterStatus.toLowerCase()} listings',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium),
                        itemCount: filteredListings.length,
                        itemBuilder: (context, index) {
                          final listing = filteredListings[index];
                          return _ListingCard(
                            listing: listing,
                            onEdit: () async {
                              final updated =
                                  await Navigator.push<MarketplaceItem>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditListingScreen(listing: listing),
                                ),
                              );

                              if (updated != null) {
                                _loadListings();
                                setState(() {});
                              }
                            },
                            onDelete: () => _deleteListing(listing.id),
                            onMarkAsSold: () => _markAsSold(listing),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Individual Listing Card Component
class _ListingCard extends StatelessWidget {
  final MarketplaceItem listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsSold;

  const _ListingCard({
    required this.listing,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkAsSold,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: listing.imageUrls.isNotEmpty
                        ? Image.network(
                            listing.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported,
                                  color: Colors.grey[400]);
                            },
                          )
                        : Icon(Icons.shopping_bag_outlined,
                            color: Colors.grey[400]),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              listing.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (listing.isSold)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'SOLD',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      if (listing.price != null)
                        Text(
                          '₹${listing.price?.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: Colors.green),
                        ),
                      if (listing.exchangeTerms != null)
                        Text(
                          'Exchange: ${listing.exchangeTerms}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description preview
            Text(
              listing.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted: ${_formatDate(listing.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Type: ${listing.type.toString().split('.').last.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                if (!listing.isSold)
                  TextButton(
                    onPressed: onMarkAsSold,
                    child: const Text('Mark as Sold',
                        style: TextStyle(color: Colors.orange)),
                  ),
                if (!listing.isSold) const SizedBox(width: 8),
                TextButton(
                  onPressed: onDelete,
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
