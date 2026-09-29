import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/book_card.dart';
import 'book_details_screen.dart';
import 'books_screen.dart';
import 'profile_screen.dart';
import 'reading_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiClient();
  int _index = 0;
  bool _loading = true;
  String? _error;
  List<BookModel> _books = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final books = await _api.getBooks();
      if (!mounted) return;
      setState(() {
        _books = books.where((b) => b.status.isEmpty || b.status == 'active').toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      const BooksScreen(),
      const ReadingListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.blackKite,
        indicatorColor: AppColors.gold.withOpacity(.16),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.gold),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.gold),
            label: 'Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.gold),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.gold),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _home() {
    final featured = _books.where((b) => b.isFeatured.toUpperCase() == 'TRUE').toList();
    final best = _books.where((b) => b.isBestSeller.toUpperCase() == 'TRUE').toList();
    final featuredBooks = featured.isEmpty ? _books.take(6).toList() : featured;
    final bestBooks = best.isEmpty ? _books.take(6).toList() : best;

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.dryadBark,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${Session.currentUser?.name.split(' ').first ?? 'Reader'} 👋',
                      style: const TextStyle(
                        color: AppColors.ashes,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Find your next\nfavorite book.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 29,
                        height: 1.12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.blackKite,
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _index = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.dryadBark,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.lightCharcoal.withOpacity(.22),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.ashes),
                  SizedBox(width: 10),
                  Text(
                    'Search books, authors...',
                    style: TextStyle(color: AppColors.lightCharcoal),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Featured Books', 'Explore'),
          const SizedBox(height: 13),
          if (_loading)
            const SizedBox(
              height: 250,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            )
          else if (_error != null)
            _errorView()
          else if (featuredBooks.isEmpty)
              _empty('No books available yet.')
            else
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 13),
                  itemBuilder: (_, i) => BookCard(
                    book: featuredBooks[i],
                    onTap: () => _open(featuredBooks[i]),
                  ),
                ),
              ),
          const SizedBox(height: 30),
          _sectionTitle('Best Sellers', 'View all'),
          const SizedBox(height: 13),
          if (!_loading && bestBooks.isNotEmpty)
            ...bestBooks.take(4).map(
                  (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _miniBook(b),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String action) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _index = 1),
          child: Text(
            action,
            style: const TextStyle(color: AppColors.gold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _miniBook(BookModel b) {
    return GestureDetector(
      onTap: () => _open(b),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.dryadBark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 55,
                height: 70,
                child: b.imageUrl.isNotEmpty
                    ? Image.network(
                  b.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ph(),
                )
                    : _ph(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ashes,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.gold,
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        b.rating.isEmpty ? '—' : b.rating,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '₹${b.price}',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph() => Container(
    color: AppColors.blackKite,
    child: const Icon(
      Icons.menu_book_rounded,
      color: AppColors.gold,
    ),
  );

  Widget _empty(String text) => SizedBox(
    height: 180,
    child: Center(
      child: Text(text, style: const TextStyle(color: AppColors.ashes)),
    ),
  );

  Widget _errorView() => SizedBox(
    height: 180,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.gold, size: 34),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unable to load books.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.ashes),
          ),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    ),
  );

  void _open(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book)),
    );
  }
}
