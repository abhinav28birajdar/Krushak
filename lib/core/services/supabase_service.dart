import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late SupabaseClient _client;

  static SupabaseClient get client => _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://your-project-url.supabase.co',
      ),
      anonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'your-anon-key',
      ),
    );
    _client = Supabase.instance.client;
  }

  // User Management
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single();

    return response;
  }

  static Future<void> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _client.from('users').upsert({
      'id': user.id,
      'email': user.email,
      ...profileData,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Farm Management
  static Future<List<Map<String, dynamic>>> getUserFarms() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('farms')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addFarm(Map<String, dynamic> farmData) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _client.from('farms').insert({
      'user_id': user.id,
      ...farmData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateFarm(
    String farmId,
    Map<String, dynamic> farmData,
  ) async {
    await _client
        .from('farms')
        .update({...farmData, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', farmId);
  }

  // Crop Management
  static Future<List<Map<String, dynamic>>> getFarmCrops(String farmId) async {
    final response = await _client
        .from('crops')
        .select('*')
        .eq('farm_id', farmId)
        .order('planted_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addCrop(Map<String, dynamic> cropData) async {
    await _client.from('crops').insert({
      ...cropData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Financial Management
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('financial_records')
        .select('*')
        .eq('user_id', user.id)
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addFinancialRecord(
    Map<String, dynamic> recordData,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _client.from('financial_records').insert({
      'user_id': user.id,
      ...recordData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Orders Management
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('orders')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createOrder(Map<String, dynamic> orderData) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _client.from('orders').insert({
      'user_id': user.id,
      ...orderData,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('notifications')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(50);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'read': true})
        .eq('id', notificationId);
  }

  // Announcements
  static Future<List<Map<String, dynamic>>> getActiveAnnouncements() async {
    final response = await _client
        .from('announcements')
        .select('*')
        .eq('active', true)
        .order('priority', ascending: false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await _client
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
    await _client.from('announcements').insert({
      ...announcementData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Additional Crop Management
  static Future<List<Map<String, dynamic>>> getUserCrops() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('crops')
        .select('*, farms!inner(*)')
        .eq('farms.user_id', user.id)
        .order('planted_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Additional Farm Management
  static Future<void> deleteFarm(String farmId) async {
    await _client.from('farms').delete().eq('id', farmId);
  }

  // Additional Financial Management
  static Future<void> deleteFinancialRecord(String recordId) async {
    await _client.from('financial_records').delete().eq('id', recordId);
  }

  static Future<void> updateFinancialRecord(
    String recordId,
    Map<String, dynamic> recordData,
  ) async {
    await _client
        .from('financial_records')
        .update({...recordData, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', recordId);
  }
}
