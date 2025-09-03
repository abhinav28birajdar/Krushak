import 'package:flutter/material.dart';

/// Market Screen - Marketplace for produce and mandi prices
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        backgroundColor: const Color(0xFF1E523A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Sell Produce'),
            Tab(text: 'Buy Produce'),
            Tab(text: 'Mandi Prices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSellProduceTab(),
          _buildBuyProduceTab(),
          _buildMandiPricesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showListProduceBottomSheet();
        },
        backgroundColor: const Color(0xFF35906A),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSellProduceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Listings Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Listings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E523A),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showListProduceBottomSheet(),
                icon: const Icon(Icons.add),
                label: const Text('Add Listing'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // My Produce Listings
          _buildProduceListingCard(
            'Premium Basmati Rice',
            '500 kg',
            '₹45/kg',
            'Active',
            '5 inquiries',
            true,
          ),
          _buildProduceListingCard(
            'Organic Wheat',
            '200 kg',
            '₹32/kg',
            'Sold',
            'Completed',
            true,
          ),
          _buildProduceListingCard(
            'Fresh Tomatoes',
            '100 kg',
            '₹25/kg',
            'Expired',
            'Relist?',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildBuyProduceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filters
          _buildSearchAndFilters(),
          const SizedBox(height: 16),

          const Text(
            'Available Produce',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 16),

          // Available Produce Listings
          _buildProduceListingCard(
            'Premium Wheat',
            '1000 kg',
            '₹30/kg',
            'Available',
            '15 km away',
            false,
          ),
          _buildProduceListingCard(
            'Organic Rice',
            '750 kg',
            '₹42/kg',
            'Available',
            '8 km away',
            false,
          ),
          _buildProduceListingCard(
            'Fresh Vegetables',
            '300 kg',
            '₹20/kg',
            'Available',
            '12 km away',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildMandiPricesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Selection
          _buildMarketSelection(),
          const SizedBox(height: 16),

          const Text(
            'Today\'s Prices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 16),

          // Price Cards
          _buildPriceCard('Wheat', '₹1,850 - ₹2,050', '₹1,950', '+2.5%', true),
          _buildPriceCard(
            'Rice (Basmati)',
            '₹4,200 - ₹4,800',
            '₹4,500',
            '+1.2%',
            true,
          ),
          _buildPriceCard(
            'Cotton',
            '₹5,500 - ₹6,200',
            '₹5,850',
            '-0.8%',
            false,
          ),
          _buildPriceCard('Sugarcane', '₹320 - ₹350', '₹335', '+0.5%', true),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search produce...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E523A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              // Show filters
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarketSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E523A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF1E523A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Market',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Text(
                  'Delhi APMC Mandi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E523A),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Change market
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildProduceListingCard(
    String name,
    String quantity,
    String price,
    String status,
    String detail,
    bool isMyListing,
  ) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
      case 'available':
        statusColor = Colors.green;
        break;
      case 'sold':
        statusColor = Colors.blue;
        break;
      case 'expired':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E523A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity: $quantity',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Price: $price',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF35906A),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    detail,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle action based on type
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMyListing
                          ? const Color(0xFF35906A)
                          : const Color(0xFF40B0B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isMyListing ? 'View' : 'Inquire'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    String crop,
    String priceRange,
    String avgPrice,
    String change,
    bool isIncrease,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E523A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Range: $priceRange',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  'Average: $avgPrice',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF35906A),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isIncrease
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIncrease ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isIncrease ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isIncrease ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // View price history
                },
                child: const Text(
                  'View History',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showListProduceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'List Your Produce',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E523A),
                ),
              ),
            ),
            const Expanded(
              child: Center(child: Text('Produce listing form would go here')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
