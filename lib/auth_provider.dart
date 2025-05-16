import 'package:flutter/material.dart';
import 'firestore_functions.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _walletAddress = '';

  bool get isLoggedIn => _isLoggedIn;
  String get walletAddress => _walletAddress;

  // Call this method when the user logs in.
  Future<void> login(String walletAddress) async {
    _isLoggedIn = true;
    _walletAddress = walletAddress;

    solflareWalletConnected(walletAddress);

    notifyListeners(); // Notify listeners that the state has changed.
  }

  // Call this method when the user logs out.
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}