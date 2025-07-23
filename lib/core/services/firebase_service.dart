import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_manager/firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  /// Initialize Firebase and return true if successful
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (_isInitializing) {
      // Wait for ongoing initialization
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }

    _isInitializing = true;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');

      // Test Firebase Auth
      try {
        // final auth = FirebaseAuth.instance;
      } catch (e) {
        _isInitializing = false;
        return false;
      }

      _isInitialized = true;
      _isInitializing = false;
      return true;
    } catch (e) {
      _isInitializing = false;
      return false;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;

  /// Get Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Wait for Firebase to be initialized
  static Future<void> waitForInitialization({Duration timeout = const Duration(seconds: 10)}) async {
    final startTime = DateTime.now();
    while (!_isInitialized) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw Exception('Firebase initialization timeout after ${timeout.inSeconds} seconds');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
