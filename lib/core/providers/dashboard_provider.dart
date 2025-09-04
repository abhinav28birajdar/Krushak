// Real-time Dashboard Provider for Krushak Home Screen
// This provider aggregates all real-time data needed for the dashboard
// and ensures live updates from Supabase subscriptions

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_provider.dart';
import '../services/supabase_service.dart';
import '../providers/weather_provider.dart';
import '../providers/market_provider.dart';

// Dashboard data model
class DashboardData {
  final Map<String, dynamic>? weather;
  final List<Map<String, dynamic>> marketPrices;
  final List<Map<String, dynamic>> announcements;
  final List<Map<String, dynamic>> farmCrops;
  final List<Map<String, dynamic>> recentMessages;
  final int unreadNotifications;
  final Map<String, dynamic>? aiInsights;
  final bool isLoading;
  final String? error;

  const DashboardData({
    this.weather,
    this.marketPrices = const [],
    this.announcements = const [],
    this.farmCrops = const [],
    this.recentMessages = const [],
    this.unreadNotifications = 0,
    this.aiInsights,
    this.isLoading = false,
    this.error,
  });

  DashboardData copyWith({
    Map<String, dynamic>? weather,
    List<Map<String, dynamic>>? marketPrices,
    List<Map<String, dynamic>>? announcements,
    List<Map<String, dynamic>>? farmCrops,
    List<Map<String, dynamic>>? recentMessages,
    int? unreadNotifications,
    Map<String, dynamic>? aiInsights,
    bool? isLoading,
    String? error,
  }) {
    return DashboardData(
      weather: weather ?? this.weather,
      marketPrices: marketPrices ?? this.marketPrices,
      announcements: announcements ?? this.announcements,
      farmCrops: farmCrops ?? this.farmCrops,
      recentMessages: recentMessages ?? this.recentMessages,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      aiInsights: aiInsights ?? this.aiInsights,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Dashboard notifier
class DashboardNotifier extends StateNotifier<DashboardData> {
  DashboardNotifier(this._ref) : super(const DashboardData(isLoading: true)) {
    _initialize();
  }

  final Ref _ref;
  RealtimeChannel? _announcementsChannel;
  RealtimeChannel? _farmCropsChannel;
  RealtimeChannel? _notificationsChannel;

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load initial data
      await _loadInitialData();

      // Set up real-time subscriptions
      await _setupRealtimeSubscriptions();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize dashboard: $e',
      );
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Load announcements
      final announcements = await SupabaseService.getActiveAnnouncements();

      // Load farm crops if user is authenticated
      final authState = _ref.read(authProvider);
      List<Map<String, dynamic>> farmCrops = [];

      if (authState.isAuthenticated && authState.profile != null) {
        final farms = await SupabaseService.getUserFarms();
        if (farms.isNotEmpty) {
          farmCrops = await SupabaseService.getFarmCrops(farms.first['id']);
        }
      }

      // Load recent community messages
      final recentMessages = <Map<String, dynamic>>[];

      // Load unread notifications count
      final unreadCount = await _getUnreadNotificationsCount();

      state = state.copyWith(
        announcements: announcements,
        farmCrops: farmCrops,
        recentMessages: recentMessages,
        unreadNotifications: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load initial data: $e');
    }
  }

  Future<void> _setupRealtimeSubscriptions() async {
    if (!SupabaseService.isInitialized) return;

    final supabase = SupabaseService.client;
    final authState = _ref.read(authProvider);

    // Subscribe to announcements
    _announcementsChannel = supabase
        .channel('dashboard_announcements')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'announcements',
          callback: (payload) async {
            await _loadAnnouncements();
          },
        )
        .subscribe();

    // Subscribe to farm crops if authenticated
    if (authState.isAuthenticated && authState.profile != null) {
      _farmCropsChannel = supabase
          .channel('dashboard_farm_crops')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'farm_crops',
            callback: (payload) async {
              await _loadFarmCrops();
            },
          )
          .subscribe();

      // Subscribe to notifications
      _notificationsChannel = supabase
          .channel('dashboard_notifications')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: authState.user!.id,
            ),
            callback: (payload) async {
              final unreadCount = await _getUnreadNotificationsCount();
              state = state.copyWith(unreadNotifications: unreadCount);
            },
          )
          .subscribe();
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final announcements = await SupabaseService.getActiveAnnouncements();
      state = state.copyWith(announcements: announcements);
    } catch (e) {
      // Silently handle real-time update errors
    }
  }

  Future<void> _loadFarmCrops() async {
    try {
      final authState = _ref.read(authProvider);
      if (authState.isAuthenticated) {
        final farms = await SupabaseService.getUserFarms();
        if (farms.isNotEmpty) {
          final farmCrops = await SupabaseService.getFarmCrops(
            farms.first['id'],
          );
          state = state.copyWith(farmCrops: farmCrops);
        }
      }
    } catch (e) {
      // Silently handle real-time update errors
    }
  }

  Future<int> _getUnreadNotificationsCount() async {
    try {
      final authState = _ref.read(authProvider);
      if (!authState.isAuthenticated) return 0;

      final result = await SupabaseService.client
          .from('notifications')
          .select('id')
          .eq('user_id', authState.user!.id)
          .eq('read', false)
          .count();

      return result.count;
    } catch (e) {
      return 0;
    }
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _announcementsChannel?.unsubscribe();
    _farmCropsChannel?.unsubscribe();
    _notificationsChannel?.unsubscribe();
    super.dispose();
  }
}

// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardData>((ref) {
      return DashboardNotifier(ref);
    });

// Helper providers for individual data streams
final dashboardWeatherProvider = Provider<Map<String, dynamic>?>((ref) {
  final weather = ref.watch(weatherProvider);
  return weather?.toJson();
});

final dashboardMarketProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final marketData = ref.watch(marketDataProvider);
  return marketData
      .take(5)
      .map(
        (price) => {
          'commodity': price.cropName,
          'current_price': price.price,
          'price_change': price.changePercentage,
          'trend': price.trend,
        },
      )
      .toList();
});

final dashboardAnnouncementsProvider = Provider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.watch(dashboardProvider).announcements;
});

final dashboardUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(dashboardProvider).unreadNotifications;
});
