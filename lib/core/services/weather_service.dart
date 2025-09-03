import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with actual API key

  static Future<Map<String, dynamic>> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Return mock data for demo purposes
        return _getMockWeatherData();
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockWeatherData();
    }
  }

  static Future<List<Map<String, dynamic>>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['list']);
      } else {
        // Return mock data for demo purposes
        return _getMockForecastData();
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockForecastData();
    }
  }

  static Map<String, dynamic> _getMockWeatherData() {
    return {
      'main': {
        'temp': 24.5,
        'feels_like': 26.2,
        'humidity': 68,
        'pressure': 1013,
      },
      'weather': [
        {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'},
      ],
      'wind': {'speed': 3.2, 'deg': 120},
      'visibility': 10000,
      'name': 'Delhi',
    };
  }

  static List<Map<String, dynamic>> _getMockForecastData() {
    return [
      {
        'dt':
            DateTime.now()
                .add(const Duration(days: 1))
                .millisecondsSinceEpoch ~/
            1000,
        'main': {'temp': 26.0, 'humidity': 65},
        'weather': [
          {'main': 'Sunny', 'description': 'sunny', 'icon': '01d'},
        ],
      },
      {
        'dt':
            DateTime.now()
                .add(const Duration(days: 2))
                .millisecondsSinceEpoch ~/
            1000,
        'main': {'temp': 23.5, 'humidity': 72},
        'weather': [
          {'main': 'Cloudy', 'description': 'cloudy', 'icon': '03d'},
        ],
      },
      {
        'dt':
            DateTime.now()
                .add(const Duration(days: 3))
                .millisecondsSinceEpoch ~/
            1000,
        'main': {'temp': 21.0, 'humidity': 80},
        'weather': [
          {'main': 'Rain', 'description': 'light rain', 'icon': '10d'},
        ],
      },
    ];
  }

  static String getWeatherAdvice(String weatherCondition, double temperature) {
    switch (weatherCondition.toLowerCase()) {
      case 'rain':
        return 'Good time for transplanting. Ensure proper drainage.';
      case 'clear':
      case 'sunny':
        if (temperature > 30) {
          return 'Hot weather - increase irrigation frequency.';
        } else {
          return 'Perfect weather for field activities.';
        }
      case 'cloudy':
        return 'Good conditions for spraying pesticides.';
      case 'thunderstorm':
        return 'Avoid field work. Secure loose equipment.';
      default:
        return 'Check specific weather conditions for farm planning.';
    }
  }

  static bool isGoodForSpraying(Map<String, dynamic> weather) {
    final windSpeed = weather['wind']?['speed'] ?? 0.0;
    final humidity = weather['main']?['humidity'] ?? 0;
    final condition = weather['weather']?[0]?['main']?.toLowerCase() ?? '';

    return windSpeed < 5.0 &&
        humidity > 40 &&
        !['rain', 'thunderstorm'].contains(condition);
  }

  static bool isGoodForHarvesting(Map<String, dynamic> weather) {
    final humidity = weather['main']?['humidity'] ?? 0;
    final condition = weather['weather']?[0]?['main']?.toLowerCase() ?? '';

    return humidity < 70 && !['rain', 'thunderstorm'].contains(condition);
  }
}
