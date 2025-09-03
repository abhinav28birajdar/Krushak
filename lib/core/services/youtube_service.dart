import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  static const String _apiKey =
      'YOUR_YOUTUBE_API_KEY'; // Replace with your YouTube Data API key
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  static Future<List<Map<String, dynamic>>> searchVideos(
    String query, {
    int maxResults = 10,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent('$query farming agriculture');
      final url =
          '$_baseUrl/search?part=snippet&q=$encodedQuery&type=video&maxResults=$maxResults&key=$_apiKey&regionCode=IN&relevanceLanguage=hi,en';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        return items
            .map(
              (item) => {
                'videoId': item['id']['videoId'],
                'title': item['snippet']['title'],
                'description': item['snippet']['description'],
                'thumbnail': item['snippet']['thumbnails']['medium']['url'],
                'channelTitle': item['snippet']['channelTitle'],
                'publishedAt': item['snippet']['publishedAt'],
                'url':
                    'https://www.youtube.com/watch?v=${item['id']['videoId']}',
              },
            )
            .toList()
            .cast<Map<String, dynamic>>();
      } else {
        print('YouTube API error: ${response.statusCode}');
        return _getFallbackVideos(query);
      }
    } catch (e) {
      print('Error searching YouTube videos: $e');
      return _getFallbackVideos(query);
    }
  }

  static Future<List<Map<String, dynamic>>> getFarmingChannelVideos() async {
    try {
      // Search for videos from popular farming channels
      const farmingChannels = [
        'agriculture farming techniques',
        'organic farming methods',
        'crop management tips',
        'modern farming technology',
        'irrigation techniques',
      ];

      List<Map<String, dynamic>> allVideos = [];

      for (String channelQuery in farmingChannels) {
        final videos = await searchVideos(channelQuery, maxResults: 5);
        allVideos.addAll(videos);
      }

      // Remove duplicates and return top 20
      final uniqueVideos = <String, Map<String, dynamic>>{};
      for (var video in allVideos) {
        uniqueVideos[video['videoId']] = video;
      }

      return uniqueVideos.values.take(20).toList();
    } catch (e) {
      print('Error getting farming channel videos: $e');
      return _getFallbackVideos('farming');
    }
  }

  static Future<List<Map<String, dynamic>>> getVideosByCategory(
    String category,
  ) async {
    final queries = {
      'crop_management': 'crop management techniques farming',
      'irrigation': 'irrigation systems farming water management',
      'pest_control': 'pest control organic farming natural pesticides',
      'soil_health': 'soil health improvement composting farming',
      'technology': 'modern farming technology agricultural innovations',
      'livestock': 'livestock management animal husbandry farming',
      'marketing': 'agricultural marketing farmer income strategies',
    };

    final query = queries[category] ?? 'general farming techniques';
    return await searchVideos(query, maxResults: 15);
  }

  static List<Map<String, dynamic>> _getFallbackVideos(String query) {
    return [
      {
        'videoId': 'dQw4w9WgXcQ', // Placeholder video ID
        'title': 'Modern $query Techniques',
        'description':
            'Learn the latest techniques in $query for better yields',
        'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        'channelTitle': 'Farming Expert',
        'publishedAt': DateTime.now().toIso8601String(),
        'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      },
      {
        'videoId': 'dQw4w9WgXcQ',
        'title': 'Organic $query Methods',
        'description': 'Sustainable and organic approaches to $query',
        'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        'channelTitle': 'Organic Farming',
        'publishedAt': DateTime.now().toIso8601String(),
        'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      },
      {
        'videoId': 'dQw4w9WgXcQ',
        'title': '$query Best Practices',
        'description': 'Essential best practices for successful $query',
        'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
        'channelTitle': 'Agricultural Science',
        'publishedAt': DateTime.now().toIso8601String(),
        'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      },
    ];
  }

  static String getVideoEmbedUrl(String videoId) {
    return 'https://www.youtube.com/embed/$videoId';
  }

  static String getVideoThumbnail(
    String videoId, {
    String quality = 'mqdefault',
  }) {
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }
}
