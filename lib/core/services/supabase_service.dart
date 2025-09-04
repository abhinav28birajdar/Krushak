import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final supabaseUrl =
          dotenv.env['SUPABASE_URL'] ??
          const String.fromEnvironment('SUPABASE_URL');
      final supabaseAnonKey =
          dotenv.env['SUPABASE_ANON_KEY'] ??
          const String.fromEnvironment('SUPABASE_ANON_KEY');

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
          'Supabase URL and Anon Key are required. Please check your .env file.',
        );
      }

      print('Initializing Supabase with URL: $supabaseUrl');

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      _client = Supabase.instance.client;
      _isInitialized = true;

      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // User Management
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final response = await client
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single();

    return response;
  }

  static Future<void> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await client.from('users').upsert({
      'id': user.id,
      'email': user.email,
      ...profileData,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Farm Management
  static Future<List<Map<String, dynamic>>> getUserFarms() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('farms')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addFarm(Map<String, dynamic> farmData) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await client.from('farms').insert({
      'user_id': user.id,
      ...farmData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateFarm(
    String farmId,
    Map<String, dynamic> farmData,
  ) async {
    await client
        .from('farms')
        .update({...farmData, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', farmId);
  }

  // Crop Management
  static Future<List<Map<String, dynamic>>> getFarmCrops(String farmId) async {
    final response = await client
        .from('crops')
        .select('*')
        .eq('farm_id', farmId)
        .order('planted_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addCrop(Map<String, dynamic> cropData) async {
    await client.from('crops').insert({
      ...cropData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Financial Management
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('financial_records')
        .select('*')
        .eq('user_id', user.id)
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addFinancialRecord(
    Map<String, dynamic> recordData,
  ) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await client.from('financial_records').insert({
      'user_id': user.id,
      ...recordData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Orders Management
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('orders')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createOrder(Map<String, dynamic> orderData) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await client.from('orders').insert({
      'user_id': user.id,
      ...orderData,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('notifications')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(50);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await client
        .from('notifications')
        .update({'read': true})
        .eq('id', notificationId);
  }

  // Announcements
  static Future<List<Map<String, dynamic>>> getActiveAnnouncements() async {
    final response = await client
        .from('announcements')
        .select('*')
        .eq('active', true)
        .order('priority', ascending: false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await client
        .from('announcements')
        .select('*')
        .eq('active', true)
        .order('priority', ascending: false)
        .order('created_at', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addAnnouncement(
    Map<String, dynamic> announcementData,
  ) async {
    await client.from('announcements').insert({
      ...announcementData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Additional Crop Management
  static Future<List<Map<String, dynamic>>> getUserCrops() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    final response = await client
        .from('crops')
        .select('*, farms!inner(*)')
        .eq('farms.user_id', user.id)
        .order('planted_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Additional Farm Management
  static Future<void> deleteFarm(String farmId) async {
    await client.from('farms').delete().eq('id', farmId);
  }

  // Additional Financial Management
  static Future<void> deleteFinancialRecord(String recordId) async {
    await client.from('financial_records').delete().eq('id', recordId);
  }

  static Future<void> updateFinancialRecord(
    String recordId,
    Map<String, dynamic> recordData,
  ) async {
    await client
        .from('financial_records')
        .update({...recordData, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', recordId);
  }
}
