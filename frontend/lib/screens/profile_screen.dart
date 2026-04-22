import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/screens/profile/edit_profile.dart';
import 'package:unimates/screens/profile/settings.dart';
import 'package:unimates/screens/profile/my_posts.dart';
import 'package:unimates/screens/profile/my_listings.dart';
import 'package:unimates/screens/profile/reviews.dart';
import 'package:unimates/screens/profile/saved_items.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) return;
    _dataFuture = Future.wait([
      MockApiService.instance.getUserProfile(fbUser.uid),
      MockApiService.instance.getUserPosts(fbUser.uid),
      MockApiService.instance.getUserListings(fbUser.uid),
    ]);
  }

  void _refresh() => setState(() => _loadData());

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log Out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    MockApiService.instance.logoutCleanup();
    // logoutCleanup is synchronous; await only the async signOut below
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading profile'),
                  TextButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final profile = data[0] as UniMatesUser?;
          final posts = data[1] as List<Post>;
          final listings = data[2] as List<MarketplaceItem>;

          // Fallback display name: use email initial if no name yet
          final rawName = profile?.name.isNotEmpty == true
              ? profile!.name
              : (fbUser.displayName?.isNotEmpty == true
                  ? fbUser.displayName!
                  : (fbUser.email ?? ''));
          final displayName = rawName.isNotEmpty ? rawName : 'User';
          final username = profile?.username.isNotEmpty == true
              ? '@${profile!.username}'
              : null;
          final university = profile?.university ?? '';
          final bio = profile?.bio;
          final avatarUrl = profile?.profileImageUrl ?? fbUser.photoURL;
          final rating = profile?.rating ?? 0.0;
          final joinYear = profile?.joinDate.year ?? DateTime.now().year;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ── Header ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage:
                              avatarUrl != null && avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Text(
                                  displayName.isNotEmpty
                                      ? (displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (username != null) ...[
                          const SizedBox(height: 4),
                          Text(username,
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                        if (university.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school_outlined,
                                  size: 16, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(university,
                                  style:
                                      TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                        if (bio != null && bio.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            bio,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[700], height: 1.4),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Member since $joinYear',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // ── Stats row ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatTile(
                          value: '${posts.length}',
                          label: 'Posts',
                        ),
                        Container(
                            height: 40, width: 1, color: Colors.grey[300]),
                        _StatTile(
                          value: '${listings.length}',
                          label: 'Listings',
                        ),
                        Container(
                            height: 40, width: 1, color: Colors.grey[300]),
                        _StatTile(
                          value: rating > 0
                              ? rating.toStringAsFixed(1)
                              : '—',
                          label: 'Rating',
                          icon: rating > 0 ? Icons.star : null,
                        ),
                      ],
                    ),
                  ),

                  // ── Menu ──────────────────────────────────────────
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      if (profile == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(user: profile),
                        ),
                      ).then((updated) {
                        if (updated != null) _refresh();
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('My Posts'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MyPostsScreen(userId: fbUser.uid),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sell_outlined),
                    title: const Text('My Listings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MyListingsScreen(userId: fbUser.uid),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.rate_review_outlined),
                    title: const Text('My Reviews'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewsScreen(
                          targetUserId: profile?.id ?? fbUser.uid,
                          targetUserName: displayName,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline),
                    title: const Text('Saved Items'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedItemsScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Out',
                        style: TextStyle(color: Colors.red)),
                    onTap: _logout,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const _StatTile(
      {required this.value, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.amber),
              const SizedBox(width: 2),
            ],
            Text(
              value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
