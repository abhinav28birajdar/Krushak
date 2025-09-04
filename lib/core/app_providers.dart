import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/auth_provider.dart';
import 'theme/theme_provider.dart';
import 'localization/language_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/market_provider.dart';
import 'providers/community_provider.dart';
import 'services/notification_service.dart';
import 'services/gemini_service.dart';
import 'services/supabase_service.dart';

class AppInitializationService {
  static bool _isInitialized = false;
  static String? _initializationError;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Starting app initialization...');

      // Initialize Supabase first (most critical)
      print('Initializing Supabase...');
      await SupabaseService.initialize();

      // Wait a moment for Supabase to be fully ready
      await Future.delayed(const Duration(milliseconds: 500));

      print('Initializing other services...');

      // Initialize Gemini AI with auto-analysis
      GeminiAIService.initialize();

      // Initialize notification service with weather alerts
      NotificationService.initialize();

      // Initialize market data service
      MarketDataService.initialize();

      // Initialize community service
      CommunityService.initialize();

      _isInitialized = true;
      _initializationError = null;
      print('All services initialized successfully');
    } catch (e) {
      _initializationError = e.toString();
      print('Error initializing services: $e');
      throw Exception('Failed to initialize app services: $e');
    }
  }

  static Future<void> dispose() async {
    try {
      GeminiAIService.dispose();
      NotificationService.dispose();
      MarketDataService.dispose();
      CommunityService.dispose();

      _isInitialized = false;
      print('All services disposed successfully');
    } catch (e) {
      print('Error disposing services: $e');
    }
  }

  static bool get isInitialized => _isInitialized;
  static String? get initializationError => _initializationError;
}

// Combined app state provider
class AppState {
  final UserState? user;
  final AppThemeMode themeMode;
  final AppLanguage language;
  final bool isLoading;
  final String? error;

  AppState({
    this.user,
    required this.themeMode,
    required this.language,
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    UserState? user,
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      user: user ?? this.user,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
    : super(
        AppState(
          themeMode: AppThemeMode.light,
          language: AppLanguage.english,
          isLoading: true,
        ),
      ) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Wait for app initialization to complete
      await AppInitializationService.initialize();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize app: ${e.toString()}',
      );
    }
  }

  void updateTheme(AppThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  void updateLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
  }

  void updateUser(UserState? user) {
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Main app state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

// Derived providers for easy access
final currentUserProvider = Provider<UserState?>((ref) {
  return ref.watch(appStateProvider).user;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

final appErrorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).error;
});

// Real-time data aggregation provider
final dashboardDataProvider = Provider<Map<String, dynamic>>((ref) {
  final weather = ref.watch(weatherProvider);
  final marketData = ref.watch(marketDataProvider);
  final notifications = ref.watch(notificationProvider);
  final unreadCount = ref.watch(unreadNotificationCountProvider);
  final user = ref.watch(currentUserProvider);

  return {
    'weather': weather,
    'marketData': marketData.take(5).toList(), // Top 5 market items
    'notifications': notifications.take(3).toList(), // Recent 3 notifications
    'unreadNotifications': unreadCount,
    'user': user,
    'lastUpdated': DateTime.now(),
  };
});

// Real-time connectivity provider
final connectivityProvider = StateProvider<bool>((ref) => true);

// App configuration provider
final appConfigProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'version': '1.0.0',
    'buildNumber': '1',
    'environment': 'production',
    'apiEndpoint': 'https://api.krushak.com',
    'supportEmail': 'support@krushak.com',
    'supportPhone': '+91-1800-123-4567',
    'features': {
      'realTimeWeather': true,
      'marketUpdates': true,
      'communityChat': true,
      'aiAnalysis': true,
      'bankLoans': true,
      'notifications': true,
      'multiLanguage': true,
      'darkMode': true,
    },
  };
});

// Real-time farm overview provider
final farmOverviewProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(currentUserProvider);
  final weather = ref.watch(weatherProvider);
  final marketSummary = ref.watch(marketSummaryProvider);

  if (user == null) {
    return {
      'totalAcres': 0.0,
      'cropsCount': 0,
      'weatherStatus': 'Unknown',
      'marketTrend': 'Unknown',
      'todaysTasks': [],
      'alerts': [],
    };
  }

  return {
    'totalAcres': user.profile?['acres'] ?? 0.0,
    'cropsCount': (user.profile?['crops'] as List?)?.length ?? 0,
    'weatherStatus': weather?.condition ?? 'Loading...',
    'marketTrend': marketSummary['rising'] > marketSummary['falling']
        ? 'Positive'
        : 'Negative',
    'todaysTasks': [
      'Check irrigation systems',
      'Monitor crop health',
      'Review market prices',
      'Plan field activities',
    ],
    'alerts': [
      if (weather?.temperature != null && weather!.temperature > 35)
        'High temperature alert - ${weather.temperature}°C',
      if (marketSummary['rising'] > 5) 'Multiple crops showing price increase',
    ],
  };
});

// Analytics provider for tracking user engagement
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, Map<String, dynamic>>((ref) {
      return AnalyticsNotifier();
    });

class AnalyticsNotifier extends StateNotifier<Map<String, dynamic>> {
  AnalyticsNotifier()
    : super({
        'appOpens': 0,
        'weatherChecks': 0,
        'marketViews': 0,
        'messagesExchanged': 0,
        'loansViewed': 0,
        'lastActiveDate': DateTime.now().toIso8601String(),
      });

  void trackAppOpen() {
    state = {
      ...state,
      'appOpens': (state['appOpens'] ?? 0) + 1,
      'lastActiveDate': DateTime.now().toIso8601String(),
    };
  }

  void trackWeatherCheck() {
    state = {...state, 'weatherChecks': (state['weatherChecks'] ?? 0) + 1};
  }

  void trackMarketView() {
    state = {...state, 'marketViews': (state['marketViews'] ?? 0) + 1};
  }

  void trackMessageSent() {
    state = {
      ...state,
      'messagesExchanged': (state['messagesExchanged'] ?? 0) + 1,
    };
  }

  void trackLoanView() {
    state = {...state, 'loansViewed': (state['loansViewed'] ?? 0) + 1};
  }
}

// Performance monitoring provider
final performanceProvider =
    StateNotifierProvider<PerformanceNotifier, Map<String, dynamic>>((ref) {
      return PerformanceNotifier();
    });

class PerformanceNotifier extends StateNotifier<Map<String, dynamic>> {
  PerformanceNotifier()
    : super({
        'loadTimes': <String, int>{},
        'apiCalls': 0,
        'errors': 0,
        'lastSync': DateTime.now().toIso8601String(),
      });

  void recordLoadTime(String screen, int milliseconds) {
    final loadTimes = Map<String, int>.from(state['loadTimes'] ?? {});
    loadTimes[screen] = milliseconds;

    state = {...state, 'loadTimes': loadTimes};
  }

  void incrementApiCalls() {
    state = {...state, 'apiCalls': (state['apiCalls'] ?? 0) + 1};
  }

  void recordError() {
    state = {...state, 'errors': (state['errors'] ?? 0) + 1};
  }

  void updateSyncTime() {
    state = {...state, 'lastSync': DateTime.now().toIso8601String()};
  }
}
