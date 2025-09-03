import 'package:flutter/material.dart';

/// Learning Screen - Educational content and community learning
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
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
        title: const Text('Learning Hub'),
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
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Show bookmarks
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'Videos'),
            Tab(text: 'Articles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCoursesTab(), _buildVideosTab(), _buildArticlesTab()],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Overview
          _buildProgressOverview(),
          const SizedBox(height: 24),

          // Featured Course
          const Text(
            'Featured Course',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 12),
          _buildFeaturedCourse(),
          const SizedBox(height: 24),

          // Available Courses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E523A),
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all courses
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildCourseCard(
            'Organic Farming Basics',
            'Learn the fundamentals of organic farming practices',
            '8 lessons • 4 hours',
            '4.8',
            '1,234 students',
            85,
            true,
          ),
          _buildCourseCard(
            'Modern Irrigation Techniques',
            'Master water-efficient irrigation methods',
            '12 lessons • 6 hours',
            '4.9',
            '892 students',
            0,
            false,
          ),
          _buildCourseCard(
            'Crop Disease Management',
            'Identify and treat common crop diseases',
            '10 lessons • 5 hours',
            '4.7',
            '756 students',
            45,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryRow(),
          const SizedBox(height: 24),

          // Recent Videos
          const Text(
            'Recent Videos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 12),

          _buildVideoCard(
            'Smart Farming with IoT Sensors',
            'Dr. Rajesh Kumar',
            '15:30',
            '2 days ago',
            '1.2K views',
          ),
          _buildVideoCard(
            'Sustainable Pest Control Methods',
            'Priya Sharma, Agricultural Expert',
            '22:45',
            '5 days ago',
            '856 views',
          ),
          _buildVideoCard(
            'Maximizing Crop Yield Naturally',
            'Farmer Success Stories',
            '18:20',
            '1 week ago',
            '2.1K views',
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reading Progress
          _buildReadingProgress(),
          const SizedBox(height: 24),

          // Latest Articles
          const Text(
            'Latest Articles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 12),

          _buildArticleCard(
            'Climate-Smart Agriculture: Future of Farming',
            'Learn how to adapt your farming practices to climate change challenges and opportunities.',
            '8 min read',
            'Yesterday',
            'Climate Change',
          ),
          _buildArticleCard(
            'Government Schemes for Farmers 2024',
            'Complete guide to all government schemes and subsidies available for farmers this year.',
            '12 min read',
            '2 days ago',
            'Government Schemes',
          ),
          _buildArticleCard(
            'Digital Marketing for Agricultural Products',
            'How to sell your produce online and reach more customers through digital platforms.',
            '15 min read',
            '3 days ago',
            'Digital Marketing',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E523A), Color(0xFF35906A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Learning Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Courses\nCompleted',
                  '3',
                  Icons.school,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'Hours\nLearned',
                  '24',
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  'Certificates\nEarned',
                  '2',
                  Icons.workspace_premium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildFeaturedCourse() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF40B0B0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF40B0B0).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF40B0B0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Sustainable Farming Practices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E523A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comprehensive course on sustainable farming methods that increase yield while protecting the environment.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              const Text(
                '15 lessons',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                '8 hours',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Start course
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40B0B0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start Course'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    String title,
    String description,
    String duration,
    String rating,
    String students,
    int progress,
    bool isEnrolled,
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
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E523A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                duration,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                students,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (isEnrolled && progress > 0) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF35906A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF35906A),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to course
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnrolled
                    ? const Color(0xFF35906A)
                    : const Color(0xFF40B0B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEnrolled
                    ? (progress > 0 ? 'Continue' : 'Start')
                    : 'Enroll Now',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    final categories = [
      {'name': 'Crop Farming', 'icon': Icons.agriculture},
      {'name': 'Livestock', 'icon': Icons.pets},
      {'name': 'Technology', 'icon': Icons.computer},
      {'name': 'Sustainability', 'icon': Icons.eco},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E523A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: const Color(0xFF1E523A),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(
    String title,
    String author,
    String duration,
    String date,
    String views,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$views • $date',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF35906A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Color(0xFF35906A), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reading Goal Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E523A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '7 of 10 articles this month',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF35906A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    String title,
    String excerpt,
    String readTime,
    String date,
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
                date,
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
            excerpt,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                readTime,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Read article
                },
                child: const Text('Read More'),
              ),
            ],
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
