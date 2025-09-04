import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';

enum NotificationType { weather, market, crop, system, alert }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  static AppNotification fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }
}

class NotificationService {
  static Timer? _weatherCheckTimer;
  static Timer? _marketCheckTimer;
  static String? _currentWeatherApiKey;
  static String? _currentGeminiApiKey;

  static void initialize() {
    _currentWeatherApiKey = const String.fromEnvironment(
      'WEATHER_API_KEY',
      defaultValue: 'demo_key',
    );
    _currentGeminiApiKey = const String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: 'demo_key',
    );

    // Start periodic weather monitoring
    _weatherCheckTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _checkWeatherAlerts(),
    );

    // Start periodic market monitoring
    _marketCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _checkMarketUpdates(),
    );

    // Initial check
    _checkWeatherAlerts();
    _checkMarketUpdates();
  }

  static void dispose() {
    _weatherCheckTimer?.cancel();
    _marketCheckTimer?.cancel();
  }

  static Future<void> _checkWeatherAlerts() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;

      final userProfile = await SupabaseService.getCurrentUser();
      if (userProfile == null || userProfile['location'] == null) return;

      final location = userProfile['location'];
      final weatherData = await _fetchWeatherData(location);

      if (weatherData != null) {
        await _analyzeWeatherAndNotify(weatherData, user.id);
      }
    } catch (e) {
      print('Error checking weather alerts: $e');
    }
  }

  static Future<Map<String, dynamic>?> _fetchWeatherData(
    String location,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$_currentWeatherApiKey&units=metric',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
    return null;
  }

  static Future<void> _analyzeWeatherAndNotify(
    Map<String, dynamic> weatherData,
    String userId,
  ) async {
    try {
      final temperature = weatherData['main']['temp']?.toDouble() ?? 0.0;
      final humidity = weatherData['main']['humidity']?.toDouble() ?? 0.0;
      final windSpeed = weatherData['wind']['speed']?.toDouble() ?? 0.0;
      final weatherCondition = weatherData['weather'][0]['main'] ?? '';
      final description = weatherData['weather'][0]['description'] ?? '';

      List<AppNotification> notifications = [];

      // High temperature alert
      if (temperature > 35) {
        final aiAnalysis = await _getWeatherAIAnalysis(
          temperature,
          humidity,
          windSpeed,
          weatherCondition,
        );
        notifications.add(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '🌡️ High Temperature Alert',
            message:
                'Temperature is ${temperature.toStringAsFixed(1)}°C. $aiAnalysis',
            type: NotificationType.weather,
            timestamp: DateTime.now(),
            data: {'temperature': temperature, 'recommendation': aiAnalysis},
          ),
        );
      }

      // Heavy rain alert
      if (weatherCondition.toLowerCase().contains('rain') &&
          description.contains('heavy')) {
        final aiAnalysis = await _getRainAIAnalysis(description, windSpeed);
        notifications.add(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '🌧️ Heavy Rain Alert',
            message: 'Heavy rainfall expected. $aiAnalysis',
            type: NotificationType.weather,
            timestamp: DateTime.now(),
            data: {'condition': weatherCondition, 'recommendation': aiAnalysis},
          ),
        );
      }

      // Drought warning
      if (humidity < 30 && temperature > 30) {
        final aiAnalysis = await _getDroughtAIAnalysis(humidity, temperature);
        notifications.add(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '🏜️ Drought Warning',
            message:
                'Low humidity (${humidity.toStringAsFixed(1)}%) detected. $aiAnalysis',
            type: NotificationType.alert,
            timestamp: DateTime.now(),
            data: {
              'humidity': humidity,
              'temperature': temperature,
              'recommendation': aiAnalysis,
            },
          ),
        );
      }

      // Save notifications to database
      for (final notification in notifications) {
        await _saveNotification(notification, userId);
      }
    } catch (e) {
      print('Error analyzing weather: $e');
    }
  }

  static Future<String> _getWeatherAIAnalysis(
    double temp,
    double humidity,
    double windSpeed,
    String condition,
  ) async {
    try {
      final prompt =
          '''
      Analyze the current weather conditions for farmers and provide specific recommendations:
      Temperature: ${temp}°C
      Humidity: ${humidity}%
      Wind Speed: ${windSpeed} m/s
      Condition: $condition
      
      Provide brief, actionable advice for crop protection and farming activities in 50 words or less.
      ''';

      final response = await GeminiAIService.analyzeWithPrompt(prompt);
      return response ??
          'Protect crops from extreme heat. Ensure adequate irrigation.';
    } catch (e) {
      return 'Protect crops from extreme heat. Ensure adequate irrigation.';
    }
  }

  static Future<String> _getRainAIAnalysis(
    String description,
    double windSpeed,
  ) async {
    try {
      final prompt =
          '''
      Heavy rain is expected with conditions: $description
      Wind speed: $windSpeed m/s
      
      Provide specific farming recommendations for heavy rain protection in 50 words or less.
      ''';

      final response = await GeminiAIService.analyzeWithPrompt(prompt);
      return response ??
          'Ensure proper drainage. Protect crops from waterlogging.';
    } catch (e) {
      return 'Ensure proper drainage. Protect crops from waterlogging.';
    }
  }

  static Future<String> _getDroughtAIAnalysis(
    double humidity,
    double temperature,
  ) async {
    try {
      final prompt =
          '''
      Drought conditions detected:
      Humidity: ${humidity}%
      Temperature: ${temperature}°C
      
      Provide water conservation and crop protection advice in 50 words or less.
      ''';

      final response = await GeminiAIService.analyzeWithPrompt(prompt);
      return response ??
          'Implement water conservation. Use mulching techniques.';
    } catch (e) {
      return 'Implement water conservation. Use mulching techniques.';
    }
  }

  static Future<void> _checkMarketUpdates() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;

      // Get market prices and analyze significant changes
      final marketAnalysis = await _getMarketPriceAnalysis();

      if (marketAnalysis.isNotEmpty) {
        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '💰 Market Price Update',
          message: marketAnalysis,
          type: NotificationType.market,
          timestamp: DateTime.now(),
        );

        await _saveNotification(notification, user.id);
      }
    } catch (e) {
      print('Error checking market updates: $e');
    }
  }

  static Future<String> _getMarketPriceAnalysis() async {
    try {
      final prompt = '''
      Analyze current agricultural market trends and provide a brief update for farmers.
      Focus on major crop prices, seasonal trends, and market opportunities.
      Provide actionable insights in 60 words or less.
      ''';

      final response = await GeminiAIService.analyzeWithPrompt(prompt);
      return response ??
          'Check current market prices for better selling opportunities.';
    } catch (e) {
      return 'Check current market prices for better selling opportunities.';
    }
  }

  static Future<void> _saveNotification(
    AppNotification notification,
    String userId,
  ) async {
    try {
      await SupabaseService.client.from('notifications').insert({
        'id': notification.id,
        'user_id': userId,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type.name,
        'read': notification.isRead,
        'data': notification.data,
        'created_at': notification.timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  static Future<List<AppNotification>> getUserNotifications(
    String userId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<int> getUnreadCount(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select('count')
          .eq('user_id', userId)
          .eq('read', false);

      return response.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super([]) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      final notifications = await NotificationService.getUserNotifications(
        user.id,
      );
      state = notifications;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await NotificationService.markAsRead(notificationId);
    state = state
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
      return NotificationNotifier();
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications.where((n) => !n.isRead).length;
});
