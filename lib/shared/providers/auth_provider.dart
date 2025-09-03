import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref
      .watch(authStateProvider)
      .maybeWhen(data: (user) => user, orElse: () => null);
});

/// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Authentication Service Class
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone_number': phoneNumber},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with phone number (OTP)
  Future<void> signInWithPhoneOtp({required String phoneNumber}) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
