import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeService {
  final _client = http.Client();
  final String _apiBase = 'http://139.59.162.30:8000';

  Future<List<Map<String, String>>> searchSongs(String query) async {
    try {
      final url = Uri.parse('$_apiBase/search?q=${Uri.encodeComponent(query)}');
      final res = await _client.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((v) => {
          'id': v['id'].toString(),
          'title': v['title'].toString(),
          'artist': v['artist'].toString(),
          'thumbnail': v['thumbnail'].toString(),
          'duration': v['duration'].toString(),
        }).toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  Future<String?> getStreamUrl(String videoId) async {
    try {
      final url = Uri.parse('$_apiBase/stream/$videoId');
      final res = await _client.get(url).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['url']?.toString();
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
