import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unimates/models/app_models.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage:
                      review.reviewerImage != null &&
                              review.reviewerImage!.isNotEmpty
                          ? NetworkImage(review.reviewerImage!)
                          : null,
                  child: review.reviewerImage == null ||
                          review.reviewerImage!.isEmpty
                      ? Text(
                          review.reviewerName.isNotEmpty
                              ? (review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : '?')
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(review.createdAt),
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                _StarRow(rating: review.rating),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(color: Colors.grey[800], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact inline star rating display
class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && (rating - i) >= 0.5;
        return Icon(
          filled
              ? Icons.star
              : (half ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}

/// A larger tappable star row for submitting a rating
class StarRatingInput extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starValue = i + 1.0;
        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              value >= starValue ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

/// Compact read-only star display used outside of ReviewCard
class StarDisplay extends StatelessWidget {
  final double rating;
  final double size;

  const StarDisplay({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return _StarRow(rating: rating, size: size);
  }
}
