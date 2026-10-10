import 'package:flutter/foundation.dart';

/// Temporary role session for the UI prototype. Replace this with Member 2's
/// authentication provider before merging the final application.
class AuthPrototypeStore extends ChangeNotifier {
  AuthPrototypeStore._();
  static final AuthPrototypeStore instance = AuthPrototypeStore._();

  static const _accounts = <String, ({String password, String role})>{
    'admin@mtalchemy.demo': (password: 'AlchemyAdmin!26', role: 'Admin'),
    'employer@mtalchemy.demo': (
      password: 'AlchemyEmployer!26',
      role: 'Employer',
    ),
    'trainer@mtalchemy.demo': (password: 'AlchemyTrainer!26', role: 'Trainer'),
    'learner@mtalchemy.demo': (password: 'AlchemyLearner!26', role: 'Learner'),
  };

  String? _email;
  String? _role;
  String? get email => _email;
  String? get role => _role;
  bool get isSignedIn => _email != null;

  String? signIn(String email, String password) {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) return null;
    _email = email.trim().toLowerCase();
    _role = account.role;
    notifyListeners();
    return account.role;
  }

  bool hasRole(String role) => _role == role;

  void signOut() {
    _email = null;
    _role = null;
    notifyListeners();
  }
}
