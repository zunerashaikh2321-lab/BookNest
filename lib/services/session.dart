import '../models/user_model.dart';

class Session {
  static UserModel? currentUser;

  static bool get isLoggedIn => currentUser != null;

  static void start(UserModel user) {
    currentUser = user;
  }

  static void clear() {
    currentUser = null;
  }
}
