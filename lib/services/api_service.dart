import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/book_model.dart';
import '../models/category_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../models/reading_list_model.dart';
class ApiClient {
  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbxuYUUM4QVKTr2knsVhRdhS0TZRaSv6X3I3JNOl6TMQEP1F5WwdcJnhS1wYKGIVVg48/exec';

  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) {
          return status != null &&
              status >= 200 &&
              status < 400;
        },
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // ============================================================
  // COMMON RESPONSE
  // ============================================================

  Map<String, dynamic> _mapResponse(Response response) {
    final data = response.data;

    debugPrint('API STATUS: ${response.statusCode}');
    debugPrint('API DATA: $data');

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      'Invalid response received from server.',
    );
  }

  void _checkSuccess(Map<String, dynamic> data) {
    if (data['status'] != 'success') {
      throw Exception(
        data['message']?.toString() ??
            'Something went wrong.',
      );
    }
  }

  Future<Map<String, dynamic>> _get({
    required String action,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final params = <String, dynamic>{
        'action': action,
      };

      if (queryParameters != null) {
        params.addAll(queryParameters);
      }

      final response = await _dio.get(
        '',
        queryParameters: params,
      );

      return _mapResponse(response);
    } on DioException catch (e) {
      debugPrint('--------------------------------');
      debugPrint('API ERROR');
      debugPrint('ACTION: $action');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('DATA: ${e.response?.data}');
      debugPrint('--------------------------------');

      throw Exception(
        e.message ?? 'Network error occurred.',
      );
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _get(
      action: 'login',
      queryParameters: {
        'email': email.trim(),
        'password': password,
      },
    );

    _checkSuccess(data);

    final result = Map<String, dynamic>.from(
      data['data'] ?? {},
    );

    return UserModel(
      userId: result['user_id']?.toString() ?? '',
      name: result['name']?.toString() ?? '',
      birthdate: result['birthdate']?.toString() ?? '',
      gender: result['gender']?.toString() ?? '',
      email: result['email']?.toString() ?? '',
      phoneNumber: result['phone_number']?.toString() ?? '',
      profileImage: result['profile_image']?.toString() ?? '',
      role: result['role']?.toString() ?? 'user',
      status: result['status']?.toString() ?? 'active',
    );
  }

  // ============================================================
  // SIGNUP
  // ============================================================

  Future<UserModel> signup({
    required String name,
    required String birthdate,
    required String gender,
    required String email,
    required String password,
    required String phoneNumber,
    required bool termsAccepted,
  }) async {
    final data = await _get(
      action: 'signup',
      queryParameters: {
        'name': name.trim(),
        'birthdate': birthdate,
        'gender': gender,
        'email': email.trim(),
        'password': password,
        'phone_number': phoneNumber.trim(),
        'profile_image': '',
        'terms_accepted':
        termsAccepted ? 'TRUE' : 'FALSE',
      },
    );

    _checkSuccess(data);

    final result = Map<String, dynamic>.from(
      data['data'] ?? {},
    );

    return UserModel(
      userId: result['user_id']?.toString() ?? '',
      name: result['name']?.toString() ?? name.trim(),
      birthdate: birthdate,
      gender: gender,
      email: result['email']?.toString() ?? email.trim(),
      phoneNumber: phoneNumber.trim(),
      profileImage:
      result['profile_image']?.toString() ?? '',
      role: result['role']?.toString() ?? 'user',
      status: result['status']?.toString() ?? 'active',
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final data = await _get(
      action: 'forgotPassword',
      queryParameters: {
        'email': email.trim(),
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
// RESET PASSWORD
// ============================================================

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final data = await _get(
      action: 'resetPassword',
      queryParameters: {
        'email': email.trim(),
        'otp': otp.trim(),
        'new_password': newPassword,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // GET USER
  // ============================================================

  Future<UserModel> getUser({
    required String userId,
  }) async {
    final data = await _get(
      action: 'getUser',
      queryParameters: {
        'user_id': userId,
      },
    );

    _checkSuccess(data);

    final result = Map<String, dynamic>.from(
      data['data'] ?? {},
    );

    return UserModel(
      userId: result['user_id']?.toString() ?? '',
      name: result['name']?.toString() ?? '',
      birthdate: result['birthdate']?.toString() ?? '',
      gender: result['gender']?.toString() ?? '',
      email: result['email']?.toString() ?? '',
      phoneNumber:
      result['phone_number']?.toString() ?? '',
      profileImage:
      result['profile_image']?.toString() ?? '',
      role: result['role']?.toString() ?? 'user',
      status: result['status']?.toString() ?? 'active',
    );
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String birthdate,
    required String gender,
    required String phoneNumber,
    String profileImage = '',
  }) async {
    final data = await _get(
      action: 'updateProfile',
      queryParameters: {
        'user_id': userId,
        'name': name.trim(),
        'birthdate': birthdate,
        'gender': gender,
        'phone_number': phoneNumber.trim(),
        'profile_image': profileImage,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<Map<String, dynamic>> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final data = await _get(
      action: 'changePassword',
      queryParameters: {
        'user_id': userId,
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // GET BOOKS
  // ============================================================

  Future<List<BookModel>> getBooks() async {
    final data = await _get(
      action: 'getBooks',
    );

    _checkSuccess(data);

    final List books = data['data'] ?? [];

    return books
        .map(
          (book) => BookModel.fromJson(
        Map<String, dynamic>.from(book),
      ),
    )
        .toList();
  }

  // ============================================================
  // GET SINGLE BOOK
  // ============================================================

  Future<BookModel?> getBook({
    required String bookId,
  }) async {
    final data = await _get(
      action: 'getBook',
      queryParameters: {
        'book_id': bookId,
      },
    );

    if (data['status'] != 'success') {
      return null;
    }

    final bookData = data['data'];

    if (bookData == null) {
      return null;
    }

    return BookModel.fromJson(
      Map<String, dynamic>.from(bookData),
    );
  }

  // ============================================================
  // GET CATEGORIES
  // ============================================================

  Future<List<CategoryModel>> getCategories() async {
    final data = await _get(
      action: 'getCategories',
    );

    _checkSuccess(data);

    final List categories = data['data'] ?? [];

    return categories
        .map(
          (category) => CategoryModel.fromJson(
        Map<String, dynamic>.from(category),
      ),
    )
        .toList();
  }

  // ============================================================
  // ADD TO READING LIST
  // ============================================================

  Future<Map<String, dynamic>> addToReadingList({
    required String userId,
    required String bookId,
  }) async {
    final data = await _get(
      action: 'addReadingList',
      queryParameters: {
        'user_id': userId,
        'book_id': bookId,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // REMOVE FROM READING LIST
  // ============================================================

  Future<Map<String, dynamic>> removeFromReadingList({
    required String listId,
  }) async {
    final data = await _get(
      action: 'removeReadingList',
      queryParameters: {
        'list_id': listId,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // GET READING LIST
  // ============================================================

  Future<List<ReadingListModel>> getReadingList({
    required String userId,
  }) async {
    final data = await _get(
      action: 'getReadingList',
      queryParameters: {
        'user_id': userId,
      },
    );

    _checkSuccess(data);

    final List items = data['data'] ?? [];

    return items
        .map(
          (item) => ReadingListModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  // ============================================================
  // ADD WATCHED BOOK
  // ============================================================

  Future<Map<String, dynamic>> addWatchedBook({
    required String userId,
    required String bookId,
  }) async {
    final data = await _get(
      action: 'addWatchedBook',
      queryParameters: {
        'user_id': userId,
        'book_id': bookId,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // REMOVE WATCHED BOOK
  // ============================================================

  Future<Map<String, dynamic>> removeWatchedBook({
    required String watchedId,
  }) async {
    final data = await _get(
      action: 'removeWatchedBook',
      queryParameters: {
        'watched_id': watchedId,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // GET WATCHED BOOKS
  // ============================================================

  Future<List<dynamic>> getWatchedBooks({
    required String userId,
  }) async {
    final data = await _get(
      action: 'getWatchedBooks',
      queryParameters: {
        'user_id': userId,
      },
    );

    _checkSuccess(data);

    return data['data'] ?? [];
  }

  // ============================================================
  // GET REVIEWS
  // ============================================================

  Future<List<ReviewModel>> getReviews(
      String bookId,
      ) async {
    final data = await _get(
      action: 'getReviews',
      queryParameters: {
        'book_id': bookId,
      },
    );

    _checkSuccess(data);

    final List reviews = data['data'] ?? [];

    return reviews
        .map(
          (review) => ReviewModel.fromJson(
        Map<String, dynamic>.from(review),
      ),
    )
        .toList();
  }

  // ============================================================
  // ADD REVIEW
  // ============================================================

  Future<Map<String, dynamic>> addReview({
    required String userId,
    required String bookId,
    required String rating,
    required String reviewText,
  }) async {
    final data = await _get(
      action: 'addReview',
      queryParameters: {
        'user_id': userId,
        'book_id': bookId,
        'rating': rating,
        'review_text': reviewText,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // GET SUGGESTIONS
  // ============================================================

  Future<List<dynamic>> getSuggestions({
    required String userId,
  }) async {
    final data = await _get(
      action: 'getSuggestions',
      queryParameters: {
        'user_id': userId,
      },
    );

    _checkSuccess(data);

    return data['data'] ?? [];
  }

  // ============================================================
  // CONTACT US
  // ============================================================

  Future<Map<String, dynamic>> contact({
    required String userId,
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final data = await _get(
      action: 'contact',
      queryParameters: {
        'user_id': userId,
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      },
    );

    _checkSuccess(data);

    return data;
  }

  // ============================================================
  // APP SETTINGS
  // ============================================================

  Future<List<dynamic>> getSettings() async {
    final data = await _get(
      action: 'getSettings',
    );

    _checkSuccess(data);

    return data['data'] ?? [];
  }
}