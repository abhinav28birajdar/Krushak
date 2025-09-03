import 'package:flutter/material.dart';

/// Community Screen - Connect with farmers, FPOs, and agricultural community
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
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
        title: const Text('Community'),
        backgroundColor: const Color(0xFF1E523A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Discussions'),
            Tab(text: 'FPOs'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDiscussionsTab(), _buildFPOsTab(), _buildEventsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        backgroundColor: const Color(0xFF35906A),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDiscussionsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Quick Stats
          _buildQuickStats(),

          // Active Categories
          _buildActiveCategories(),

          // Recent Discussions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Discussions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E523A),
                  ),
                ),
                const SizedBox(height: 16),

                _buildDiscussionCard(
                  'Best practices for wheat farming in winter?',
                  'Looking for advice on winter wheat cultivation. What are the best varieties and techniques?',
                  'Rajesh Kumar',
                  '2 hours ago',
                  '12 replies',
                  '45 likes',
                  'Crop Farming',
                ),
                _buildDiscussionCard(
                  'Organic pesticide recommendations needed',
                  'My tomato plants are getting affected by aphids. Any organic solutions?',
                  'Priya Sharma',
                  '5 hours ago',
                  '8 replies',
                  '23 likes',
                  'Pest Control',
                ),
                _buildDiscussionCard(
                  'Government subsidy for solar water pumps?',
                  'Has anyone applied for the solar pump subsidy? What\'s the process?',
                  'Amit Singh',
                  '1 day ago',
                  '15 replies',
                  '67 likes',
                  'Government Schemes',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFPOsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My FPO
          _buildMyFPOSection(),
          const SizedBox(height: 24),

          // Nearby FPOs
          const Text(
            'Nearby FPOs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 16),

          _buildFPOCard(
            'Green Valley Farmers Producer Organization',
            'Wheat, Rice, Pulses',
            '145 members',
            '5.2 km away',
            '4.5',
            false,
          ),
          _buildFPOCard(
            'Organic Farming Collective',
            'Organic Vegetables, Fruits',
            '89 members',
            '8.7 km away',
            '4.8',
            false,
          ),
          _buildFPOCard(
            'Sustainable Agriculture FPO',
            'Mixed Farming, Dairy',
            '203 members',
            '12.1 km away',
            '4.2',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming Events
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 16),

          _buildEventCard(
            'Modern Farming Techniques Workshop',
            'Learn about latest farming technologies and sustainable practices',
            'Tomorrow, 10:00 AM',
            'Agricultural University, Delhi',
            '45 attending',
            'Workshop',
            false,
          ),
          _buildEventCard(
            'Organic Fertilizer Making Training',
            'Hands-on training for creating organic fertilizers at home',
            'Dec 25, 2024, 9:00 AM',
            'Community Center, Gurgaon',
            '32 attending',
            'Training',
            true,
          ),
          _buildEventCard(
            'Farmer\'s Market Exhibition',
            'Showcase and sell your produce directly to consumers',
            'Dec 28, 2024, 8:00 AM',
            'Central Park, Delhi',
            '156 attending',
            'Exhibition',
            false,
          ),

          const SizedBox(height: 24),

          // Past Events
          const Text(
            'Past Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 16),

          _buildPastEventCard(
            'Digital Agriculture Summit',
            'Dec 15, 2024',
            'India Gate, Delhi',
            '4.8 ★ (124 reviews)',
          ),
          _buildPastEventCard(
            'Sustainable Farming Conference',
            'Dec 10, 2024',
            'IARI, New Delhi',
            '4.6 ★ (89 reviews)',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E523A), Color(0xFF35906A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Active\nDiscussions', '247'),
          _buildStatItem('Community\nMembers', '1.2K'),
          _buildStatItem('Expert\nAnswers', '89'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildActiveCategories() {
    final categories = [
      'Crop Farming',
      'Livestock',
      'Pest Control',
      'Government Schemes',
      'Market Prices',
      'Technology',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Topics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => Chip(
                    label: Text(category),
                    backgroundColor: const Color(0xFF1E523A).withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: Color(0xFF1E523A),
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDiscussionCard(
    String title,
    String preview,
    String author,
    String time,
    String replies,
    String likes,
    String category,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF40B0B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF40B0B0),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            preview,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF35906A),
                child: Text(
                  author[0],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                author,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E523A),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    replies,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    likes,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyFPOSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF35906A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF35906A).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My FPO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delhi Farmers Collective',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E523A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Member since Jan 2023',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '267 members • Mixed Farming',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // View FPO details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF35906A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFPOCard(
    String name,
    String focus,
    String members,
    String distance,
    String rating,
    bool isJoined,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E523A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      focus,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                members,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                distance,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Join or view FPO
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isJoined
                    ? const Color(0xFF35906A)
                    : const Color(0xFF40B0B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isJoined ? 'View Details' : 'Request to Join'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String description,
    String dateTime,
    String location,
    String attending,
    String type,
    bool isRegistered,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF40B0B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF40B0B0),
                  ),
                ),
              ),
              const Spacer(),
              if (isRegistered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Registered',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                dateTime,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                attending,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Register or view event
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered
                    ? const Color(0xFF35906A)
                    : const Color(0xFF40B0B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isRegistered ? 'View Details' : 'Register'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventCard(
    String title,
    String date,
    String location,
    String rating,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E523A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date • $location',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            rating,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Discussion'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'What would you like to discuss?',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Provide more details...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Create post logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF35906A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
