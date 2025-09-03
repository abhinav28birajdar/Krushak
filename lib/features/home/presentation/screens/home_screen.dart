import 'package:flutter/material.dart';

/// Home Screen - Main dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning, Farmer!'),
        backgroundColor: const Color(0xFF1E523A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Card
            _buildWeatherCard(),
            const SizedBox(height: 16),

            // Quick Actions
            _buildQuickActionsSection(),
            const SizedBox(height: 16),

            // Farm Snapshot
            _buildFarmSnapshotCard(),
            const SizedBox(height: 16),

            // Alerts & Recommendations
            _buildAlertsSection(),
            const SizedBox(height: 16),

            // Recent Activity
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF35906A), Color(0xFF40B0B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Weather',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '28°C',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Partly Cloudy',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const Icon(Icons.wb_cloudy, color: Colors.white, size: 48),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail('Humidity', '65%'),
              _buildWeatherDetail('Wind', '12 km/h'),
              _buildWeatherDetail('Rain', '20%'),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E523A),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildQuickActionCard(
              'Crop Diagnosis',
              Icons.local_hospital,
              const Color(0xFF1E523A),
              () {},
            ),
            _buildQuickActionCard(
              'Log Practice',
              Icons.eco,
              const Color(0xFF35906A),
              () {},
            ),
            _buildQuickActionCard(
              'Market Prices',
              Icons.trending_up,
              const Color(0xFF40B0B0),
              () {},
            ),
            _buildQuickActionCard(
              'Apply Loan',
              Icons.account_balance,
              const Color(0xFF35906A),
              () {},
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmSnapshotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              const Text(
                'My Farm Snapshot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E523A),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSnapshotItem('Total Area', '5.2 acres')),
              Expanded(child: _buildSnapshotItem('Active Crops', '3')),
              Expanded(child: _buildSnapshotItem('Carbon Credits', '124')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E523A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alerts & Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E523A),
          ),
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          'Weather Alert',
          'Heavy rain expected tomorrow. Secure your crops.',
          Icons.warning,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildAlertCard(
          'Market Update',
          'Wheat prices increased by 5% this week.',
          Icons.trending_up,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E523A),
          ),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          'Crop Diagnosis',
          'Wheat health analysis completed',
          '2 hours ago',
          Icons.local_hospital,
        ),
        _buildActivityItem(
          'Sustainable Practice',
          'Organic fertilizer application logged',
          '1 day ago',
          Icons.eco,
        ),
        _buildActivityItem(
          'Market Trade',
          'Rice sold to Buyer ABC',
          '3 days ago',
          Icons.shopping_cart,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E523A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1E523A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
