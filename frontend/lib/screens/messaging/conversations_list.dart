import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'new_conversation.dart';


class ConversationsListScreen extends StatefulWidget {
  final String currentUserId;

  const ConversationsListScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshConversations();
  }

  void _refreshConversations() {
    _conversationsFuture =
        MockApiService.instance.getConversations(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Conversation>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _ConversationCard(
                conversation: conversation,
                currentUserId: widget.currentUserId,
                onTap: () async {
                  // Mark as read when opening — capture nav first
                  final navigator = Navigator.of(context);
                  await MockApiService.instance
                      .markConversationAsRead(conversation.id);

                  if (!mounted) return;

                  // Navigate to chat screen
                  await navigator.push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        conversation: conversation,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );

                  // Refresh the list
                  if (mounted) {
                    _refreshConversations();
                    setState(() {});
                  }
                },
                onDelete: () async {
                  await MockApiService.instance
                      .deleteConversation(conversation.id);
                  if (mounted) {
                    _refreshConversations();
                    setState(() {});
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNewConversation(context);
        },
        tooltip: 'Start New Chat',
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _navigateToNewConversation(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewConversationScreen(
          currentUserId: widget.currentUserId,
        ),
      ),
    );

    if (mounted) {
      _refreshConversations();
      setState(() {});
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation to begin messaging',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _navigateToNewConversation(context);
            },
            icon: const Icon(Icons.add_comment),
            label: const Text('Start a Chat'),
          ),
        ],
      ),
    );
  }
}

/// Conversation Card Widget
class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationCard({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = conversation.unreadCount > 0;
    final lastMessageTime = _formatTime(conversation.lastMessageTime);
    final otherUserName = conversation.getOtherUserName(currentUserId);
    final otherUserImage = conversation.getOtherUserImage(currentUserId);

    return Dismissible(
      key: Key(conversation.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        // Show confirmation dialog and return the result
        final otherName = conversation.getOtherUserName(currentUserId);
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: Text(
              'Delete conversation with $otherName?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        
        if (result == true) {
          onDelete();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conversation deleted')),
            );
          }
        }
        return result ?? false;
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: otherUserImage != null
              ? NetworkImage(otherUserImage)
              : null,
          onBackgroundImageError: otherUserImage != null
              ? (exception, stackTrace) {}
              : null,
          child: otherUserImage == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          otherUserName,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isUnread ? Colors.black87 : Colors.grey[600],
            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              lastMessageTime,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            if (isUnread) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }
}

// =====================
// Chat Screen
// =====================

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  late Future<List<Message>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messagesFuture =
        MockApiService.instance.getMessages(widget.conversation.id);
  }

  void _showUserProfile() {
    final name = widget.conversation.getOtherUserName(widget.currentUserId);
    final image = widget.conversation.getOtherUserImage(widget.currentUserId);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: image != null ? NetworkImage(image) : null,
              onBackgroundImageError: image != null ? (e, st) {} : null,
              child: image == null ? const Icon(Icons.person, size: 40) : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'UniMates Member',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
        title: GestureDetector(
          onTap: _showUserProfile,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.conversation.getOtherUserName(widget.currentUserId)),
              Text(
                'Tap to view profile',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Start a conversation with ${widget.conversation.getOtherUserName(widget.currentUserId)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message.senderId == widget.currentUserId;

                    return _MessageBubble(
                      message: message,
                      isSender: isSender,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: _sendMessage,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversation.id,
      senderId: widget.currentUserId, // Django UUID at this point
      senderName: 'You',
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final success = await MockApiService.instance.sendMessage(message);

    if (success && mounted) {
      setState(() {
        _messagesFuture =
            MockApiService.instance.getMessages(widget.conversation.id);
      });
      // Scroll to bottom
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }
}

/// Message Bubble Widget
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSender;

  const _MessageBubble({
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isSender
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isSender ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
