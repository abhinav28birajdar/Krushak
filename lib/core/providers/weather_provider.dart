import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';

class WeatherData {
  final String location;
  final String locationName;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String icon;
  final DateTime timestamp;
  final String aiRecommendation;
  final List<WeatherForecast> forecast;

  WeatherData({
    required this.location,
    required this.locationName,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.icon,
    required this.timestamp,
    this.aiRecommendation = '',
    this.forecast = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'locationName': locationName,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'condition': condition,
      'description': description,
      'icon': icon,
      'timestamp': timestamp.toIso8601String(),
      'aiRecommendation': aiRecommendation,
      'forecast': forecast.map((f) => f.toJson()).toList(),
    };
  }

  static WeatherData fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? '',
      locationName: json['locationName'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      aiRecommendation: json['aiRecommendation'] ?? '',
      forecast: (json['forecast'] as List? ?? [])
          .map((f) => WeatherForecast.fromJson(f))
          .toList(),
    );
  }
}

class WeatherForecast {
  final DateTime date;
  final double temperature;
  final String condition;
  final String description;
  final String icon;
  final double humidity;

  WeatherForecast({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.humidity,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'temperature': temperature,
      'condition': condition,
      'description': description,
      'icon': icon,
      'humidity': humidity,
    };
  }

  static WeatherForecast fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date']),
      temperature: (json['temperature'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      humidity: (json['humidity'] ?? 0).toDouble(),
    );
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: 'demo_key',
  );

  static Future<WeatherData?> getCurrentWeather(String location) async {
    try {
      // Get current weather
      final currentResponse = await http.get(
        Uri.parse('$_baseUrl/weather?q=$location&appid=$_apiKey&units=metric'),
        headers: {'Content-Type': 'application/json'},
      );

      if (currentResponse.statusCode != 200) {
        throw Exception('Failed to fetch weather data');
      }

      final currentData = json.decode(currentResponse.body);

      // Get forecast
      final forecastResponse = await http.get(
        Uri.parse('$_baseUrl/forecast?q=$location&appid=$_apiKey&units=metric'),
        headers: {'Content-Type': 'application/json'},
      );

      List<WeatherForecast> forecast = [];
      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body);
        final List<dynamic> forecastList = forecastData['list'] ?? [];

        forecast = forecastList.take(5).map((item) {
          return WeatherForecast(
            date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
            temperature: (item['main']['temp'] ?? 0).toDouble(),
            condition: item['weather'][0]['main'] ?? '',
            description: item['weather'][0]['description'] ?? '',
            icon: item['weather'][0]['icon'] ?? '',
            humidity: (item['main']['humidity'] ?? 0).toDouble(),
          );
        }).toList();
      }

      // Get AI recommendation
      final aiRecommendation = await _getAIWeatherRecommendation(
        currentData['main']['temp']?.toDouble() ?? 0,
        currentData['main']['humidity']?.toDouble() ?? 0,
        currentData['wind']['speed']?.toDouble() ?? 0,
        currentData['weather'][0]['main'] ?? '',
        currentData['weather'][0]['description'] ?? '',
      );

      return WeatherData(
        location: location,
        locationName: currentData['name'] ?? location,
        temperature: (currentData['main']['temp'] ?? 0).toDouble(),
        humidity: (currentData['main']['humidity'] ?? 0).toDouble(),
        windSpeed: (currentData['wind']['speed'] ?? 0).toDouble(),
        condition: currentData['weather'][0]['main'] ?? '',
        description: currentData['weather'][0]['description'] ?? '',
        icon: currentData['weather'][0]['icon'] ?? '',
        timestamp: DateTime.now(),
        aiRecommendation: aiRecommendation,
        forecast: forecast,
      );
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    }
  }

  static Future<String> _getAIWeatherRecommendation(
    double temperature,
    double humidity,
    double windSpeed,
    String condition,
    String description,
  ) async {
    try {
      final prompt =
          '''
      Current Weather Analysis for Farmers:
      Temperature: ${temperature}°C
      Humidity: ${humidity}%
      Wind Speed: ${windSpeed} m/s
      Condition: $condition
      Description: $description
      
      Provide specific farming recommendations based on these weather conditions:
      1. Crop protection advice
      2. Irrigation recommendations
      3. Best farming activities for today
      4. Any weather-related precautions
      
      Keep response under 150 words and make it actionable for farmers.
      ''';

      final response = await GeminiAIService.analyzeWithPrompt(prompt);
      return response ?? _getDefaultRecommendation(temperature, condition);
    } catch (e) {
      return _getDefaultRecommendation(temperature, condition);
    }
  }

  static String _getDefaultRecommendation(
    double temperature,
    String condition,
  ) {
    if (temperature > 35) {
      return 'High temperature detected. Increase irrigation frequency and provide shade for sensitive crops.';
    } else if (condition.toLowerCase().contains('rain')) {
      return 'Rain expected. Check drainage systems and protect crops from waterlogging.';
    } else if (temperature < 10) {
      return 'Low temperature. Protect crops from frost and reduce watering.';
    } else {
      return 'Good weather conditions for most farming activities.';
    }
  }

  static Future<WeatherData?> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch weather data');
      }

      final data = json.decode(response.body);

      final aiRecommendation = await _getAIWeatherRecommendation(
        data['main']['temp']?.toDouble() ?? 0,
        data['main']['humidity']?.toDouble() ?? 0,
        data['wind']['speed']?.toDouble() ?? 0,
        data['weather'][0]['main'] ?? '',
        data['weather'][0]['description'] ?? '',
      );

      return WeatherData(
        location: '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}',
        locationName: data['name'] ?? 'Current Location',
        temperature: (data['main']['temp'] ?? 0).toDouble(),
        humidity: (data['main']['humidity'] ?? 0).toDouble(),
        windSpeed: (data['wind']['speed'] ?? 0).toDouble(),
        condition: data['weather'][0]['main'] ?? '',
        description: data['weather'][0]['description'] ?? '',
        icon: data['weather'][0]['icon'] ?? '',
        timestamp: DateTime.now(),
        aiRecommendation: aiRecommendation,
      );
    } catch (e) {
      print('Error fetching weather by coordinates: $e');
      return null;
    }
  }
}

