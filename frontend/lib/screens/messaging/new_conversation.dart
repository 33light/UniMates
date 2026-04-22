import 'package:flutter/material.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'conversations_list.dart';

/// New Conversation Screen - Phase 4
/// Allows users to start a new conversation with another user

class NewConversationScreen extends StatefulWidget {
  final String currentUserId;

  const NewConversationScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  late TextEditingController _searchController;
  List<UniMatesUser> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Start New Chat'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchUsers(value);
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching && _searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _UserSearchCard(
          user: user,
          onTap: () {
            _startConversation(user);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a new conversation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Search for a user to begin messaging',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final results =
        await MockApiService.instance.searchUsers(query);

    // Filter out current user
    final filtered =
        results.where((u) => u.id != widget.currentUserId).toList();

    if (mounted) {
      setState(() {
        _searchResults = filtered;
        _isSearching = false;
      });
    }
  }

  void _startConversation(UniMatesUser user) async {
    // Get or create conversation
    final conversation =
        await MockApiService.instance.getOrCreateConversation(
      otherUserId: user.id,
      otherUserName: user.name,
      otherUserImage: user.profileImageUrl ?? '',
      currentUserId: widget.currentUserId,
      currentUserName: 'You',
    );

    if (mounted) {
      // Navigate to chat screen
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversation: conversation,
            currentUserId: widget.currentUserId,
          ),
        ),
      );
    }
  }
}

/// User Search Card Widget
class _UserSearchCard extends StatelessWidget {
  final UniMatesUser user;
  final VoidCallback onTap;

  const _UserSearchCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: user.profileImageUrl != null
            ? NetworkImage(user.profileImageUrl!)
            : null,
        onBackgroundImageError: user.profileImageUrl != null
            ? (exception, stackTrace) {}
            : null,
        child: user.profileImageUrl == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '@${user.username}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            if (user.isVerified) ...[
              const Icon(
                Icons.verified,
                size: 14,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              '${user.university} • Rating: ${user.rating.toStringAsFixed(1)} ⭐',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      trailing: ElevatedButton(
        onPressed: onTap,
        child: const Text('Message'),
      ),
      onTap: onTap,
    );
  }
}
