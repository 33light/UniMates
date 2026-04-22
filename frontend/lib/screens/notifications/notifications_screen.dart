import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unimates/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.addListener(_onUpdate);
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'message':
        return Icons.message;
      case 'resolved':
        return Icons.check_circle;
      case 'found':
        return Icons.search;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'message':
        return Colors.purple;
      case 'resolved':
        return Colors.green;
      case 'found':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService.instance.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                NotificationService.instance.markAllRead();
                setState(() {});
              },
              child: const Text('Mark all read'),
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () {
                NotificationService.instance.clearAll();
                setState(() {});
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet.',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Activity like likes, comments, and\nmessages will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 70),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor:
                        _colorForType(n.type).withAlpha(30),
                    child: Icon(
                      _iconForType(n.type),
                      color: _colorForType(n.type),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.body,
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(n.createdAt),
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                  tileColor: n.isRead
                      ? null
                      : Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(40),
                  onTap: () {
                    NotificationService.instance.markRead(n.id);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}
