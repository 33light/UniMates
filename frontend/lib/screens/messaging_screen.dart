import 'package:flutter/material.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'messaging/conversations_list.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  late Future<String?> _currentUserIdFuture;

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = MockApiService.instance.getCurrentUserDjangoId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _currentUserIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final currentUserId = snapshot.data ?? '';
        return ConversationsListScreen(currentUserId: currentUserId);
      },
    );
  }
}
