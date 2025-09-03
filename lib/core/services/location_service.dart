import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const String _weatherApiKey =
      'YOUR_OPENWEATHER_API_KEY'; // Replace with your API key
  static const String _weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Get weather data for location
  static Future<Map<String, dynamic>> getWeatherData(
    double latitude,
    double longitude,
  ) async {
    try {
      final url =
          '$_weatherBaseUrl/weather?lat=$latitude&lon=$longitude&appid=$_weatherApiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'location': data['name'],
          'country': data['sys']['country'],
          'temperature': data['main']['temp'].round(),
          'feelsLike': data['main']['feels_like'].round(),
          'humidity': data['main']['humidity'],
          'pressure': data['main']['pressure'],
          'windSpeed': data['wind']['speed'],
          'windDirection': data['wind']['deg'],
          'visibility': data['visibility'] / 1000, // Convert to km
          'cloudiness': data['clouds']['all'],
          'weather': data['weather'][0]['main'],
          'weatherDescription': data['weather'][0]['description'],
          'weatherIcon': data['weather'][0]['icon'],
          'sunrise': DateTime.fromMillisecondsSinceEpoch(
            data['sys']['sunrise'] * 1000,
          ),
          'sunset': DateTime.fromMillisecondsSinceEpoch(
            data['sys']['sunset'] * 1000,
          ),
          'timestamp': DateTime.now(),
        };
      } else {
        return _getFallbackWeatherData(latitude, longitude);
      }
    } catch (e) {
      print('Error getting weather data: $e');
      return _getFallbackWeatherData(latitude, longitude);
    }
  }

  // Get weather forecast for next 5 days
  static Future<List<Map<String, dynamic>>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final url =
          '$_weatherBaseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_weatherApiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> forecastList = data['list'];

        return forecastList
            .take(10)
            .map(
              (forecast) => {
                'date': DateTime.fromMillisecondsSinceEpoch(
                  forecast['dt'] * 1000,
                ),
                'temperature': forecast['main']['temp'].round(),
                'minTemp': forecast['main']['temp_min'].round(),
                'maxTemp': forecast['main']['temp_max'].round(),
                'humidity': forecast['main']['humidity'],
                'weather': forecast['weather'][0]['main'],
                'weatherDescription': forecast['weather'][0]['description'],
                'weatherIcon': forecast['weather'][0]['icon'],
                'windSpeed': forecast['wind']['speed'],
                'cloudiness': forecast['clouds']['all'],
              },
            )
            .toList()
            .cast<Map<String, dynamic>>();
      } else {
        return _getFallbackForecastData();
      }
    } catch (e) {
      print('Error getting weather forecast: $e');
      return _getFallbackForecastData();
    }
  }

  // Get location details from coordinates
  static Future<Map<String, dynamic>> getLocationDetails(
    double latitude,
    double longitude,
  ) async {
    try {
      final url =
          'https://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$_weatherApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          return {
            'city': location['name'] ?? 'Unknown',
            'state': location['state'] ?? 'Unknown',
            'country': location['country'] ?? 'Unknown',
            'latitude': latitude,
            'longitude': longitude,
          };
        }
      }

      return _getFallbackLocationData(latitude, longitude);
    } catch (e) {
      print('Error getting location details: $e');
      return _getFallbackLocationData(latitude, longitude);
    }
  }

  // Get nearby markets/mandis
  static Future<List<Map<String, dynamic>>> getNearbyMarkets(
    double latitude,
    double longitude, {
    double radiusKm = 50,
  }) async {
    // This would typically use a places API or custom database
    // For now, returning sample data based on common market locations in India

    final markets = [
      {
        'name': 'Local APMC Market',
        'address': 'Main Market Road',
        'distance': '5.2 km',
        'type': 'APMC Market',
        'openTime': '06:00 AM',
        'closeTime': '02:00 PM',
        'contact': '+91-9876543210',
        'facilities': ['Weighbridge', 'Storage', 'Banking'],
        'latitude': latitude + 0.01,
        'longitude': longitude + 0.01,
      },
      {
        'name': 'District Agricultural Market',
        'address': 'Agriculture Market Yard',
        'distance': '12.8 km',
        'type': 'District Market',
        'openTime': '05:30 AM',
        'closeTime': '03:00 PM',
        'contact': '+91-9876543211',
        'facilities': ['Quality Testing', 'Auction Hall', 'Cold Storage'],
        'latitude': latitude + 0.02,
        'longitude': longitude - 0.01,
      },
      {
        'name': 'Regional Wholesale Market',
        'address': 'Wholesale Market Complex',
        'distance': '25.4 km',
        'type': 'Wholesale Market',
        'openTime': '04:00 AM',
        'closeTime': '04:00 PM',
        'contact': '+91-9876543212',
        'facilities': [
          'Multiple Buyers',
          'Transport Hub',
          'Financial Services',
        ],
        'latitude': latitude - 0.01,
        'longitude': longitude + 0.02,
      },
    ];

    return markets;
  }

  // Get agricultural zones for the region
  static Map<String, dynamic> getAgriculturalZoneInfo(
    double latitude,
    double longitude,
  ) {
    // Simplified zoning based on coordinates
    // In real implementation, this would use government agricultural zone data

    if (latitude >= 8 && latitude <= 12 && longitude >= 77 && longitude <= 78) {
      return {
        'zone': 'Southern Zone',
        'state': 'Karnataka',
        'cropPattern': 'Rabi and Kharif crops',
        'mainCrops': ['Rice', 'Sugarcane', 'Cotton', 'Groundnut'],
        'soilType': 'Red soil and Black soil',
        'rainfallPattern': 'Monsoon dependent',
        'irrigationSources': ['Bore wells', 'Canals', 'Tanks'],
        'averageRainfall': '600-1000 mm',
        'growingSeasons': ['Kharif (June-October)', 'Rabi (November-March)'],
      };
    } else if (latitude >= 18 &&
        latitude <= 21 &&
        longitude >= 72 &&
        longitude <= 77) {
      return {
        'zone': 'Western Zone',
        'state': 'Maharashtra',
        'cropPattern': 'Cotton and Sugarcane belt',
        'mainCrops': ['Cotton', 'Sugarcane', 'Soybean', 'Wheat'],
        'soilType': 'Black soil (Regur)',
        'rainfallPattern': 'Monsoon dependent',
        'irrigationSources': ['Wells', 'Rivers', 'Reservoirs'],
        'averageRainfall': '500-1200 mm',
        'growingSeasons': ['Kharif (June-October)', 'Rabi (November-April)'],
      };
    } else {
      return {
        'zone': 'General Zone',
        'state': 'India',
        'cropPattern': 'Mixed cropping',
        'mainCrops': ['Rice', 'Wheat', 'Pulses', 'Oilseeds'],
        'soilType': 'Varied soil types',
        'rainfallPattern': 'Monsoon dependent',
        'irrigationSources': ['Wells', 'Canals', 'Rivers'],
        'averageRainfall': '600-1200 mm',
        'growingSeasons': ['Kharif (June-October)', 'Rabi (November-March)'],
      };
    }
  }

  static Map<String, dynamic> _getFallbackWeatherData(
    double latitude,
    double longitude,
  ) {
    return {
      'location': 'Current Location',
      'country': 'IN',
      'temperature': 28,
      'feelsLike': 32,
      'humidity': 65,
      'pressure': 1013,
      'windSpeed': 3.5,
      'windDirection': 180,
      'visibility': 10.0,
      'cloudiness': 20,
      'weather': 'Clear',
      'weatherDescription': 'clear sky',
      'weatherIcon': '01d',
      'sunrise': DateTime.now().subtract(Duration(hours: 2)),
      'sunset': DateTime.now().add(Duration(hours: 6)),
      'timestamp': DateTime.now(),
    };
  }

  static List<Map<String, dynamic>> _getFallbackForecastData() {
    return List.generate(
      5,
      (index) => {
        'date': DateTime.now().add(Duration(days: index + 1)),
        'temperature': 28 + (index % 3),
        'minTemp': 22 + (index % 2),
        'maxTemp': 34 + (index % 3),
        'humidity': 60 + (index * 5),
        'weather': ['Clear', 'Clouds', 'Rain'][index % 3],
        'weatherDescription': [
          'clear sky',
          'few clouds',
          'light rain',
        ][index % 3],
        'weatherIcon': ['01d', '02d', '10d'][index % 3],
        'windSpeed': 3.0 + (index * 0.5),
        'cloudiness': 20 + (index * 10),
      },
    );
  }

  static Map<String, dynamic> _getFallbackLocationData(
    double latitude,
    double longitude,
  ) {
    return {
      'city': 'Current City',
      'state': 'Current State',
      'country': 'India',
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
