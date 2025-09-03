import 'dart:math';

class MarketDataService {
  static const List<Map<String, dynamic>> _cropPrices = [
    {
      'name': 'Wheat',
      'currentPrice': 2150.0,
      'unit': 'per quintal',
      'change': 2.5,
      'trend': 'up',
      'marketDemand': 'high',
    },
    {
      'name': 'Rice',
      'currentPrice': 3200.0,
      'unit': 'per quintal',
      'change': -1.2,
      'trend': 'down',
      'marketDemand': 'medium',
    },
    {
      'name': 'Maize',
      'currentPrice': 1850.0,
      'unit': 'per quintal',
      'change': 0.8,
      'trend': 'up',
      'marketDemand': 'high',
    },
    {
      'name': 'Sugarcane',
      'currentPrice': 350.0,
      'unit': 'per quintal',
      'change': 1.5,
      'trend': 'up',
      'marketDemand': 'medium',
    },
    {
      'name': 'Cotton',
      'currentPrice': 6800.0,
      'unit': 'per quintal',
      'change': -0.5,
      'trend': 'down',
      'marketDemand': 'low',
    },
    {
      'name': 'Potato',
      'currentPrice': 1200.0,
      'unit': 'per quintal',
      'change': 3.2,
      'trend': 'up',
      'marketDemand': 'high',
    },
    {
      'name': 'Onion',
      'currentPrice': 2800.0,
      'unit': 'per quintal',
      'change': -2.1,
      'trend': 'down',
      'marketDemand': 'medium',
    },
    {
      'name': 'Tomato',
      'currentPrice': 1500.0,
      'unit': 'per quintal',
      'change': 4.5,
      'trend': 'up',
      'marketDemand': 'high',
    },
  ];

  static Future<List<Map<String, dynamic>>> getLiveMarketPrices() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Add some randomness to simulate real-time price changes
    final Random random = Random();

    return _cropPrices.map((crop) {
      final basePrice = crop['currentPrice'] as double;
      final variation = (random.nextDouble() - 0.5) * 0.1; // ±5% variation
      final newPrice = basePrice * (1 + variation);
      final priceChange = ((newPrice - basePrice) / basePrice) * 100;

      return {
        ...crop,
        'currentPrice': newPrice,
        'change': priceChange,
        'trend': priceChange >= 0 ? 'up' : 'down',
        'lastUpdated': DateTime.now(),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> getCropDetails(String cropName) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final crop = _cropPrices.firstWhere(
      (c) => c['name'].toLowerCase() == cropName.toLowerCase(),
      orElse: () => _cropPrices.first,
    );

    return {
      ...crop,
      'description': _getCropDescription(cropName),
      'seasonalTrends': _getSeasonalTrends(cropName),
      'bestMarkets': _getBestMarkets(cropName),
      'qualityFactors': _getQualityFactors(cropName),
    };
  }

  static String _getCropDescription(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return 'Major cereal crop, high demand in flour mills and export markets.';
      case 'rice':
        return 'Staple food grain with steady domestic and international demand.';
      case 'maize':
        return 'Versatile crop used for food, feed, and industrial purposes.';
      case 'sugarcane':
        return 'Cash crop processed in sugar mills, high water requirement.';
      case 'cotton':
        return 'Important fiber crop for textile industry, price volatile.';
      case 'potato':
        return 'Vegetable crop with good storage potential and processing demand.';
      case 'onion':
        return 'Essential vegetable with seasonal price fluctuations.';
      case 'tomato':
        return 'High-value vegetable crop, requires cold storage for better prices.';
      default:
        return 'Important agricultural commodity with market potential.';
    }
  }

  static List<String> _getSeasonalTrends(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return ['Peak harvest: March-April', 'Sowing: November-December'];
      case 'rice':
        return [
          'Kharif harvest: October-November',
          'Rabi harvest: March-April',
        ];
      case 'potato':
        return ['Best prices: May-August', 'Harvest: January-March'];
      default:
        return ['Check seasonal calendar for optimal timing'];
    }
  }

  static List<String> _getBestMarkets(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return ['Karnal Mandi', 'Hisar APMC', 'Ludhiana Market'];
      case 'rice':
        return ['Chandigarh Market', 'Karnal Mandi', 'Basmati Hub'];
      case 'potato':
        return ['Agra Mandi', 'Delhi Azadpur', 'Kanpur Market'];
      default:
        return ['Local APMC', 'Wholesale Markets', 'FPO Centers'];
    }
  }

  static List<String> _getQualityFactors(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return ['Moisture content', 'Protein percentage', 'Grain weight'];
      case 'rice':
        return ['Grain length', 'Broken percentage', 'Purity level'];
      case 'potato':
        return ['Size uniformity', 'Dry matter', 'Disease-free'];
      default:
        return ['Freshness', 'Grade standards', 'Packaging quality'];
    }
  }

  static Future<List<Map<String, dynamic>>> getMarketNews() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      {
        'headline': 'Wheat Prices Rise Due to Export Demand',
        'summary':
            'International demand pushes wheat prices up by 3% this week.',
        'impact': 'positive',
        'relevantCrops': ['Wheat'],
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'headline': 'Monsoon Forecast Affects Rice Sowing',
        'summary':
            'Early monsoon prediction influences rice cultivation decisions.',
        'impact': 'neutral',
        'relevantCrops': ['Rice'],
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'headline': 'Government Announces Potato Storage Subsidy',
        'summary':
            'New cold storage incentives to help farmers get better prices.',
        'impact': 'positive',
        'relevantCrops': ['Potato'],
        'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getPriceAlerts(
    List<String> crops,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      {
        'crop': 'Tomato',
        'message': 'Price increased by 5% - Good time to sell!',
        'type': 'sell_opportunity',
        'priority': 'high',
      },
      {
        'crop': 'Wheat',
        'message': 'Target price of ₹2200/quintal reached',
        'type': 'target_reached',
        'priority': 'medium',
      },
      {
        'crop': 'Onion',
        'message': 'Price dropping - Consider storage options',
        'type': 'price_warning',
        'priority': 'medium',
      },
    ];
  }
}
