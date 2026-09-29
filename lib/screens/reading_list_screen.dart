import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/reading_list_model.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/book_list_tile.dart';
import 'book_details_screen.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  final _api = ApiClient();
  bool _loading = true;
  String? _error;
  List<_SavedBook> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Session.currentUser;

    if (user == null) return;

    try {
      final list = await _api.getReadingList(
        userId: user.userId,
      );

      final result = <_SavedBook>[];

      for (final item in list) {
        final book = await _api.getBook(
          bookId: item.bookId,
        );

        if (book != null) {
          result.add(
            _SavedBook(item, book),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _items = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        _loading = false;
      });
    }
  }

  Future<void> _remove(_SavedBook item) async {
    try {
      await _api.removeFromReadingList(
        listId: item.item.listId,
      );
      setState(() => _items.remove(item));
      _message('Removed from reading list.');
    } catch (e) {
      _message(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppColors.blackKite),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.dryadBark,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const Text(
            'My Reading List',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Books you want to read next.',
            style: TextStyle(color: AppColors.ashes),
          ),
          const SizedBox(height: 22),
          if (_loading)
            const SizedBox(
              height: 350,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.ashes),
                ),
              ),
            )
          else if (_items.isEmpty)
              const SizedBox(
                height: 350,
                child: Center(
                  child: Text(
                    'Your reading list is empty.',
                    style: TextStyle(color: AppColors.ashes),
                  ),
                ),
              )
            else
              ..._items.map(
                    (item) => BookListTile(
                  book: item.book,
                  onRemove: () => _remove(item),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailsScreen(book: item.book),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SavedBook {
  final ReadingListModel item;
  final BookModel book;
  _SavedBook(this.item, this.book);
}
