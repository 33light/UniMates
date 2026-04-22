import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unimates/models/app_models.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;
  final Function(String postId) onLike;
  final Function(String postId) onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLikedByCurrentUser ?? false;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    widget.onLike(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.post.author.profileImageUrl != null
                      ? NetworkImage(widget.post.author.profileImageUrl!)
                      : null,
                  child: widget.post.author.profileImageUrl == null
                      ? Text(
                          widget.post.author.name.isNotEmpty ? widget.post.author.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.author.name.isNotEmpty
                            ? widget.post.author.name
                            : widget.post.author.email.split('@').first,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (widget.post.author.username.isNotEmpty)
                        Text(
                          '@${widget.post.author.username}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                ),
                Text(
                  dateFormatter.format(widget.post.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),
          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Post Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.likesCount} likes',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.comment,
                  size: 16,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.commentsCount} comments',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _toggleLike,
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                    label: Text(
                      _isLiked ? 'Liked' : 'Like',
                      style: TextStyle(
                        color: _isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => widget.onComment(widget.post.id),
                    icon: const Icon(Icons.comment_outlined),
                    label: const Text('Comment'),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: widget.onTap,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('View'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
