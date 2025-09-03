import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import 'announcements_screen.dart';

class AnnouncementBox extends StatefulWidget {
  const AnnouncementBox({super.key});

  @override
  State<AnnouncementBox> createState() => _AnnouncementBoxState();
}

class _AnnouncementBoxState extends State<AnnouncementBox> {
  List<Map<String, dynamic>> recentAnnouncements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentAnnouncements();
  }

  Future<void> _loadRecentAnnouncements() async {
    try {
      final announcements = await SupabaseService.getAnnouncements();
      setState(() {
        // Get the 3 most recent announcements
        recentAnnouncements = announcements.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 120,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recentAnnouncements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.campaign,
                  color: KrushakColors.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Latest Announcements',
                  style: KrushakTextStyles.h5.copyWith(
                    color: KrushakColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnnouncementsScreen(),
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(color: KrushakColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),

          // Announcements List
          ...recentAnnouncements.map(
            (announcement) => _buildAnnouncementItem(announcement),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(Map<String, dynamic> announcement) {
    final category = announcement['category'] ?? 'General';
    final priority = announcement['priority'] ?? 'medium';
    final isUrgent = priority == 'high';

    return InkWell(
      onTap: () => _showAnnouncementDetails(announcement),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getCategoryIcon(category),
                size: 16,
                color: _getCategoryColor(category),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          announcement['title'] ?? 'No Title',
                          style: KrushakTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUrgent
                                ? Colors.red[800]
                                : KrushakColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUrgent)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    announcement['content'] ?? 'No content',
                    style: KrushakTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time and Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(announcement['created_at']),
                  style: KrushakTextStyles.labelSmall.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'weather alert':
        return Colors.orange;
      case 'market price':
        return Colors.green;
      case 'government scheme':
        return Colors.blue;
      case 'technology update':
        return Colors.purple;
      default:
        return KrushakColors.primaryGreen;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'weather alert':
        return Icons.warning;
      case 'market price':
        return Icons.trending_up;
      case 'government scheme':
        return Icons.account_balance;
      case 'technology update':
        return Icons.new_releases;
      default:
        return Icons.campaign;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inDays}d';
      }
    } catch (e) {
      return '';
    }
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          announcement['title'] ?? 'Announcement',
          style: KrushakTextStyles.h5,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    announcement['category'] ?? 'General',
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  announcement['category'] ?? 'General',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(
                      announcement['category'] ?? 'General',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                announcement['content'] ?? 'No content available',
                style: KrushakTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (announcement['action_url'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle action URL
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening: ${announcement['action_url']}'),
                  ),
                );
              },
              child: Text(announcement['action_text'] ?? 'Learn More'),
            ),
        ],
      ),
    );
  }
}
