import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../diagnosis/presentation/screens/crop_diagnosis_screen.dart';
import '../../../loans/presentation/screens/bank_loans_screen.dart';
import '../../../market/presentation/screens/market_screen.dart';
import '../../../account/presentation/screens/account_screen.dart';

/// Modern Home Screen with comprehensive dashboard
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  final ScrollController _scrollController = ScrollController();

  // Data state
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _weatherData;
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _farmCrops = [];
  List<Map<String, dynamic>> _marketPrices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data
      _userData = await SupabaseService.getCurrentUser();

      // Load weather data based on location
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        _weatherData = await LocationService.getWeatherData(
          position.latitude,
          position.longitude,
        );
      }

      // Load announcements
      _announcements = await SupabaseService.getActiveAnnouncements();

      // Load market prices
      await _loadMarketPrices();

      // Load farm crops if user has farms
      if (_userData != null) {
        final farms = await SupabaseService.getUserFarms();
        if (farms.isNotEmpty) {
          _farmCrops = await SupabaseService.getFarmCrops(farms.first['id']);
        }
      }
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Future<void> _loadMarketPrices() async {
    try {
      final commodities = ['wheat', 'rice', 'cotton', 'soybean'];
      _marketPrices.clear();

      for (String commodity in commodities) {
        final priceData = await GeminiAIService.getMarketPrices(
          commodity,
          'India',
        );
        _marketPrices.add(priceData);
      }
    } catch (e) {
      print('Error loading market prices: $e');
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _refreshController.forward();
    await _loadInitialData();
    _refreshController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KrushakColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: KrushakColors.primaryGreen,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: KrushakColors.primaryGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: KrushakColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(KrushakSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: KrushakColors.white,
                                child: ClipOval(
                                  child: Image.asset(
                                    'web/logoapp.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.agriculture,
                                        color: KrushakColors.primaryGreen,
                                        size: KrushakIconSizes.md,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: KrushakSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Good ${_getGreeting()}!',
                                      style: KrushakTextStyles.bodyMedium
                                          .copyWith(
                                            color: KrushakColors.white
                                                .withOpacity(0.8),
                                          ),
                                    ),
                                    Text(
                                      _userData?['full_name'] ?? 'Farmer',
                                      style: KrushakTextStyles.h4.copyWith(
                                        color: KrushakColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications_outlined,
                                      color: KrushakColors.white,
                                      size: KrushakIconSizes.md,
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: KrushakColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(KrushakSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Announcements
                  if (_announcements.isNotEmpty) ...[
                    _buildAnnouncementsCard(),
                    const SizedBox(height: KrushakSpacing.md),
                  ],

                  // Weather Card
                  _buildWeatherCard(),
                  const SizedBox(height: KrushakSpacing.md),

                  // Quick Actions Grid
                  _buildQuickActionsGrid(),
                  const SizedBox(height: KrushakSpacing.md),

                  // Farm Overview
                  _buildFarmOverviewCard(),
                  const SizedBox(height: KrushakSpacing.md),

                  // AI Insights
                  _buildAIInsightsCard(),
                  const SizedBox(height: KrushakSpacing.md),

                  // Crop Monitoring
                  _buildCropMonitoringCard(),
                  const SizedBox(height: KrushakSpacing.md),

                  // Market Prices
                  _buildMarketPricesCard(),
                  const SizedBox(height: KrushakSpacing.xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.campaign,
                color: Colors.orange,
                size: KrushakIconSizes.md,
              ),
              const SizedBox(width: KrushakSpacing.sm),
              Text(
                'Important Announcements',
                style: KrushakTextStyles.h5.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: KrushakSpacing.md),
          ...(_announcements
              .take(2)
              .map(
                (announcement) => Container(
                  margin: const EdgeInsets.only(bottom: KrushakSpacing.sm),
                  padding: const EdgeInsets.all(KrushakSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(KrushakRadius.md),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement['title'] ?? 'Announcement',
                        style: KrushakTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement['message'] ?? 'No message',
                        style: KrushakTextStyles.bodySmall.copyWith(
                          color: KrushakColors.mediumGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
              .toList()),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final weather = _weatherData;
    final temperature = weather?['temperature']?.toString() ?? '28';
    final description = weather?['weatherDescription'] ?? 'Partly Cloudy';
    final humidity = weather?['humidity']?.toString() ?? '65';
    final windSpeed = weather?['windSpeed']?.toString() ?? '12';
    final location = weather?['location'] ?? 'Current Location';

    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Weather - $location',
                    style: KrushakTextStyles.labelMedium.copyWith(
                      color: KrushakColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${temperature}°C',
                    style: KrushakTextStyles.h1.copyWith(
                      color: KrushakColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: KrushakTextStyles.bodySmall.copyWith(
                      color: KrushakColors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.wb_cloudy, color: KrushakColors.white, size: 48),
            ],
          ),
          const SizedBox(height: KrushakSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail('Humidity', '$humidity%'),
              _buildWeatherDetail('Wind', '$windSpeed km/h'),
              _buildWeatherDetail(
                'Rain',
                weather?['cloudiness']?.toString() ?? '20%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: KrushakTextStyles.labelLarge.copyWith(
            color: KrushakColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: KrushakTextStyles.caption.copyWith(
            color: KrushakColors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: KrushakTextStyles.h4.copyWith(
            color: KrushakColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: KrushakSpacing.md,
          mainAxisSpacing: KrushakSpacing.md,
          childAspectRatio: 1.2,
          children: [
            _buildQuickActionCard(
              'Crop Diagnosis',
              Icons.local_hospital,
              KrushakColors.primaryGreen,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CropDiagnosisScreen(),
                ),
              ),
            ),
            _buildQuickActionCard(
              'Log Practice',
              Icons.eco,
              KrushakColors.secondaryGreen,
              () {},
            ),
            _buildQuickActionCard(
              'Market Prices',
              Icons.trending_up,
              KrushakColors.accentTeal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MarketScreen()),
              ),
            ),
            _buildQuickActionCard(
              'Apply Loan',
              Icons.account_balance,
              KrushakColors.info,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BankLoansScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(KrushakSpacing.md),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(KrushakRadius.lg),
            boxShadow: KrushakShadows.card,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: KrushakColors.white, size: KrushakIconSizes.lg),
              const SizedBox(height: KrushakSpacing.sm),
              Text(
                title,
                style: KrushakTextStyles.labelMedium.copyWith(
                  color: KrushakColors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmOverviewCard() {
    final totalArea = _userData?['farm_area'] ?? '5.2';
    final activeCrops = _farmCrops.length.toString();
    final carbonCredits = _userData?['carbon_credits'] ?? '124';

    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Farm Overview',
                style: KrushakTextStyles.h5.copyWith(
                  color: KrushakColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: KrushakTextStyles.labelMedium.copyWith(
                    color: KrushakColors.accentTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KrushakSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildFarmStat(
                  'Total Area',
                  '$totalArea acres',
                  Icons.landscape,
                ),
              ),
              Expanded(
                child: _buildFarmStat('Active Crops', activeCrops, Icons.grass),
              ),
              Expanded(
                child: _buildFarmStat(
                  'Carbon Credits',
                  carbonCredits,
                  Icons.eco,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: KrushakColors.primaryGreen,
          size: KrushakIconSizes.md,
        ),
        const SizedBox(height: KrushakSpacing.xs),
        Text(
          value,
          style: KrushakTextStyles.h5.copyWith(
            color: KrushakColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: KrushakTextStyles.caption.copyWith(
            color: KrushakColors.mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAIInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrushakColors.accentTeal.withOpacity(0.1),
            KrushakColors.secondaryGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        border: Border.all(color: KrushakColors.accentTeal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: KrushakColors.accentTeal,
                size: KrushakIconSizes.md,
              ),
              const SizedBox(width: KrushakSpacing.sm),
              Text(
                'AI Insights',
                style: KrushakTextStyles.h5.copyWith(
                  color: KrushakColors.accentTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: KrushakSpacing.md),
          Text(
            'Based on current weather patterns and your crop data, consider applying organic fertilizer to your wheat field in the next 2 days for optimal growth.',
            style: KrushakTextStyles.bodyMedium.copyWith(
              color: KrushakColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropMonitoringCard() {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Monitoring',
            style: KrushakTextStyles.h5.copyWith(
              color: KrushakColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: KrushakSpacing.md),
          if (_farmCrops.isNotEmpty)
            ...(_farmCrops
                .take(3)
                .map(
                  (crop) => _buildCropItem(
                    crop['crop_name'] ?? 'Unknown Crop',
                    crop['area_acres']?.toString() ?? 'Field',
                    crop['status'] ?? 'Growing',
                    _getCropStatusColor(crop['status']),
                  ),
                )
                .toList())
          else ...[
            _buildCropItem(
              'Wheat',
              'Field A',
              'Healthy',
              KrushakColors.success,
            ),
            _buildCropItem(
              'Rice',
              'Field B',
              'Needs Water',
              KrushakColors.warning,
            ),
            _buildCropItem(
              'Maize',
              'Field C',
              'Excellent',
              KrushakColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Color _getCropStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
      case 'excellent':
      case 'growing':
        return KrushakColors.success;
      case 'needs water':
      case 'warning':
        return KrushakColors.warning;
      case 'diseased':
      case 'critical':
        return KrushakColors.error;
      default:
        return KrushakColors.success;
    }
  }

  Widget _buildCropItem(
    String crop,
    String field,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KrushakSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KrushakRadius.sm),
            ),
            child: Icon(
              Icons.grass,
              color: statusColor,
              size: KrushakIconSizes.sm,
            ),
          ),
          const SizedBox(width: KrushakSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop,
                  style: KrushakTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  field,
                  style: KrushakTextStyles.caption.copyWith(
                    color: KrushakColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KrushakSpacing.sm,
              vertical: KrushakSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KrushakRadius.sm),
            ),
            child: Text(
              status,
              style: KrushakTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPricesCard() {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Market Prices',
                style: KrushakTextStyles.h5.copyWith(
                  color: KrushakColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MarketScreen()),
                ),
                child: Text(
                  'View All',
                  style: KrushakTextStyles.labelMedium.copyWith(
                    color: KrushakColors.accentTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KrushakSpacing.md),
          if (_marketPrices.isNotEmpty)
            ...(_marketPrices
                .take(3)
                .map(
                  (priceData) => _buildPriceItem(
                    priceData['commodity'] ?? 'Unknown',
                    priceData['current_price'] ?? '₹0/quintal',
                    priceData['price_trend'] ?? 'stable',
                    priceData['price_trend'] == 'up',
                  ),
                )
                .toList())
          else ...[
            _buildPriceItem('Wheat', '₹2,150', '+5%', true),
            _buildPriceItem('Rice', '₹3,200', '-2%', false),
            _buildPriceItem('Maize', '₹1,800', '+8%', true),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceItem(
    String commodity,
    String price,
    String change,
    bool isUp,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KrushakSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KrushakColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KrushakRadius.sm),
            ),
            child: Icon(
              Icons.grain,
              color: KrushakColors.primaryGreen,
              size: KrushakIconSizes.sm,
            ),
          ),
          const SizedBox(width: KrushakSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity,
                  style: KrushakTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'per quintal',
                  style: KrushakTextStyles.caption.copyWith(
                    color: KrushakColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: KrushakTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    color: isUp ? KrushakColors.success : KrushakColors.error,
                    size: KrushakIconSizes.xs,
                  ),
                  Text(
                    change,
                    style: KrushakTextStyles.caption.copyWith(
                      color: isUp ? KrushakColors.success : KrushakColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
