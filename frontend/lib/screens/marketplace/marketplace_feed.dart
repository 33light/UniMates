import 'package:flutter/material.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/widgets/marketplace_item_card.dart';
import 'package:unimates/screens/search/search_screen.dart';
import 'item_detail.dart';
import 'manage_listings.dart';

class MarketplaceFeedScreen extends StatefulWidget {
  const MarketplaceFeedScreen({super.key});

  @override
  State<MarketplaceFeedScreen> createState() => _MarketplaceFeedScreenState();
}

class _MarketplaceFeedScreenState extends State<MarketplaceFeedScreen> {
  final MockApiService _apiService = MockApiService.instance;
  late Future<List<MarketplaceItem>> _itemsFuture;
  final ScrollController _scrollController = ScrollController();

  // Pagination state
  int _currentPage = 0;
  final int _pageSize = 10;
  List<MarketplaceItem> _allItems = [];
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;
  String? _paginationError;

  // Filter state
  String? _selectedCategory;
  ListingType? _selectedType;
  double? _minPrice;
  double? _maxPrice;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadInitialItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<MarketplaceItem>> _loadInitialItems() async {
    final items = await _apiService.getMarketplaceItems(
      page: 0,
      pageSize: _pageSize,
      category: _selectedCategory,
      type: _selectedType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      searchQuery: _searchQuery,
    );
    if (mounted) setState(() => _allItems = items);
    return items;
  }

  void _onScroll() {
    // Load more items when user scrolls near the bottom
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !_isLoadingMore &&
        _hasMoreItems &&
        _paginationError == null) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore) return;

    if (!mounted) return;

    setState(() {
      _isLoadingMore = true;
      _paginationError = null;
    });

    try {
      final newItems = await _apiService.getMarketplaceItems(
        page: _currentPage + 1,
        pageSize: _pageSize,
        category: _selectedCategory,
        type: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        searchQuery: _searchQuery,
      );

      if (!mounted) return;

      if (newItems.isEmpty) {
        setState(() => _hasMoreItems = false);
      } else {
        setState(() {
          _currentPage++;
          _allItems.addAll(newItems);
        });
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Error loading more items: $e');
      setState(() {
        _paginationError = 'Failed to load more items';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _retryLoadingMore() {
    setState(() => _paginationError = null);
    _loadMoreItems();
  }

  Future<void> _refreshItems() async {
    setState(() {
      _currentPage = 0;
      _allItems = [];
      _hasMoreItems = true;
      _isLoadingMore = false;
      _paginationError = null;
      _itemsFuture = _loadInitialItems();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        selectedCategory: _selectedCategory,
        selectedType: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        searchQuery: _searchQuery,
        onApplyFilters: (category, type, minPrice, maxPrice, searchQuery) {
          setState(() {
            _selectedCategory = category;
            _selectedType = type;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _searchQuery = searchQuery;
            _currentPage = 0;
            _allItems = [];
            _hasMoreItems = true;
            _paginationError = null;
            _itemsFuture = _loadInitialItems();
          });
        },
        onClearFilters: () {
          setState(() {
            _selectedCategory = null;
            _selectedType = null;
            _minPrice = null;
            _maxPrice = null;
            _searchQuery = null;
            _currentPage = 0;
            _allItems = [];
            _hasMoreItems = true;
            _paginationError = null;
            _itemsFuture = _loadInitialItems();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Global Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageListingsScreen(),
                ),
              ).then((_) => _refreshItems());
            },
            tooltip: 'My Listings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshItems,
            tooltip: 'Refresh items',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilterSheet,
            tooltip: 'Filter & Search',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshItems,
        child: FutureBuilder<List<MarketplaceItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _allItems.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError && _allItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refreshItems,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }



            if (_allItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _selectedCategory = null;
                        _selectedType = null;
                        _minPrice = null;
                        _maxPrice = null;
                        _searchQuery = null;
                        _currentPage = 0;
                        _allItems = [];
                        _hasMoreItems = true;
                        _paginationError = null;
                        _itemsFuture = _loadInitialItems();
                      }),
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _allItems.length + (_isLoadingMore ? 1 : 0) + (_paginationError != null ? 1 : 0),
              itemBuilder: (context, index) {
                // Show error message at the bottom
                if (_paginationError != null &&
                    index == _allItems.length + (_isLoadingMore ? 1 : 0)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _paginationError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _retryLoadingMore,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show loading indicator at the bottom
                if (index == _allItems.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: MarketplaceItemCard(
                    item: _allItems[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(
                            item: _allItems[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? selectedCategory;
  final ListingType? selectedType;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;
  final Function(String?, ListingType?, double?, double?, String?)
      onApplyFilters;
  final VoidCallback onClearFilters;

  const _FilterBottomSheet({
    required this.selectedCategory,
    required this.selectedType,
    required this.minPrice,
    required this.maxPrice,
    required this.searchQuery,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _category = widget.selectedCategory;
  late ListingType? _type = widget.selectedType;
  late double? _minPrice = widget.minPrice;
  late double? _maxPrice = widget.maxPrice;
  late String? _searchQuery = widget.searchQuery;
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'Electronics',
    'Books',
    'Furniture',
    'Clothing',
    'Sports',
    'Stationery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = _searchQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter & Search',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search items...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _searchQuery = value.isEmpty ? null : value;
                  },
                ),
                const SizedBox(height: 20),
                // Category
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _category == null,
                      onSelected: (selected) {
                        setState(() => _category = null);
                      },
                    ),
                    ..._categories.map(
                      (cat) => FilterChip(
                        label: Text(cat),
                        selected: _category == cat,
                        onSelected: (selected) {
                          setState(() => _category = selected ? cat : null);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Type
                Text(
                  'Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _type == null,
                      onSelected: (selected) {
                        setState(() => _type = null);
                      },
                    ),
                    ...ListingType.values.map(
                      (t) => FilterChip(
                        label: Text(t.toString().split('.').last.toUpperCase()),
                        selected: _type == t,
                        onSelected: (selected) {
                          setState(() => _type = selected ? t : null);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Price Range
                Text(
                  'Price Range',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          _minPrice = value.isEmpty ? null : double.tryParse(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          _maxPrice = value.isEmpty ? null : double.tryParse(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onClearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApplyFilters(
                            _category,
                            _type,
                            _minPrice,
                            _maxPrice,
                            _searchQuery,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
