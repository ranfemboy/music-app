import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeService {
  final _client = http.Client();

  // Piped instances - handle decrypt otomatis
  final List<String> _pipedInstances = [
    'https://pipedapi.kavin.rocks',
    'https://piped-api.garudalinux.org',
    'https://api.piped.projectsegfau.lt',
    'https://pipedapi.adminforge.de',
  ];

  Future<List<Map<String, String>>> searchSongs(String query) async {
    for (final instance in _pipedInstances) {
      try {
        final url = Uri.parse(
          '$instance/search?q=${Uri.encodeComponent(query)}&filter=music_songs'
        );
        final res = await _client.get(url, headers: {
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final items = data['items'] as List?;
          if (items == null || items.isEmpty) continue;

          return items.take(20).map((v) {
            final id = v['url']?.toString().replaceAll('/watch?v=', '') ?? '';
            return {
              'id': id,
              'title': v['title']?.toString() ?? 'Unknown',
              'artist': v['uploaderName']?.toString() ?? 'Unknown',
              'thumbnail': v['thumbnail']?.toString() ?? 
                'https://img.youtube.com/vi/$id/mqdefault.jpg',
              'duration': v['duration']?.toString() ?? '0',
            };
          }).where((v) => v['id']!.isNotEmpty).toList();
        }
      } catch (e) {
        continue;
      }
    }
    return [];
  }

  Future<String?> getStreamUrl(String videoId) async {
    for (final instance in _pipedInstances) {
      try {
        final url = Uri.parse('$instance/streams/$videoId');
        final res = await _client.get(url, headers: {
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          
          // Coba audioStreams dulu
          final audioStreams = data['audioStreams'] as List?;
          if (audioStreams != null && audioStreams.isNotEmpty) {
            // Sort by bitrate, ambil yang tertinggi
            audioStreams.sort((a, b) =>
              (b['bitrate'] ?? 0).compareTo(a['bitrate'] ?? 0));
            
            final streamUrl = audioStreams.first['url']?.toString();
            if (streamUrl != null && streamUrl.isNotEmpty) {
              return streamUrl;
            }
          }
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
