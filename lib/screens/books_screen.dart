import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/book_card.dart';
import 'book_details_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _api = ApiClient();
  final _search = TextEditingController();
  List<BookModel> _books = [];
  List<BookModel> _filtered = [];
  bool _loading = true;
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_filter);
  }

  Future<void> _load() async {
    try {
      final books = await _api.getBooks();
      if (!mounted) return;
      setState(() {
        _books = books;
        _loading = false;
      });
      _filter();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _filtered = _books.where((b) {
        final matchSearch = q.isEmpty ||
            b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q);
        final matchCategory =
            _category == 'All' || b.categoryId.toLowerCase() == _category.toLowerCase();
        return matchSearch && matchCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text(
            'Explore Books',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Search your next great read.',
            style: TextStyle(color: AppColors.ashes),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _search,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Search by title or author',
              hintStyle: const TextStyle(color: AppColors.lightCharcoal),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold),
              filled: true,
              fillColor: AppColors.dryadBark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in ['All', 'C001', 'C002', 'C003', 'C004', 'C005'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) {
                        setState(() => _category = c);
                        _filter();
                      },
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.dryadBark,
                      labelStyle: TextStyle(
                        color: _category == c
                            ? AppColors.background
                            : AppColors.ashes,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            )
          else if (_filtered.isEmpty)
            const SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  'No books found.',
                  style: TextStyle(color: AppColors.ashes),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                childAspectRatio: .58,
              ),
              itemBuilder: (_, i) => BookCard(
                book: _filtered[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailsScreen(book: _filtered[i]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
