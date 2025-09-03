import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

/// Learning Screen with courses, tutorials, and knowledge base
class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen>
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
          'Learning',
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
            icon: const Icon(
              Icons.bookmark_outline,
              color: KrushakColors.white,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: KrushakColors.white,
          unselectedLabelColor: KrushakColors.white.withOpacity(0.7),
          indicatorColor: KrushakColors.white,
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
    return ListView(
      padding: const EdgeInsets.all(KrushakSpacing.md),
      children: [
        // Featured Course
        _buildFeaturedCourse(),
        const SizedBox(height: KrushakSpacing.lg),

        // Course Categories
        Text(
          'Course Categories',
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
          childAspectRatio: 1.2,
          children: [
            _buildCategoryCard('Crop Management', Icons.grass, 12),
            _buildCategoryCard('Soil Health', Icons.landscape, 8),
            _buildCategoryCard('Pest Control', Icons.bug_report, 6),
            _buildCategoryCard('Market Skills', Icons.trending_up, 10),
          ],
        ),
        const SizedBox(height: KrushakSpacing.lg),

        // Popular Courses
        Text(
          'Popular Courses',
          style: KrushakTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: KrushakColors.primaryGreen,
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),
        ...List.generate(5, (index) => _buildCourseCard(index)),
      ],
    );
  }

  Widget _buildVideosTab() {
    return ListView(
      padding: const EdgeInsets.all(KrushakSpacing.md),
      children: [
        // Video Categories
        _buildVideoCategories(),
        const SizedBox(height: KrushakSpacing.lg),

        // Latest Videos
        Text(
          'Latest Videos',
          style: KrushakTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: KrushakColors.primaryGreen,
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),
        ...List.generate(8, (index) => _buildVideoCard(index)),
      ],
    );
  }

  Widget _buildArticlesTab() {
    return ListView(
      padding: const EdgeInsets.all(KrushakSpacing.md),
      children: [
        // Article of the Day
        _buildArticleOfTheDay(),
        const SizedBox(height: KrushakSpacing.lg),

        // Recent Articles
        Text(
          'Recent Articles',
          style: KrushakTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: KrushakColors.primaryGreen,
          ),
        ),
        const SizedBox(height: KrushakSpacing.md),
        ...List.generate(10, (index) => _buildArticleCard(index)),
      ],
    );
  }

  Widget _buildFeaturedCourse() {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrushakColors.accentTeal.withOpacity(0.8),
            KrushakColors.secondaryGreen.withOpacity(0.8),
          ],
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KrushakSpacing.sm,
                  vertical: KrushakSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: KrushakColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(KrushakRadius.sm),
                ),
                child: Text(
                  'FEATURED',
                  style: KrushakTextStyles.caption.copyWith(
                    color: KrushakColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KrushakSpacing.md),
          Text(
            'Complete Guide to Organic Farming',
            style: KrushakTextStyles.h4.copyWith(
              color: KrushakColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: KrushakSpacing.sm),
          Text(
            'Learn sustainable farming practices that increase yield while protecting the environment.',
            style: KrushakTextStyles.bodyMedium.copyWith(
              color: KrushakColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: KrushakSpacing.md),
          Row(
            children: [
              Icon(
                Icons.person,
                color: KrushakColors.white.withOpacity(0.8),
                size: KrushakIconSizes.xs,
              ),
              const SizedBox(width: KrushakSpacing.xs),
              Text(
                '1,234 enrolled',
                style: KrushakTextStyles.caption.copyWith(
                  color: KrushakColors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: KrushakSpacing.md),
              Icon(
                Icons.access_time,
                color: KrushakColors.white.withOpacity(0.8),
                size: KrushakIconSizes.xs,
              ),
              const SizedBox(width: KrushakSpacing.xs),
              Text(
                '8 hours',
                style: KrushakTextStyles.caption.copyWith(
                  color: KrushakColors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: KrushakSpacing.md),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: KrushakColors.white,
              foregroundColor: KrushakColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KrushakRadius.button),
              ),
            ),
            child: const Text('Start Learning'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, int courseCount) {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.md),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: KrushakColors.primaryGreen,
            size: KrushakIconSizes.lg,
          ),
          const SizedBox(height: KrushakSpacing.sm),
          Text(
            name,
            style: KrushakTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '$courseCount courses',
            style: KrushakTextStyles.caption.copyWith(
              color: KrushakColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(int index) {
    final courses = [
      {
        'title': 'Smart Irrigation Techniques',
        'instructor': 'Dr. Rajesh Sharma',
        'duration': '4 hours',
        'students': '856',
        'level': 'Beginner',
      },
      {
        'title': 'Pest Management Strategies',
        'instructor': 'Prof. Meera Gupta',
        'duration': '6 hours',
        'students': '1,234',
        'level': 'Intermediate',
      },
      {
        'title': 'Crop Rotation Benefits',
        'instructor': 'Farmer Suresh Kumar',
        'duration': '3 hours',
        'students': '672',
        'level': 'Beginner',
      },
      {
        'title': 'Digital Marketing for Farmers',
        'instructor': 'Priya Patel',
        'duration': '5 hours',
        'students': '445',
        'level': 'Advanced',
      },
      {
        'title': 'Soil Testing & Analysis',
        'instructor': 'Dr. Anand Singh',
        'duration': '7 hours',
        'students': '998',
        'level': 'Intermediate',
      },
    ];

    final course = courses[index % courses.length];

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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: KrushakColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(KrushakRadius.sm),
            ),
            child: Icon(
              Icons.play_circle_outline,
              color: KrushakColors.primaryGreen,
              size: KrushakIconSizes.lg,
            ),
          ),
          const SizedBox(width: KrushakSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title']!,
                  style: KrushakTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: KrushakSpacing.xs),
                Text(
                  'by ${course['instructor']}',
                  style: KrushakTextStyles.bodySmall.copyWith(
                    color: KrushakColors.mediumGray,
                  ),
                ),
                const SizedBox(height: KrushakSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: KrushakColors.mediumGray,
                      size: KrushakIconSizes.xs,
                    ),
                    const SizedBox(width: KrushakSpacing.xs),
                    Text(
                      course['duration']!,
                      style: KrushakTextStyles.caption.copyWith(
                        color: KrushakColors.mediumGray,
                      ),
                    ),
                    const SizedBox(width: KrushakSpacing.sm),
                    Icon(
                      Icons.person,
                      color: KrushakColors.mediumGray,
                      size: KrushakIconSizes.xs,
                    ),
                    const SizedBox(width: KrushakSpacing.xs),
                    Text(
                      course['students']!,
                      style: KrushakTextStyles.caption.copyWith(
                        color: KrushakColors.mediumGray,
                      ),
                    ),
                  ],
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
              color: _getLevelColor(course['level']!).withOpacity(0.1),
              borderRadius: BorderRadius.circular(KrushakRadius.sm),
            ),
            child: Text(
              course['level']!,
              style: KrushakTextStyles.caption.copyWith(
                color: _getLevelColor(course['level']!),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCategories() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All', true),
          _buildCategoryChip('Crop Care', false),
          _buildCategoryChip('Technology', false),
          _buildCategoryChip('Market Tips', false),
          _buildCategoryChip('Interviews', false),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: KrushakSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: KrushakColors.lightGray,
        selectedColor: KrushakColors.primaryGreen,
        labelStyle: KrushakTextStyles.labelSmall.copyWith(
          color: isSelected ? KrushakColors.white : KrushakColors.mediumGray,
        ),
      ),
    );
  }

  Widget _buildVideoCard(int index) {
    final videos = [
      {
        'title': 'Modern Drip Irrigation Setup',
        'channel': 'Smart Farming TV',
        'views': '25K',
        'duration': '12:45',
      },
      {
        'title': 'Organic Pest Control Methods',
        'channel': 'EcoFarm Channel',
        'views': '18K',
        'duration': '8:30',
      },
      {
        'title': 'Soil Health Assessment',
        'channel': 'Agriculture Today',
        'views': '32K',
        'duration': '15:20',
      },
      {
        'title': 'Market Price Analysis',
        'channel': 'Farm Business',
        'views': '12K',
        'duration': '6:15',
      },
    ];

    final video = videos[index % videos.length];

    return Container(
      margin: const EdgeInsets.only(bottom: KrushakSpacing.md),
      decoration: BoxDecoration(
        color: KrushakColors.white,
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        boxShadow: KrushakShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: KrushakColors.lightGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(KrushakRadius.lg),
                topRight: Radius.circular(KrushakRadius.lg),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: KrushakColors.mediumGray,
                    size: 48,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KrushakSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['duration']!,
                      style: KrushakTextStyles.caption.copyWith(
                        color: KrushakColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KrushakSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title']!,
                  style: KrushakTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: KrushakSpacing.xs),
                Text(
                  video['channel']!,
                  style: KrushakTextStyles.bodySmall.copyWith(
                    color: KrushakColors.mediumGray,
                  ),
                ),
                const SizedBox(height: KrushakSpacing.xs),
                Text(
                  '${video['views']} views',
                  style: KrushakTextStyles.caption.copyWith(
                    color: KrushakColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleOfTheDay() {
    return Container(
      padding: const EdgeInsets.all(KrushakSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrushakColors.primaryGreen.withOpacity(0.1),
            KrushakColors.secondaryGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(KrushakRadius.lg),
        border: Border.all(color: KrushakColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article,
                color: KrushakColors.primaryGreen,
                size: KrushakIconSizes.md,
              ),
              const SizedBox(width: KrushakSpacing.sm),
              Text(
                'Article of the Day',
                style: KrushakTextStyles.h5.copyWith(
                  color: KrushakColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: KrushakSpacing.md),
          Text(
            'Climate-Smart Agriculture: Adapting to Changing Weather Patterns',
            style: KrushakTextStyles.h6.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: KrushakSpacing.sm),
          Text(
            'Learn how to make your farming practices resilient to climate change while maintaining productivity...',
            style: KrushakTextStyles.bodyMedium.copyWith(
              color: KrushakColors.mediumGray,
            ),
          ),
          const SizedBox(height: KrushakSpacing.md),
          Row(
            children: [
              Text(
                'Dr. Kavitha Nair',
                style: KrushakTextStyles.labelSmall.copyWith(
                  color: KrushakColors.mediumGray,
                ),
              ),
              const SizedBox(width: KrushakSpacing.md),
              Text(
                '5 min read',
                style: KrushakTextStyles.labelSmall.copyWith(
                  color: KrushakColors.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(int index) {
    final articles = [
      {
        'title': 'Maximizing Crop Yield with Precision Agriculture',
        'author': 'Dr. Ramesh Kumar',
        'readTime': '8 min',
        'category': 'Technology',
      },
      {
        'title': 'Understanding Soil Micronutrients',
        'author': 'Prof. Sunita Sharma',
        'readTime': '6 min',
        'category': 'Soil Health',
      },
      {
        'title': 'Integrated Pest Management Strategies',
        'author': 'Farmer Raj Singh',
        'readTime': '12 min',
        'category': 'Pest Control',
      },
      {
        'title': 'Digital Tools for Farm Management',
        'author': 'Tech Expert Priya',
        'readTime': '10 min',
        'category': 'Technology',
      },
    ];

    final article = articles[index % articles.length];

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
              Icons.article,
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
                  article['title']!,
                  style: KrushakTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: KrushakSpacing.xs),
                Text(
                  'by ${article['author']}',
                  style: KrushakTextStyles.bodySmall.copyWith(
                    color: KrushakColors.mediumGray,
                  ),
                ),
                const SizedBox(height: KrushakSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KrushakSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: KrushakColors.accentTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(KrushakRadius.sm),
                      ),
                      child: Text(
                        article['category']!,
                        style: KrushakTextStyles.caption.copyWith(
                          color: KrushakColors.accentTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: KrushakSpacing.sm),
                    Text(
                      article['readTime']!,
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

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return KrushakColors.success;
      case 'intermediate':
        return KrushakColors.warning;
      case 'advanced':
        return KrushakColors.error;
      default:
        return KrushakColors.mediumGray;
    }
  }
}
