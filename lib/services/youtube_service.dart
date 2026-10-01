import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeService {
  // Invidious public instances
  final List<String> _instances = [
    'https://invidious.snopyta.org',
    'https://yewtu.be',
    'https://invidious.kavin.rocks',
  ];

  Future<List<Map<String, String>>> searchSongs(String query) async {
    for (final instance in _instances) {
      try {
        final url = Uri.parse(
          '$instance/api/v1/search?q=${Uri.encodeComponent(query)}&type=video'
        );
        final res = await http.get(url).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final List data = jsonDecode(res.body);
          return data.take(20).map((v) => {
            'id': v['videoId'].toString(),
            'title': v['title'].toString(),
            'artist': v['author'].toString(),
            'thumbnail': 'https://img.youtube.com/vi/${v['videoId']}/0.jpg',
          }).toList();
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }

  Future<String?> getStreamUrl(String videoId) async {
    for (final instance in _instances) {
      try {
        final url = Uri.parse('$instance/api/v1/videos/$videoId');
        final res = await http.get(url).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final formats = data['adaptiveFormats'] as List?;
          if (formats != null) {
            final audioFormats = formats
              .where((f) => f['type'].toString().contains('audio'))
              .toList();
            if (audioFormats.isNotEmpty) {
              audioFormats.sort((a, b) =>
                (b['bitrate'] ?? 0).compareTo(a['bitrate'] ?? 0));
              return audioFormats.first['url'].toString();
            }
          }
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  void dispose() {}
}
