import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/widgets/post_card.dart';
import 'package:unimates/widgets/marketplace_item_card.dart';
import 'package:unimates/screens/community/post_detail.dart';
import 'package:unimates/screens/marketplace/item_detail.dart';
import 'package:unimates/screens/lost_found/lost_found_item_detail.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  Future<Map<String, dynamic>>? _resultsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _search(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String q) {
    if (q.trim().isEmpty) {
      setState(() => _resultsFuture = null);
      return;
    }
    setState(
        () { _resultsFuture = MockApiService.instance.globalSearch(q.trim()); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search UniMates...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _resultsFuture = null);
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() {}),
          onSubmitted: _search,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          TextButton(
            onPressed: () => _search(_searchController.text),
            child: const Text('Search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Listings'),
            Tab(text: 'Lost & Found'),
            Tab(text: 'People'),
          ],
        ),
        elevation: 1,
      ),
      body: _resultsFuture == null
          ? _buildEmptyPrompt()
          : FutureBuilder<Map<String, dynamic>>(
              future: _resultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? {};
                final posts = (data['posts'] as List?)?.cast<Post>() ?? [];
                final items =
                    (data['items'] as List?)?.cast<MarketplaceItem>() ?? [];
                final lostFound =
                    (data['lostFound'] as List?)?.cast<LostFoundItem>() ?? [];
                final users =
                    (data['users'] as List?)?.cast<UniMatesUser>() ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _PostsTab(posts: posts),
                    _ListingsTab(items: items),
                    _LostFoundTab(items: lostFound),
                    _PeopleTab(users: users),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Search posts, listings, lost & found, and people',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ── Posts tab ────────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  final List<Post> posts;
  const _PostsTab({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return _NoResults(label: 'No posts found');
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (_, i) => PostCard(
        post: posts[i],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PostDetailScreen(post: posts[i]))),
        onLike: (id) async =>
            await MockApiService.instance.togglePostLike(id),
        onComment: (id) => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PostDetailScreen(post: posts[i]))),
      ),
    );
  }
}

// ── Listings tab ─────────────────────────────────────────────────────────────

class _ListingsTab extends StatelessWidget {
  final List<MarketplaceItem> items;
  const _ListingsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _NoResults(label: 'No listings found');
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (_, i) => MarketplaceItemCard(
        item: items[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailScreen(item: items[i])),
        ),
      ),
    );
  }
}

// ── Lost & Found tab ─────────────────────────────────────────────────────────

class _LostFoundTab extends StatelessWidget {
  final List<LostFoundItem> items;
  const _LostFoundTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _NoResults(label: 'No items found');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item.type == LostFoundType.lost
                  ? Colors.red[100]
                  : Colors.green[100],
              child: Icon(
                item.type == LostFoundType.lost
                    ? Icons.search
                    : Icons.inventory_2_outlined,
                color: item.type == LostFoundType.lost
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            title: Text(item.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${item.type == LostFoundType.lost ? 'Lost' : 'Found'} · ${item.location}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              DateFormat('MMM d').format(item.itemDate),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => LostFoundItemDetailScreen(item: item)),
            ),
          ),
        );
      },
    );
  }
}

// ── People tab ───────────────────────────────────────────────────────────────

class _PeopleTab extends StatelessWidget {
  final List<UniMatesUser> users;
  const _PeopleTab({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return _NoResults(label: 'No users found');
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final user = users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: user.profileImageUrl != null &&
                      user.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null ||
                      user.profileImageUrl!.isEmpty
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(user.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('@${user.username} · ${user.university}'),
            trailing: user.rating > 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(user.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13)),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}

// ── Shared empty state ────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String label;
  const _NoResults({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        ],
      ),
    );
  }
}
