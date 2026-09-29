import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../models/watched_book_model.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/book_list_tile.dart';
import 'book_details_screen.dart';

class WatchedBooksScreen extends StatefulWidget {
  const WatchedBooksScreen({super.key});

  @override
  State<WatchedBooksScreen> createState() =>
      _WatchedBooksScreenState();
}

class _WatchedBooksScreenState
    extends State<WatchedBooksScreen> {
  final ApiClient _api = ApiClient();

  bool _loading = true;

  List<_Watched> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============================================================
  // LOAD WATCHED BOOKS
  // ============================================================

  Future<void> _load() async {
    final user = Session.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    try {
      final list = await _api.getWatchedBooks(
        userId: user.userId,
      );

      final result = <_Watched>[];

      for (final item in list) {
        final watched = WatchedBookModel.fromJson(
          Map<String, dynamic>.from(item),
        );

        final book = await _api.getBook(
          bookId: watched.bookId,
        );

        if (book != null) {
          result.add(
            _Watched(
              watched,
              book,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _items = result;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'WATCHED BOOKS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: AppColors.blackKite,
        ),
      );
    }
  }

  // ============================================================
  // REMOVE WATCHED BOOK
  // ============================================================

  Future<void> _remove(_Watched item) async {
    try {
      await _api.removeWatchedBook(
        watchedId: item.item.watchedId,
      );

      if (!mounted) return;

      setState(() {
        _items.remove(item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Book removed from watched books.',
          ),
          backgroundColor: AppColors.blackKite,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: AppColors.blackKite,
        ),
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Watched Books',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: RefreshIndicator(
        color: AppColors.gold,
        backgroundColor: AppColors.dryadBark,
        onRefresh: _load,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            28,
          ),

          children: [
            // --------------------------------------------------
            // LOADING
            // --------------------------------------------------

            if (_loading)
              const SizedBox(
                height: 350,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                  ),
                ),
              )

            // --------------------------------------------------
            // EMPTY
            // --------------------------------------------------

            else if (_items.isEmpty)
              const SizedBox(
                height: 350,
                child: Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.gold,
                        size: 55,
                      ),

                      SizedBox(height: 16),

                      Text(
                        'No watched books yet.',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'Books you mark as watched will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.ashes,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )

            // --------------------------------------------------
            // BOOK LIST
            // --------------------------------------------------

            else
              ..._items.map(
                    (item) => BookListTile(
                  book: item.book,

                  onRemove: () => _remove(item),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookDetailsScreen(
                              book: item.book,
                            ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INTERNAL MODEL
// ============================================================

class _Watched {
  final WatchedBookModel item;
  final BookModel book;

  const _Watched(
      this.item,
      this.book,
      );
}