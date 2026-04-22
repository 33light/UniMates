import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/mock_api_service.dart';
import '../../screens/search/search_screen.dart';
import 'report_lost_item.dart';
import 'report_found_item.dart';
import 'lost_found_item_detail.dart';

class LostFoundHomeScreen extends StatefulWidget {
  const LostFoundHomeScreen({super.key});

  @override
  State<LostFoundHomeScreen> createState() => _LostFoundHomeScreenState();
}

class _LostFoundHomeScreenState extends State<LostFoundHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<LostFoundItem> _lostItems = [];
  List<LostFoundItem> _foundItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Rebuild when the user switches tabs
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    // Pre-populate from cache so the screen never appears empty on remount
    _lostItems = MockApiService.instance.getCachedLostFoundItems(LostFoundType.lost);
    _foundItems = MockApiService.instance.getCachedLostFoundItems(LostFoundType.found);
    // Only show spinner if there is no cached data yet
    _isLoading = _lostItems.isEmpty && _foundItems.isEmpty;
    // Always refresh from network in the background
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final lost = await MockApiService.instance
          .getLostFoundItems(type: LostFoundType.lost, showResolved: false);
      final found = await MockApiService.instance
          .getLostFoundItems(type: LostFoundType.found, showResolved: false);
      if (mounted) {
        setState(() {
          _lostItems = lost;
          _foundItems = found;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  Future<void> _loadSearch(String query) async {
    try {
      final all = await MockApiService.instance.searchLostFoundItemsByQuery(query);
      if (mounted) {
        setState(() {
          _lostItems = all.where((i) => i.type == LostFoundType.lost && !i.isResolved).toList();
          _foundItems = all.where((i) => i.type == LostFoundType.found && !i.isResolved).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  void _refresh() {
    setState(() { _isLoading = true; _error = null; });
    if (_searchQuery.isEmpty) {
      _loadItems();
    } else {
      _loadSearch(_searchQuery);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Global Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _refresh();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _refresh();
                  },
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Lost Items'),
                  Tab(text: 'Found Items'),
                ],
              ),
            ],
          ),
        ),
      ),
      // Body: directly switch based on current tab index — no PageView caching
      body: _tabController.index == 0
          ? _buildItemsList(LostFoundType.lost, _lostItems)
          : _buildItemsList(LostFoundType.found, _foundItems),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReportMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

Widget _buildItemsList(LostFoundType type, List<LostFoundItem> items) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        key: ValueKey(type),
        onRefresh: () async => _refresh(),
        child: ListView(
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type == LostFoundType.lost ? Icons.search : Icons.inbox,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No ${type == LostFoundType.lost ? 'lost' : 'found'} items yet'
                          : 'No results found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    if (_searchQuery.isEmpty) ...[  
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to report an item',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: ValueKey(type),
      onRefresh: () async => _refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildItemCard(context, items[index]),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, LostFoundItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LostFoundItemDetailScreen(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Item image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: item.imageUrls.isNotEmpty
                      ? Image.network(
                          item.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                item.type == LostFoundType.lost
                                    ? Icons.help_outline
                                    : Icons.check_circle_outline,
                                size: 32,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            item.type == LostFoundType.lost
                                ? Icons.help_outline
                                : Icons.check_circle_outline,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.itemDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Reporter and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                          children: [
                            if (item.reporterImage != null)
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(item.reporterImage!),
                                onBackgroundImageError: (exception, stackTrace) {},
                              )
                            else
                              CircleAvatar(
                                radius: 12,
                                child: Text(
                                  item.reporterName.isNotEmpty ? item.reporterName[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.reporterName,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        ),
                        if (item.isResolved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Resolved',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Report an Item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Report Lost Item'),
              subtitle: const Text('I lost something'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportLostItemScreen(),
                  ),
                ).then((_) => _refresh());
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Report Found Item'),
              subtitle: const Text('I found something'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportFoundItemScreen(),
                  ),
                ).then((_) => _refresh());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
