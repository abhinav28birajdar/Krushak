import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiAIService {
  static const String _apiKey =
      'YOUR_GEMINI_API_KEY'; // Replace with your Gemini API key
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // Get real-time market prices
  static Future<Map<String, dynamic>> getMarketPrices(
    String commodity,
    String location,
  ) async {
    try {
      final prompt =
          '''
      Get current market price for $commodity in $location, India. 
      Provide response in JSON format with following structure:
      {
        "commodity": "$commodity",
        "location": "$location",
        "current_price": "price per quintal in INR",
        "price_trend": "up/down/stable",
        "market_analysis": "brief analysis of price trend",
        "best_selling_markets": ["market1", "market2", "market3"],
        "price_forecast": "7-day forecast",
        "demand_supply": "current demand and supply status"
      }
      ''';

      final response = await _makeGeminiRequest(prompt);

      if (response != null && response['candidates'] != null) {
        final content =
            response['candidates'][0]['content']['parts'][0]['text'];
        // Parse the JSON response from Gemini
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      }

      // Fallback data if API fails
      return _getFallbackMarketData(commodity, location);
    } catch (e) {
      print('Error getting market prices: $e');
      return _getFallbackMarketData(commodity, location);
    }
  }

  // Crop diagnosis using AI
  static Future<Map<String, dynamic>> diagnoseCrop(
    String cropName,
    String symptoms,
    String? imageDescription,
  ) async {
    try {
      final prompt =
          '''
      As an agricultural expert, diagnose the crop disease/issue based on the following information:
      
      Crop: $cropName
      Symptoms: $symptoms
      ${imageDescription != null ? 'Image Description: $imageDescription' : ''}
      
      Provide response in JSON format:
      {
        "diagnosis": "specific disease or issue name",
        "confidence": "percentage (0-100)",
        "description": "detailed description of the problem",
        "causes": ["cause1", "cause2"],
        "treatment": {
          "immediate_actions": ["action1", "action2"],
          "organic_solutions": ["solution1", "solution2"],
          "chemical_solutions": ["solution1", "solution2"],
          "preventive_measures": ["measure1", "measure2"]
        },
        "severity": "low/medium/high",
        "timeline": "expected recovery time",
        "cost_estimate": "treatment cost in INR",
        "expert_tips": ["tip1", "tip2"]
      }
      ''';

      final response = await _makeGeminiRequest(prompt);

      if (response != null && response['candidates'] != null) {
        final content =
            response['candidates'][0]['content']['parts'][0]['text'];
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      }

      return _getFallbackDiagnosisData(cropName, symptoms);
    } catch (e) {
      print('Error in crop diagnosis: $e');
      return _getFallbackDiagnosisData(cropName, symptoms);
    }
  }

  // Get learning content from Gemini
  static Future<List<Map<String, dynamic>>> getLearningContent(
    String topic,
    String category,
  ) async {
    try {
      final prompt =
          '''
      Create educational content for farmers about $topic in $category category.
      Provide response in JSON array format:
      [
        {
          "title": "content title",
          "description": "brief description",
          "content": "detailed educational content",
          "difficulty": "beginner/intermediate/advanced",
          "duration": "estimated reading time",
          "key_points": ["point1", "point2", "point3"],
          "practical_tips": ["tip1", "tip2"],
          "references": ["reference1", "reference2"]
        }
      ]
      Provide 3-5 pieces of content.
      ''';

      final response = await _makeGeminiRequest(prompt);

      if (response != null && response['candidates'] != null) {
        final content =
            response['candidates'][0]['content']['parts'][0]['text'];
        final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final List<dynamic> contentList = jsonDecode(jsonMatch.group(0)!);
          return contentList.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }

      return _getFallbackLearningContent(topic, category);
    } catch (e) {
      print('Error getting learning content: $e');
      return _getFallbackLearningContent(topic, category);
    }
  }

  // Get weather-based farming advice
  static Future<Map<String, dynamic>> getWeatherBasedAdvice(
    Map<String, dynamic> weatherData,
    List<String> crops,
  ) async {
    try {
      final prompt =
          '''
      Based on current weather conditions and farmer's crops, provide farming advice:
      
      Weather: ${weatherData.toString()}
      Crops: ${crops.join(', ')}
      
      Provide response in JSON format:
      {
        "general_advice": "overall farming advice for current weather",
        "crop_specific_advice": {
          ${crops.map((crop) => '"$crop": "specific advice for $crop"').join(',\n          ')}
        },
        "immediate_actions": ["action1", "action2"],
        "weather_alerts": ["alert1", "alert2"],
        "irrigation_advice": "irrigation recommendations",
        "disease_prevention": ["prevention1", "prevention2"],
        "best_practices": ["practice1", "practice2"]
      }
      ''';

      final response = await _makeGeminiRequest(prompt);

      if (response != null && response['candidates'] != null) {
        final content =
            response['candidates'][0]['content']['parts'][0]['text'];
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      }

      return _getFallbackWeatherAdvice(weatherData, crops);
    } catch (e) {
      print('Error getting weather advice: $e');
      return _getFallbackWeatherAdvice(weatherData, crops);
    }
  }

  static Future<Map<String, dynamic>?> _makeGeminiRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error making Gemini request: $e');
      return null;
    }
  }

  // Fallback data methods
  static Map<String, dynamic> _getFallbackMarketData(
    String commodity,
    String location,
  ) {
    final basePrice = {
      'wheat': 2200,
      'rice': 2800,
      'cotton': 6200,
      'sugarcane': 350,
      'soybean': 4500,
      'corn': 1800,
      'tomato': 1200,
      'onion': 800,
      'potato': 900,
    };

    return {
      'commodity': commodity,
      'location': location,
      'current_price': '₹${basePrice[commodity.toLowerCase()] ?? 2000}/quintal',
      'price_trend': 'up',
      'market_analysis': 'Prices are trending upward due to seasonal demand',
      'best_selling_markets': ['Local Mandi', 'APMC Market', 'Online Platform'],
      'price_forecast': 'Expected to rise by 5-10% in next week',
      'demand_supply': 'High demand, moderate supply',
    };
  }

  static Map<String, dynamic> _getFallbackDiagnosisData(
    String cropName,
    String symptoms,
  ) {
    return {
      'diagnosis': 'Fungal Infection',
      'confidence': '75',
      'description':
          'Based on symptoms, appears to be a common fungal infection',
      'causes': ['High humidity', 'Poor air circulation', 'Overwatering'],
      'treatment': {
        'immediate_actions': ['Remove affected parts', 'Improve drainage'],
        'organic_solutions': ['Neem oil spray', 'Baking soda solution'],
        'chemical_solutions': ['Copper sulfate', 'Fungicide spray'],
        'preventive_measures': ['Proper spacing', 'Regular monitoring'],
      },
      'severity': 'medium',
      'timeline': '2-3 weeks with proper treatment',
      'cost_estimate': '₹500-1000',
      'expert_tips': [
        'Apply treatment early morning',
        'Ensure good ventilation',
      ],
    };
  }

  static List<Map<String, dynamic>> _getFallbackLearningContent(
    String topic,
    String category,
  ) {
    return [
      {
        'title': 'Modern $topic Techniques',
        'description': 'Learn advanced techniques for $topic',
        'content': 'Comprehensive guide to modern $topic practices...',
        'difficulty': 'intermediate',
        'duration': '15 minutes',
        'key_points': ['Point 1', 'Point 2', 'Point 3'],
        'practical_tips': ['Tip 1', 'Tip 2'],
        'references': ['Agricultural University', 'ICAR Research'],
      },
    ];
  }

  static Map<String, dynamic> _getFallbackWeatherAdvice(
    Map<String, dynamic> weatherData,
    List<String> crops,
  ) {
    return {
      'general_advice':
          'Monitor weather conditions closely and adjust farming practices accordingly',
      'crop_specific_advice': crops.asMap().map(
        (key, crop) => MapEntry(
          crop,
          'Maintain proper irrigation for $crop based on current weather',
        ),
      ),
      'immediate_actions': ['Check irrigation systems', 'Monitor crop health'],
      'weather_alerts': ['Temperature changes expected', 'Monitor for pests'],
      'irrigation_advice': 'Adjust watering schedule based on humidity levels',
      'disease_prevention': [
        'Improve air circulation',
        'Monitor humidity levels',
      ],
      'best_practices': ['Regular field inspection', 'Maintain soil health'],
    };
  }
}
