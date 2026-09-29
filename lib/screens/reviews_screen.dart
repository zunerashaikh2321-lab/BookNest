import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/review_card.dart';

class ReviewsScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const ReviewsScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ApiClient _api = ApiClient();

  List<ReviewModel> _reviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // IMPORTANT:
      // getReviews() takes a positional String argument.
      final reviews = await _api.getReviews(widget.bookId);

      if (!mounted) return;

      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load reviews.';
      });
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;

    double total = 0;

    for (final review in _reviews) {
      total += double.tryParse(review.rating) ?? 0;
    }

    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Reviews',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.gold,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.gold,
              size: 50,
            ),
            const SizedBox(height: 15),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.ashes,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _loadReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.background,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.dryadBark,
      onRefresh: _loadReviews,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _bookHeader(),

          const SizedBox(height: 18),

          _ratingSummary(),

          const SizedBox(height: 25),

          Row(
            children: [
              const Text(
                'Reader Reviews',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${_reviews.length} reviews',
                style: const TextStyle(
                  color: AppColors.ashes,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (_reviews.isEmpty)
            _emptyState()
          else
            ..._reviews.map(
                  (review) => ReviewCard(
                review: review,
              ),
            ),
        ],
      ),
    );
  }

  Widget _bookHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blackKite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.gold,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reviews for',
                  style: TextStyle(
                    color: AppColors.lightCharcoal,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.bookTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.dryadBark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < _averageRating.round()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 25),

          Container(
            width: 1,
            height: 55,
            color: AppColors.lightCharcoal.withOpacity(0.3),
          ),

          const SizedBox(width: 25),

          Expanded(
            child: Text(
              _reviews.isEmpty
                  ? 'No ratings yet'
                  : 'Based on ${_reviews.length} reader ratings',
              style: const TextStyle(
                color: AppColors.ashes,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            color: AppColors.gold,
            size: 55,
          ),
          const SizedBox(height: 15),
          const Text(
            'No reviews yet',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Be the first reader to share your thoughts.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ashes,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}