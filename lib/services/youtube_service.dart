import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<List<Map<String, String>>> searchSongs(String query) async {
    try {
      final results = await _yt.search.search(query);
      return results.map((video) => {
        'id': video.id.value,
        'title': video.title,
        'artist': video.author,
        'duration': video.duration?.toString() ?? '0:00',
        'thumbnail': 'https://img.youtube.com/vi/${video.id.value}/0.jpg',
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> getStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
