import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/presentation/widgets/profile_settings_screen.dart';
import '../../../../shared/presentation/widgets/farm_management_screen.dart';
import '../../../../shared/presentation/widgets/financial_overview_screen.dart';

/// Account Screen - User profile, settings, and app preferences
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _farms = [];
  List<Map<String, dynamic>> _financialRecords = [];
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _userData = await SupabaseService.getCurrentUser();
      _farms = await SupabaseService.getUserFarms();
      _financialRecords = await SupabaseService.getFinancialRecords();
      _orders = await SupabaseService.getUserOrders();
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: KrushakColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: KrushakColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStatisticsCards(),
            _buildFarmSection(),
            _buildFinancialSection(),
            _buildAccountOptions(),
            _buildAppSettings(),
            _buildSupportInfo(),
            _buildLogoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [KrushakColors.primaryGreen, KrushakColors.secondaryGreen],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: _userData?['avatar_url'] != null
                        ? NetworkImage(_userData!['avatar_url'])
                        : null,
                    child: _userData?['avatar_url'] == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: KrushakColors.primaryGreen,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData?['full_name'] ?? 'Farmer',
                          style: KrushakTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData?['email'] ?? 'farmer@krushak.com',
                          style: KrushakTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _userData?['farmer_type'] ?? 'Progressive Farmer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileSettingsScreen(userData: _userData),
                      ),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickStat(
                    'Experience',
                    '${_userData?['experience_years'] ?? 5} Years',
                    Icons.timeline,
                  ),
                  _buildQuickStat(
                    'Location',
                    _userData?['district'] ?? 'India',
                    Icons.location_on,
                  ),
                  _buildQuickStat(
                    'Farms',
                    _farms.length.toString(),
                    Icons.landscape,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Overview', style: KrushakTextStyles.h4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  '₹${_calculateTotalRevenue()}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Expenses',
                  '₹${_calculateTotalExpenses()}',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Orders',
                  _orders
                      .where((o) => o['status'] == 'pending')
                      .length
                      .toString(),
                  Icons.shopping_cart,
                  KrushakColors.accentBrown,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Area',
                  '${_calculateTotalFarmArea()} acres',
                  Icons.landscape,
                  KrushakColors.secondaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: KrushakTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: KrushakTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalRevenue() {
    final revenue = _financialRecords
        .where((record) => record['type'] == 'income')
        .fold(0.0, (sum, record) => sum + (record['amount'] ?? 0));
    return revenue.toStringAsFixed(0);
  }

  String _calculateTotalExpenses() {
    final expenses = _financialRecords
        .where((record) => record['type'] == 'expense')
        .fold(0.0, (sum, record) => sum + (record['amount'] ?? 0));
    return expenses.toStringAsFixed(0);
  }

  String _calculateTotalFarmArea() {
    final totalArea = _farms.fold(
      0.0,
      (sum, farm) => sum + (farm['size_acres'] ?? 0),
    );
    return totalArea.toStringAsFixed(1);
  }

  Widget _buildFarmSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Farms', style: KrushakTextStyles.h4),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmManagementScreen(),
                  ),
                ),
                child: const Text('Manage Farms'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_farms.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _farms.length,
                itemBuilder: (context, index) {
                  final farm = _farms[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm['name'] ?? 'Farm ${index + 1}',
                          style: KrushakTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          farm['location'] ?? 'Unknown Location',
                          style: KrushakTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.landscape,
                              size: 16,
                              color: KrushakColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${farm['size_acres'] ?? 0} acres',
                              style: KrushakTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.add_business, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No farms added yet',
                      style: KrushakTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Financial Overview', style: KrushakTextStyles.h4),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinancialOverviewScreen(),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  KrushakColors.accentBrown.withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: KrushakColors.accentBrown.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Profit',
                          style: KrushakTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '₹${(double.parse(_calculateTotalRevenue()) - double.parse(_calculateTotalExpenses())).toStringAsFixed(0)}',
                          style: KrushakTextStyles.h3.copyWith(
                            color: KrushakColors.accentBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      color: KrushakColors.accentBrown,
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Income',
                            style: KrushakTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '₹${_calculateTotalRevenue()}',
                            style: KrushakTextStyles.bodyLarge.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Expenses',
                            style: KrushakTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '₹${_calculateTotalExpenses()}',
                            style: KrushakTextStyles.bodyLarge.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  Widget _buildAccountOptions() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            Icons.person_outline,
            'Profile Settings',
            'Edit personal information',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfileSettingsScreen(userData: _userData),
              ),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.agriculture_outlined,
            'Farm Management',
            'Manage your farms and crops',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FarmManagementScreen(),
              ),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.account_balance_wallet_outlined,
            'Financial Overview',
            'View earnings, expenses, credits',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinancialOverviewScreen(),
              ),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.local_shipping_outlined,
            'Order History',
            'Track your orders and deliveries',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order History feature coming soon!'),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.eco_outlined,
            'Carbon Credits',
            'View your sustainability impact',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Carbon Credits feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            Icons.notifications_outlined,
            'Notifications',
            'Manage push notifications',
            () {},
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: KrushakColors.primaryGreen,
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.language_outlined,
            'Language',
            'Hindi (हिंदी)',
            () {
              _showLanguageDialog();
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.dark_mode_outlined,
            'Dark Mode',
            'Switch to dark theme',
            () {},
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: KrushakColors.primaryGreen,
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.wifi_off_outlined,
            'Offline Mode',
            'Enable offline functionality',
            () {},
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: KrushakColors.primaryGreen,
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.security_outlined,
            'Privacy & Security',
            'Manage data and security settings',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSupportInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            Icons.help_outline,
            'Help Center',
            'Get help and support',
            () {},
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.feedback_outlined,
            'Send Feedback',
            'Share your thoughts with us',
            () {},
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.star_outline,
            'Rate App',
            'Rate Krushak on Play Store',
            () {},
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.share_outlined,
            'Share App',
            'Invite friends to use Krushak',
            () {},
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.info_outline,
            'About',
            'App version 1.0.0',
            () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showLogoutDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade200),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Version 1.0.0 (Build 1)',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: KrushakColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: KrushakColors.primaryGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E523A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: 'hi',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('हिंदी (Hindi)'),
              value: 'hi',
              groupValue: 'hi',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('ਪੰਜਾਬੀ (Punjabi)'),
              value: 'pa',
              groupValue: 'hi',
              onChanged: (value) {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: KrushakColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.agriculture,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('About Krushak'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Krushak - FarmerOS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E523A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Empowering farmers with AI-driven insights, sustainable practices, and direct market access.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Version: 1.0.0\nBuild: 1\nRelease Date: December 2024',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
