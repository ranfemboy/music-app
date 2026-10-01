class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? audioUrl;
  final String? thumbnailUrl;
  final Duration duration;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    this.audioUrl,
    this.thumbnailUrl,
    this.duration = Duration.zero,
    this.isFavorite = false,
  });

  Song copyWith({bool? isFavorite, String? audioUrl}) {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      audioUrl: audioUrl ?? this.audioUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Playlist {
  final String id;
  final String name;
  List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    this.songs = const [],
  });
}
