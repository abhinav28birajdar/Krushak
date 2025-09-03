import 'package:flutter/material.dart';

/// Account Screen - User profile, settings, and app preferences
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            // Account Options
            _buildAccountOptions(),

            // App Settings
            _buildAppSettings(),

            // Support & Info
            _buildSupportInfo(),

            // Logout Section
            _buildLogoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E523A), Color(0xFF35906A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile Picture
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: const NetworkImage(
                        'https://via.placeholder.com/150', // Placeholder profile image
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF40B0B0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // User Info
              const Text(
                'Rajesh Kumar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Wheat & Rice Farmer',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Delhi, India',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Farms', '2'),
                  Container(width: 1, height: 30, color: Colors.white30),
                  _buildStatItem('Years', '15'),
                  Container(width: 1, height: 30, color: Colors.white30),
                  _buildStatItem('Crops', '4'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
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
            () {
              // Navigate to profile settings
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.agriculture_outlined,
            'Farm Management',
            'Manage your farms and crops',
            () {
              // Navigate to farm management
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.account_balance_wallet_outlined,
            'Financial Overview',
            'View earnings, expenses, credits',
            () {
              // Navigate to financial overview
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.local_shipping_outlined,
            'Order History',
            'Track your orders and deliveries',
            () {
              // Navigate to order history
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.eco_outlined,
            'Carbon Credits',
            'View your sustainability impact',
            () {
              // Navigate to carbon credits
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
            () {
              // Navigate to notification settings
            },
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Toggle notifications
              },
              activeColor: const Color(0xFF35906A),
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
            () {
              // Toggle dark mode
            },
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Toggle dark mode
              },
              activeColor: const Color(0xFF35906A),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.wifi_off_outlined,
            'Offline Mode',
            'Enable offline functionality',
            () {
              // Configure offline mode
            },
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Toggle offline mode
              },
              activeColor: const Color(0xFF35906A),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.security_outlined,
            'Privacy & Security',
            'Manage data and security settings',
            () {
              // Navigate to privacy settings
            },
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
            () {
              // Navigate to help center
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.feedback_outlined,
            'Send Feedback',
            'Share your thoughts with us',
            () {
              // Open feedback form
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.star_outline,
            'Rate App',
            'Rate Krushak on Play Store',
            () {
              // Open app store for rating
            },
          ),
          _buildDivider(),
          _buildOptionTile(
            Icons.share_outlined,
            'Share App',
            'Invite friends to use Krushak',
            () {
              // Share app
            },
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout),
                const SizedBox(width: 8),
                const Text(
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
          color: const Color(0xFF1E523A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF1E523A), size: 20),
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
                // Change language
              },
            ),
            RadioListTile<String>(
              title: const Text('हिंदी (Hindi)'),
              value: 'hi',
              groupValue: 'hi',
              onChanged: (value) {
                Navigator.pop(context);
                // Change language
              },
            ),
            RadioListTile<String>(
              title: const Text('ਪੰਜਾਬੀ (Punjabi)'),
              value: 'pa',
              groupValue: 'hi',
              onChanged: (value) {
                Navigator.pop(context);
                // Change language
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
                color: const Color(0xFF1E523A),
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
              // Perform logout
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
