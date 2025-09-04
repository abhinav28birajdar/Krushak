import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class GeminiAIService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'demo_key',
  );
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static Timer? _autoAnalysisTimer;
  static List<Function(String)> _analysisListeners = [];

  static void initialize() {
    // Start auto-analysis every 2 minutes as requested
    _autoAnalysisTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _performAutoAnalysis(),
    );
  }

  static void dispose() {
    _autoAnalysisTimer?.cancel();
    _analysisListeners.clear();
  }

  static void addAnalysisListener(Function(String) listener) {
    _analysisListeners.add(listener);
  }

  static void removeAnalysisListener(Function(String) listener) {
    _analysisListeners.remove(listener);
  }

  static void _notifyListeners(String analysis) {
    for (final listener in _analysisListeners) {
      try {
        listener(analysis);
      } catch (e) {
        print('Error notifying analysis listener: $e');
      }
    }
  }

  static Future<void> _performAutoAnalysis() async {
    try {
      final currentTime = DateTime.now();
      final hour = currentTime.hour;

      String analysisType;
      if (hour >= 6 && hour < 12) {
        analysisType = 'morning_analysis';
      } else if (hour >= 12 && hour < 18) {
        analysisType = 'afternoon_analysis';
      } else {
        analysisType = 'evening_analysis';
      }

      final analysis = await _getTimeBasedAnalysis(analysisType, currentTime);
      _notifyListeners(analysis);
    } catch (e) {
      print('Error performing auto analysis: $e');
    }
  }

  static Future<String> _getTimeBasedAnalysis(
    String type,
    DateTime time,
  ) async {
    String prompt;

    switch (type) {
      case 'morning_analysis':
        prompt =
            '''
        Good morning! Provide a comprehensive farming analysis for today:
        
        1. Weather considerations for morning farm activities
        2. Best crops to tend to in morning hours
        3. Irrigation recommendations
        4. Market opportunities to watch today
        5. Seasonal farming tips for ${_getCurrentSeason()}
        
        Current time: ${time.toString()}
        Keep response under 200 words and make it actionable for Indian farmers.
        ''';
        break;

      case 'afternoon_analysis':
        prompt =
            '''
        Afternoon farming update:
        
        1. Midday weather precautions
        2. Market price movements to monitor
        3. Crop protection advice for afternoon heat
        4. Optimal selling times today
        5. Equipment maintenance tips
        
        Current time: ${time.toString()}
        Keep response under 200 words and focus on practical advice.
        ''';
        break;

      case 'evening_analysis':
        prompt =
            '''
        Evening farming summary:
        
        1. Tomorrow's farming preparations
        2. Market analysis and selling opportunities
        3. Crop health monitoring tips
        4. Weather outlook for next day
        5. End-of-day farm management tasks
        
        Current time: ${time.toString()}
        Keep response under 200 words and plan-focused.
        ''';
        break;

      default:
        prompt = '''
        General farming analysis:
        
        1. Current season farming recommendations
        2. Market trends to watch
        3. Weather-based farming tips
        4. Crop management advice
        
        Provide actionable insights for farmers in under 150 words.
        ''';
    }

    return await analyzeWithPrompt(prompt) ??
        'Auto-analysis temporarily unavailable. Check weather and market updates manually.';
  }

  static String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Summer';
    if (month >= 6 && month <= 9) return 'Monsoon';
    if (month >= 10 && month <= 2) return 'Winter';
    return 'Transition';
  }

  static Future<String?> analyzeWithPrompt(String prompt) async {
    try {
      if (_apiKey == 'demo_key') {
        // Return demo response when API key is not available
        return _getDemoResponse(prompt);
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
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
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;

          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String?;
          }
        }
      }

      throw Exception('Invalid response format');
    } catch (e) {
      print('Error calling Gemini API: $e');
      return _getDemoResponse(prompt);
    }
  }

  static String _getDemoResponse(String prompt) {
    // Provide contextual demo responses based on prompt keywords
    final lowerPrompt = prompt.toLowerCase();

    if (lowerPrompt.contains('weather') &&
        lowerPrompt.contains('temperature')) {
      return 'Weather Alert: Monitor temperature changes. Ensure adequate irrigation during hot weather. Protect crops from extreme conditions.';
    }

    if (lowerPrompt.contains('market') && lowerPrompt.contains('price')) {
      return 'Market Update: Current prices show seasonal trends. Consider selling high-demand crops. Monitor government procurement rates.';
    }

    if (lowerPrompt.contains('morning')) {
      return 'Morning Farming Tips: Check irrigation systems, inspect crops for pests, plan fertilizer application. Ideal time for field work before heat increases.';
    }

    if (lowerPrompt.contains('afternoon')) {
      return 'Afternoon Guidance: Avoid heavy fieldwork during peak heat. Focus on equipment maintenance, market research, and planning activities.';
    }

    if (lowerPrompt.contains('evening')) {
      return 'Evening Planning: Review today\'s progress, prepare for tomorrow\'s tasks, check weather forecast, plan irrigation schedules.';
    }

    if (lowerPrompt.contains('crop') &&
        lowerPrompt.contains('recommendation')) {
      return 'Crop Management: Monitor plant health, ensure proper nutrition, check for diseases, maintain optimal soil moisture levels.';
    }

    if (lowerPrompt.contains('rain') || lowerPrompt.contains('heavy')) {
      return 'Rain Advisory: Ensure proper drainage, protect crops from waterlogging, postpone fertilizer application until after rain.';
    }

    if (lowerPrompt.contains('drought') || lowerPrompt.contains('humidity')) {
      return 'Drought Management: Implement water conservation, use mulching techniques, adjust irrigation schedules, protect sensitive crops.';
    }

    return 'Agricultural Advisory: Focus on seasonal best practices, monitor weather conditions, stay updated with market trends, maintain crop health.';
  }

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
