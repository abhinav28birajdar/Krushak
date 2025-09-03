import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

/// Market Screen with real-time pricing and marketplace features
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KrushakColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Market',
          style: KrushakTextStyles.h4.copyWith(
            color: KrushakColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: KrushakColors.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: KrushakColors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: KrushakColors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: KrushakColors.white,
          unselectedLabelColor: KrushakColors.white.withOpacity(0.7),
          indicatorColor: KrushakColors.white,
          tabs: const [
            Tab(text: 'Buy'),
            Tab(text: 'Sell'),
            Tab(text: 'Prices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBuyTab(), _buildSellTab(), _buildPricesTab()],
      ),
    );
  }

  Widget _buildBuyTab() {
    return ListView(
      padding: const EdgeInsets.all(KrushakSpacing.md),
      children: [
        // Featured Products
        Text(
          'Featured Products',
          style: KrushakTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: KrushakColors.primaryGreen,
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => _buildFeaturedProductCard(index),
          ),
        ),
        const SizedBox(height: KrushakSpacing.lg),

        // Categories
        Text(
          'Categories',
          style: KrushakTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: KrushakColors.primaryGreen,
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: KrushakSpacing.md,
          mainAxisSpacing: KrushakSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildCategoryCard('Seeds', Icons.eco, 120),
            _buildCategoryCard('Fertilizers', Icons.grass, 85),
            _buildCategoryCard('Tools', Icons.build, 45),
            _buildCategoryCard('Equipment', Icons.agriculture, 23),
          ],
        ),
      ],
    );
  }

  Widget _buildSellTab() {
    return ListView(
      padding: const EdgeInsets.all(KrushakSpacing.md),
      children: [
        // Sell Your Produce
        Container(
          padding: const EdgeInsets.all(KrushakSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                KrushakColors.secondaryGreen.withOpacity(0.1),
                KrushakColors.accentTeal.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(KrushakRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sell Your Produce',
                style: KrushakTextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: KrushakColors.primaryGreen,
                ),
              ),
              const SizedBox(height: KrushakSpacing.sm),
              Text(
                'Get the best prices for your crops directly from verified buyers',
                style: KrushakTextStyles.bodyMedium.copyWith(
                  color: KrushakColors.mediumGray,
                ),
              ),
              const SizedBox(height: KrushakSpacing.md),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: KrushakColors.primaryGreen,
                  foregroundColor: KrushakColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KrushakRadius.button),
                  ),
                ),
                child: const Text('List Your Produce'),
              ),
            ],
          ),
        ),
        const SizedBox(height: KrushakSpacing.lg),

        // Your Listings
        Text(
          'Your Listings',
          style: KrushakTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: KrushakColors.primaryGreen,
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),
        ...List.generate(3, (index) => _buildSellingItem(index)),
      ],
    );
  }

  Widget _buildPricesTab() {
    return ListView(
      padding: const EdgeInsets.all(KrushakSpacing.md),
      children: [
        // Live Market Prices
        Container(
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
                children: [
                  Icon(
                    Icons.trending_up,
                    color: KrushakColors.success,
                    size: KrushakIconSizes.md,
                  ),
                  const SizedBox(width: KrushakSpacing.sm),
                  Text(
                    'Live Market Prices',
                    style: KrushakTextStyles.h5.copyWith(
                      fontWeight: FontWeight.bold,
                      color: KrushakColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KrushakSpacing.sm),
              Text(
                'Updated every 30 minutes',
                style: KrushakTextStyles.caption.copyWith(
                  color: KrushakColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),

        // Price List
        ...List.generate(8, (index) => _buildPriceItem(index)),
      ],
    );
  }

  Widget _buildFeaturedProductCard(int index) {
    final products = [
      {'name': 'Organic Wheat Seeds', 'price': '₹450/kg', 'rating': '4.8'},
      {'name': 'NPK Fertilizer', 'price': '₹890/50kg', 'rating': '4.6'},
      {'name': 'Spray Pump', 'price': '₹2,500', 'rating': '4.7'},
      {'name': 'Drip Irrigation Kit', 'price': '₹8,900', 'rating': '4.9'},
      {'name': 'Soil pH Meter', 'price': '₹1,200', 'rating': '4.5'},
    ];

    final product = products[index % products.length];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: KrushakSpacing.md),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: KrushakColors.lightGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(KrushakRadius.lg),
                topRight: Radius.circular(KrushakRadius.lg),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                color: KrushakColors.mediumGray,
                size: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KrushakSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  style: KrushakTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: KrushakSpacing.xs),
                Text(
                  product['price']!,
                  style: KrushakTextStyles.labelLarge.copyWith(
                    color: KrushakColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: KrushakColors.warning,
                      size: KrushakIconSizes.xs,
                    ),
                    Text(
                      product['rating']!,
                      style: KrushakTextStyles.caption.copyWith(
                        color: KrushakColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.sm),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: KrushakColors.primaryGreen,
            size: KrushakIconSizes.md,
          ),
          const SizedBox(height: KrushakSpacing.xs),
          Flexible(
            child: Text(
              name,
              style: KrushakTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count items',
            style: KrushakTextStyles.caption.copyWith(
              color: KrushakColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellingItem(int index) {
    final items = [
      {
        'crop': 'Wheat',
        'quantity': '50 quintal',
        'price': '₹2,150/quintal',
        'status': 'Active',
      },
      {
        'crop': 'Rice',
        'quantity': '30 quintal',
        'price': '₹3,200/quintal',
        'status': 'Sold',
      },
      {
        'crop': 'Maize',
        'quantity': '25 quintal',
        'price': '₹1,800/quintal',
        'status': 'Negotiating',
      },
    ];

    final item = items[index];
    final isActive = item['status'] == 'Active';
    final isSold = item['status'] == 'Sold';

    return Container(
      margin: const EdgeInsets.only(bottom: KrushakSpacing.md),
      padding: const EdgeInsets.all(KrushakSpacing.md),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: KrushakColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KrushakRadius.sm),
            ),
            child: Icon(
              Icons.grain,
              color: KrushakColors.primaryGreen,
              size: KrushakIconSizes.md,
            ),
          ),
          const SizedBox(width: KrushakSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['crop']!,
                  style: KrushakTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item['quantity']!,
                  style: KrushakTextStyles.bodySmall.copyWith(
                    color: KrushakColors.mediumGray,
                  ),
                ),
                Text(
                  item['price']!,
                  style: KrushakTextStyles.labelMedium.copyWith(
                    color: KrushakColors.primaryGreen,
                    fontWeight: FontWeight.w600,
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
              color: isSold
                  ? KrushakColors.success.withOpacity(0.1)
                  : isActive
                  ? KrushakColors.info.withOpacity(0.1)
                  : KrushakColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KrushakRadius.sm),
            ),
            child: Text(
              item['status']!,
              style: KrushakTextStyles.caption.copyWith(
                color: isSold
                    ? KrushakColors.success
                    : isActive
                    ? KrushakColors.info
                    : KrushakColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(int index) {
    final prices = [
      {'commodity': 'Wheat', 'price': '₹2,150', 'change': '+5%', 'isUp': true},
      {'commodity': 'Rice', 'price': '₹3,200', 'change': '-2%', 'isUp': false},
      {'commodity': 'Maize', 'price': '₹1,800', 'change': '+8%', 'isUp': true},
      {'commodity': 'Barley', 'price': '₹1,950', 'change': '+3%', 'isUp': true},
      {'commodity': 'Gram', 'price': '₹4,500', 'change': '-1%', 'isUp': false},
      {
        'commodity': 'Sugarcane',
        'price': '₹350',
        'change': '+2%',
        'isUp': true,
      },
      {'commodity': 'Cotton', 'price': '₹5,800', 'change': '+7%', 'isUp': true},
      {
        'commodity': 'Groundnut',
        'price': '₹6,200',
        'change': '-4%',
        'isUp': false,
      },
    ];

    final priceData = prices[index];
    final isUp = priceData['isUp'] as bool;
    final commodity = priceData['commodity'] as String;
    final price = priceData['price'] as String;
    final change = priceData['change'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: KrushakSpacing.sm),
      padding: const EdgeInsets.all(KrushakSpacing.md),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
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