class WeatherNotifier extends StateNotifier<WeatherData?> {
  Timer? _updateTimer;

  WeatherNotifier() : super(null) {
    _loadWeatherData();
    // Update weather every 10 minutes
    _updateTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _loadWeatherData(),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;

      final userProfile = await SupabaseService.getCurrentUser();
      if (userProfile != null && userProfile['location'] != null) {
        final location = userProfile['location'] as String;
        final weatherData = await WeatherService.getCurrentWeather(location);

        if (weatherData != null) {
          state = weatherData;
          await _saveWeatherData(weatherData, user.id);
        }
      }
    } catch (e) {
      print('Error loading weather data: $e');
    }
  }

  Future<void> updateLocation(String location) async {
    try {
      final weatherData = await WeatherService.getCurrentWeather(location);
      if (weatherData != null) {
        state = weatherData;

        final user = SupabaseService.client.auth.currentUser;
        if (user != null) {
          await _saveWeatherData(weatherData, user.id);

          // Update user location
          await SupabaseService.client
              .from('users')
              .update({'location': location})
              .eq('id', user.id);
        }
      }
    } catch (e) {
      print('Error updating weather location: $e');
    }
  }

  Future<void> updateByCoordinates(double lat, double lon) async {
    try {
      final weatherData = await WeatherService.getWeatherByCoordinates(
        lat,
        lon,
      );
      if (weatherData != null) {
        state = weatherData;

        final user = SupabaseService.client.auth.currentUser;
        if (user != null) {
          await _saveWeatherData(weatherData, user.id);
        }
      }
    } catch (e) {
      print('Error updating weather by coordinates: $e');
    }
  }

  Future<void> _saveWeatherData(WeatherData weatherData, String userId) async {
    try {
      await SupabaseService.client.from('weather_data').upsert({
        'user_id': userId,
        'location': weatherData.location,
        'location_name': weatherData.locationName,
        'temperature': weatherData.temperature,
        'humidity': weatherData.humidity,
        'wind_speed': weatherData.windSpeed,
        'condition': weatherData.condition,
        'description': weatherData.description,
        'icon': weatherData.icon,
        'ai_recommendation': weatherData.aiRecommendation,
        'updated_at': weatherData.timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Error saving weather data: $e');
    }
  }

  Future<void> refresh() async {
    await _loadWeatherData();
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherData?>((
  ref,
) {
  return WeatherNotifier();
});

final weatherLocationProvider = Provider<String>((ref) {
  final weather = ref.watch(weatherProvider);
  return weather?.locationName ?? 'Unknown Location';
});

final weatherTemperatureProvider = Provider<String>((ref) {
  final weather = ref.watch(weatherProvider);
  if (weather == null) return '--°C';
  return '${weather.temperature.toStringAsFixed(1)}°C';
});

final weatherConditionProvider = Provider<String>((ref) {
  final weather = ref.watch(weatherProvider);
  return weather?.condition ?? 'Unknown';
});

final weatherRecommendationProvider = Provider<String>((ref) {
  final weather = ref.watch(weatherProvider);
  return weather?.aiRecommendation ?? 'Loading weather recommendations...';
});
