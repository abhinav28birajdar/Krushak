import 'dart:math';

class CropMonitoringService {
  static Future<Map<String, dynamic>> getCropHealthStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final Random random = Random();

    return {
      'overallHealth': 85 + random.nextInt(10), // 85-94%
      'diseaseRisk': ['Low', 'Medium', 'High'][random.nextInt(3)],
      'pestActivity': ['Minimal', 'Moderate', 'High'][random.nextInt(3)],
      'soilMoisture': 60 + random.nextInt(25), // 60-84%
      'nutrients': {
        'nitrogen': 'Adequate',
        'phosphorus': 'Low',
        'potassium': 'High',
      },
      'recommendations': _getHealthRecommendations(),
      'lastUpdated': DateTime.now(),
    };
  }

  static Future<List<Map<String, dynamic>>> getFieldAlerts() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return [
      {
        'type': 'irrigation',
        'severity': 'medium',
        'message': 'Soil moisture dropping in Field A - Consider irrigation',
        'field': 'Field A',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'action': 'Schedule irrigation within 24 hours',
      },
      {
        'type': 'pest',
        'severity': 'high',
        'message': 'Aphid activity detected in tomato section',
        'field': 'Field B',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        'action': 'Apply organic pesticide immediately',
      },
      {
        'type': 'weather',
        'severity': 'low',
        'message': 'Perfect conditions for fertilizer application',
        'field': 'All Fields',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'action': 'Consider applying nutrients today',
      },
      {
        'type': 'growth',
        'severity': 'medium',
        'message': 'Wheat crop entering critical growth stage',
        'field': 'Field C',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        'action': 'Monitor closely for next 2 weeks',
      },
    ];
  }

  static Future<Map<String, dynamic>> getSoilAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final Random random = Random();

    return {
      'ph': 6.5 + (random.nextDouble() * 1.5), // 6.5-8.0
      'organicMatter': 2.5 + (random.nextDouble() * 2.0), // 2.5-4.5%
      'nitrogen': 180 + random.nextInt(100), // 180-280 kg/ha
      'phosphorus': 15 + random.nextInt(20), // 15-35 kg/ha
      'potassium': 220 + random.nextInt(100), // 220-320 kg/ha
      'moistureContent': 15 + random.nextInt(20), // 15-35%
      'temperature': 22 + random.nextInt(8), // 22-30°C
      'recommendations': _getSoilRecommendations(),
      'testDate': DateTime.now().subtract(const Duration(days: 7)),
      'nextTestDue': DateTime.now().add(const Duration(days: 30)),
    };
  }

  static Future<List<Map<String, dynamic>>> getCropSchedule() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      {
        'activity': 'Irrigation',
        'crop': 'Tomato',
        'field': 'Field B',
        'scheduledDate': DateTime.now().add(const Duration(days: 1)),
        'status': 'pending',
        'priority': 'high',
        'duration': '2 hours',
      },
      {
        'activity': 'Fertilizer Application',
        'crop': 'Wheat',
        'field': 'Field C',
        'scheduledDate': DateTime.now().add(const Duration(days: 2)),
        'status': 'pending',
        'priority': 'medium',
        'duration': '4 hours',
      },
      {
        'activity': 'Pest Inspection',
        'crop': 'Rice',
        'field': 'Field A',
        'scheduledDate': DateTime.now().add(const Duration(days: 3)),
        'status': 'pending',
        'priority': 'medium',
        'duration': '1 hour',
      },
      {
        'activity': 'Harvesting',
        'crop': 'Onion',
        'field': 'Field D',
        'scheduledDate': DateTime.now().add(const Duration(days: 7)),
        'status': 'upcoming',
        'priority': 'high',
        'duration': '6 hours',
      },
    ];
  }

  static Future<Map<String, dynamic>> getYieldPrediction(
    String cropName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final Random random = Random();
    final baseYield = _getBaseYield(cropName);
    final variation = (random.nextDouble() - 0.5) * 0.2; // ±10% variation
    final predictedYield = baseYield * (1 + variation);

    return {
      'crop': cropName,
      'predictedYield': predictedYield,
      'unit': 'quintals/hectare',
      'confidence': 85 + random.nextInt(10), // 85-94%
      'factors': {
        'weather': 'Favorable',
        'soilHealth': 'Good',
        'pestManagement': 'Effective',
        'irrigation': 'Optimal',
      },
      'comparisonWithLastYear': variation * 100,
      'estimatedHarvestDate': DateTime.now().add(
        Duration(days: 30 + random.nextInt(60)),
      ),
      'recommendations': _getYieldRecommendations(cropName),
    };
  }

  static double _getBaseYield(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return 45.0;
      case 'rice':
        return 55.0;
      case 'maize':
        return 60.0;
      case 'sugarcane':
        return 650.0;
      case 'cotton':
        return 25.0;
      case 'potato':
        return 200.0;
      case 'onion':
        return 180.0;
      case 'tomato':
        return 350.0;
      default:
        return 50.0;
    }
  }

  static List<String> _getHealthRecommendations() {
    return [
      'Maintain regular irrigation schedule',
      'Apply organic fertilizer next week',
      'Monitor for pest activity daily',
      'Ensure proper drainage in all fields',
      'Consider soil testing in 2 weeks',
    ];
  }

  static List<String> _getSoilRecommendations() {
    return [
      'Add organic compost to improve soil structure',
      'Consider lime application to balance pH',
      'Increase phosphorus levels with DAP fertilizer',
      'Maintain current potassium levels',
      'Improve water retention with mulching',
    ];
  }

  static List<String> _getYieldRecommendations(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return [
          'Apply urea during tillering stage',
          'Ensure adequate moisture during grain filling',
          'Monitor for rust diseases',
        ];
      case 'rice':
        return [
          'Maintain 2-3 cm water level',
          'Apply potash during panicle initiation',
          'Control weeds early in season',
        ];
      case 'tomato':
        return [
          'Support plants with stakes',
          'Regular pruning for better yield',
          'Control humidity to prevent diseases',
        ];
      default:
        return [
          'Follow recommended fertilizer schedule',
          'Monitor weather conditions',
          'Maintain optimal irrigation',
        ];
    }
  }

  static Future<List<Map<String, dynamic>>> getIrrigationSchedule() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      {
        'field': 'Field A',
        'crop': 'Wheat',
        'nextIrrigation': DateTime.now().add(const Duration(hours: 18)),
        'duration': '2 hours',
        'waterRequirement': '25mm',
        'method': 'Drip irrigation',
        'priority': 'high',
      },
      {
        'field': 'Field B',
        'crop': 'Tomato',
        'nextIrrigation': DateTime.now().add(const Duration(days: 1, hours: 6)),
        'duration': '1.5 hours',
        'waterRequirement': '20mm',
        'method': 'Sprinkler',
        'priority': 'medium',
      },
      {
        'field': 'Field C',
        'crop': 'Rice',
        'nextIrrigation': DateTime.now().add(const Duration(days: 2)),
        'duration': '3 hours',
        'waterRequirement': '50mm',
        'method': 'Flood irrigation',
        'priority': 'low',
      },
    ];
  }
}
