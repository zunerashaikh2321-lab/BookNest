import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import '../widgets/input_field.dart';
import '../widgets/review_card.dart';

class BookDetailsScreen extends StatefulWidget {
  final BookModel book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final _api = ApiClient();
  final _reviewController = TextEditingController();

  List<ReviewModel> _reviews = [];
  bool _loadingReviews = true;
  bool _busy = false;
  double _rating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _api.getReviews(widget.book.bookId);
      if (mounted) setState(() => _reviews = reviews);
    } finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Future<void> _readingList() async {
    final user = Session.currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await _api.addToReadingList(
        userId: user.userId,
        bookId: widget.book.bookId,
      );
      _message('Added to your reading list.');
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _watched() async {
    final user = Session.currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await _api.addWatchedBook(
        userId: user.userId,
        bookId: widget.book.bookId,
      );
      _message('Marked as watched.');
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitReview() async {
    final user = Session.currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await _api.addReview(
        userId: user.userId,
        bookId: widget.book.bookId,
        rating: _rating.toStringAsFixed(1),
        reviewText: _reviewController.text,
      );
      _reviewController.clear();
      _message('Review submitted.');
      await _loadReviews();
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.blackKite,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(55, 45, 55, 25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: b.imageUrl.isNotEmpty
                      ? Image.network(
                    b.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _coverPlaceholder(),
                  )
                      : _coverPlaceholder(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  b.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'by ${b.author}',
                  style: const TextStyle(
                    color: AppColors.ashes,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _stat(Icons.star_rounded, b.rating.isEmpty ? '—' : b.rating),
                    const SizedBox(width: 10),
                    _stat(Icons.reviews_outlined, b.totalReviews.isEmpty ? '0' : b.totalReviews),
                    const Spacer(),
                    Text(
                      '₹${b.price}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  b.description.isEmpty ? 'No description available.' : b.description,
                  style: const TextStyle(
                    color: AppColors.ashes,
                    height: 1.65,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _readingList,
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: const Text('Save'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _watched,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Watched'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Write a Review',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.dryadBark,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Your rating',
                            style: TextStyle(color: AppColors.ashes),
                          ),
                          const Spacer(),
                          Text(
                            _rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _rating,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        activeColor: AppColors.gold,
                        inactiveColor: AppColors.lightCharcoal,
                        onChanged: (v) => setState(() => _rating = v),
                      ),
                      InputField(
                        label: 'Review',
                        hintText: 'Share your thoughts...',
                        prefixIcon: Icons.rate_review_outlined,
                        controller: _reviewController,
                      ),
                      const SizedBox(height: 15),
                      GoldButton(
                        text: 'Submit Review',
                        onPressed: _submitReview,
                        isLoading: _busy,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Text(
                      'Reader Reviews',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_reviews.length}',
                      style: const TextStyle(color: AppColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                if (_loadingReviews)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  )
                else if (_reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: Text(
                      'No reviews yet. Be the first reader!',
                      style: TextStyle(color: AppColors.ashes),
                    ),
                  )
                else
                  ..._reviews.map(
                        (r) => ReviewCard(review: r),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.dryadBark,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 16),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: AppColors.blackKite,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: AppColors.gold,
          size: 70,
        ),
      ),
    );
  }
}
