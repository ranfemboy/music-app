class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String audioPath;
  final String imagePath;
  final Duration duration;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.audioPath,
    required this.imagePath,
    this.duration = Duration.zero,
    this.isFavorite = false,
  });

  Song copyWith({bool? isFavorite}) {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      audioPath: audioPath,
      imagePath: imagePath,
      duration: duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'audioPath': audioPath,
    'imagePath': imagePath,
    'isFavorite': isFavorite,
  };
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
