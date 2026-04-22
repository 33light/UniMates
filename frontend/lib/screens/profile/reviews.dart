import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/widgets/review_card.dart';

class ReviewsScreen extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const ReviewsScreen({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late Future<List<Review>> _reviewsFuture;
  late Future<bool> _hasReviewedFuture;
  bool _isSelf = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkIsSelf();
  }

  void _load() {
    _reviewsFuture =
        MockApiService.instance.getReviews(widget.targetUserId);
    _hasReviewedFuture =
        MockApiService.instance.hasReviewed(widget.targetUserId);
  }

  Future<void> _checkIsSelf() async {
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Fast path: target is current user's Firebase UID
    if (firebaseUid == widget.targetUserId) {
      if (mounted) setState(() => _isSelf = true);
      return;
    }
    // Slow path: target is a Django UUID — compare against cached Django ID
    final djangoId = await MockApiService.instance.getCurrentUserDjangoId();
    if (mounted && djangoId != null && djangoId == widget.targetUserId) {
      setState(() => _isSelf = true);
    }
  }

  void _refresh() => setState(() => _load());

  Future<void> _openAddReview() async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddReviewSheet(targetUserId: widget.targetUserId),
    );
    if (!mounted) return;
    if (submitted == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isSelf = _isSelf;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.targetUserName}'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data ?? [];

          double avgRating = 0;
          if (reviews.isNotEmpty) {
            avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;
          }

          return Column(
            children: [
              // Summary header
              if (reviews.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      StarDisplay(rating: avgRating, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} review${reviews.length == 1 ? '' : 's'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

              // Reviews list
              Expanded(
                child: reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No reviews yet.',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (_, i) => ReviewCard(review: reviews[i]),
                      ),
              ),

              // Leave a review button
              if (!isSelf)
                FutureBuilder<bool>(
                  future: _hasReviewedFuture,
                  builder: (context, snap) {
                    final alreadyReviewed = snap.data == true;
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                alreadyReviewed ? null : _openAddReview,
                            icon: Icon(alreadyReviewed
                                ? Icons.check
                                : Icons.rate_review_outlined),
                            label: Text(alreadyReviewed
                                ? 'You already reviewed this user'
                                : 'Leave a Review'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Add Review Bottom Sheet ────────────────────────────────────────────────

class _AddReviewSheet extends StatefulWidget {
  final String targetUserId;
  const _AddReviewSheet({required this.targetUserId});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write a comment')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final error = await MockApiService.instance.addReview(
        targetUserId: widget.targetUserId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (mounted) {
        if (error == null) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          Navigator.pop(context, false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Leave a Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          StarRatingInput(
            value: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: 6),
          Text(
            _rating == 0
                ? 'Tap to rate'
                : ['', 'Poor', 'Fair', 'Good', 'Very Good',
                    'Excellent'][_rating.toInt()],
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Comment',
              hintText: 'Describe your experience...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Review',
                      style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
