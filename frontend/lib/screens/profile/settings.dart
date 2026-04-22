import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification toggles
  bool _communityNotifs = true;
  bool _marketplaceNotifs = true;
  bool _messageNotifs = true;
  bool _lostFoundNotifs = false;

  @override
  void initState() {
    super.initState();
    _loadNotifPrefs();
  }

  Future<void> _loadNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _communityNotifs = prefs.getBool('notif_community') ?? true;
        _marketplaceNotifs = prefs.getBool('notif_marketplace') ?? true;
        _messageNotifs = prefs.getBool('notif_messages') ?? true;
        _lostFoundNotifs = prefs.getBool('notif_lostfound') ?? false;
      });
    }
  }

  Future<void> _setNotif(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _showThemeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SimpleDialog(
          title: const Text('Choose Theme'),
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              subtitle: const Text('Follow device setting'),
              value: ThemeMode.system,
              groupValue: AppThemeMode.notifier.value,
              onChanged: (m) {
                AppThemeMode.notifier.value = m!;
                setDialogState(() {});
                if (mounted) setState(() {});
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: AppThemeMode.notifier.value,
              onChanged: (m) {
                AppThemeMode.notifier.value = m!;
                setDialogState(() {});
                if (mounted) setState(() {});
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: AppThemeMode.notifier.value,
              onChanged: (m) {
                AppThemeMode.notifier.value = m!;
                setDialogState(() {});
                if (mounted) setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _currentThemeName() {
    switch (AppThemeMode.notifier.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  Future<void> _sendPasswordReset() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email address found.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Text(
            'A password reset link will be sent to ${user.email}. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Send')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to ${user.email}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error sending reset email.')),
        );
      }
    }
  }

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
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── Account ──────────────────────────────────────────────
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            subtitle: const Text('Send a reset link to your email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _sendPasswordReset,
          ),
          const Divider(height: 1),

          // ── Notifications ─────────────────────────────────────────
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.forum_outlined),
            title: const Text('Community'),
            subtitle: const Text('Likes and comments on your posts'),
            value: _communityNotifs,
            onChanged: (v) {
              setState(() => _communityNotifs = v);
              _setNotif('notif_community', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sell_outlined),
            title: const Text('Marketplace'),
            subtitle: const Text('Inquiries about your listings'),
            value: _marketplaceNotifs,
            onChanged: (v) {
              setState(() => _marketplaceNotifs = v);
              _setNotif('notif_marketplace', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.message_outlined),
            title: const Text('Messages'),
            subtitle: const Text('New messages and replies'),
            value: _messageNotifs,
            onChanged: (v) {
              setState(() => _messageNotifs = v);
              _setNotif('notif_messages', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.search_outlined),
            title: const Text('Lost & Found'),
            subtitle: const Text('Updates on items near your campus'),
            value: _lostFoundNotifs,
            onChanged: (v) {
              setState(() => _lostFoundNotifs = v);
              _setNotif('notif_lostfound', v);
            },
          ),
          const Divider(height: 1),

          // ── App ───────────────────────────────────────────────────
          _SectionHeader(title: 'App'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(_currentThemeName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showThemeDialog,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About UniMates'),
            subtitle: const Text('Version 2.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'UniMates',
                applicationVersion: '2.0.0',
                applicationLegalese: '© 2026 UniMates Team',
              );
            },
          ),
          const Divider(height: 1),

          // ── Danger Zone ───────────────────────────────────────────
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log Out',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
