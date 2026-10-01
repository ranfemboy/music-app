import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../models/song.dart';
import '../services/youtube_service.dart';

enum RepeatMode { off, one, all }

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final YoutubeService _youtube = YoutubeService();

  List<Song> _songs = [];
  List<Song> _queue = [];
  List<Song> _recentlyPlayed = [];
  List<Song> _favorites = [];
  List<Playlist> _playlists = [];
  List<Song> _searchResults = [];

  Song? _currentSong;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isLoading = false;
  bool _isBuffering = false;
  RepeatMode _repeatMode = RepeatMode.off;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;
  String _searchQuery = '';

  List<Song> get songs => _songs;
  List<Song> get queue => _queue;
  List<Song> get recentlyPlayed => _recentlyPlayed;
  List<Song> get favorites => _favorites;
  List<Playlist> get playlists => _playlists;
  List<Song> get searchResults => _searchResults;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  bool get isLoading => _isLoading;
  bool get isBuffering => _isBuffering;
  RepeatMode get repeatMode => _repeatMode;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  String get searchQuery => _searchQuery;

  MusicProvider() {
    _initPlayer();
    _loadFavorites();
  }

  void _initPlayer() {
    _player.positionStream.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _totalDuration = dur;
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
      notifyListeners();
    });
  }

  void _onSongComplete() {
    switch (_repeatMode) {
      case RepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
        break;
      case RepeatMode.all:
        nextSong();
        break;
      case RepeatMode.off:
        if (_currentIndex < _queue.length - 1) {
          nextSong();
        } else {
          _isPlaying = false;
          notifyListeners();
        }
        break;
    }
  }

  Future<void> searchYoutube(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _searchQuery = query;
    notifyListeners();

    try {
      final results = await _youtube.searchSongs(query);
      _searchResults = results.map((r) => Song(
        id: r['id']!,
        title: r['title']!,
        artist: r['artist']!,
        thumbnailUrl: r['thumbnail'],
      )).toList();
    } catch (e) {
      _searchResults = [];
      debugPrint('Search error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    try {
      _isBuffering = true;
      _currentSong = song;
      _queue = playlist ?? [song];
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) _currentIndex = 0;
      notifyListeners();

      final streamUrl = await _youtube.getStreamUrl(song.id);
      if (streamUrl == null) {
        _isBuffering = false;
        notifyListeners();
        return;
      }

      await _player.setUrl(streamUrl);
      await _player.play();
      _isPlaying = true;
      _isBuffering = false;

      _addToRecentlyPlayed(song);
      if (!_songs.any((s) => s.id == song.id)) {
        _songs.insert(0, song);
      }
      notifyListeners();
    } catch (e) {
      _isBuffering = false;
      _isPlaying = false;
      notifyListeners();
      debugPrint('Play error: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> nextSong() async {
    if (_queue.isEmpty) return;
    if (_isShuffle) {
      _currentIndex = Random().nextInt(_queue.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    await playSong(_queue[_currentIndex], playlist: _queue);
  }

  Future<void> previousSong() async {
    if (_queue.isEmpty) return;
    if (_currentPosition.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await playSong(_queue[_currentIndex], playlist: _queue);
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    _isMuted = volume == 0;
    await _player.setVolume(volume);
    notifyListeners();
  }

  Future<void> toggleMute() async {
    if (_isMuted) {
      await setVolume(_volume == 0 ? 1.0 : _volume);
      _isMuted = false;
    } else {
      await _player.setVolume(0);
      _isMuted = true;
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  void toggleFavorite(Song song) {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _songs[index].isFavorite = !_songs[index].isFavorite;
      if (_songs[index].isFavorite) {
        _favorites.add(_songs[index]);
      } else {
        _favorites.removeWhere((s) => s.id == song.id);
      }
      if (_currentSong?.id == song.id) {
        _currentSong = _songs[index];
      }
      _saveFavorites();
      notifyListeners();
    }
  }

  void createPlaylist(String name) {
    _playlists.add(Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    ));
    notifyListeners();
  }

  void addToPlaylist(Playlist playlist, Song song) {
    final index = _playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      _playlists[index].songs.add(song);
      notifyListeners();
    }
  }

  void removeFromPlaylist(Playlist playlist, Song song) {
    final index = _playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      _playlists[index].songs.removeWhere((s) => s.id == song.id);
      notifyListeners();
    }
  }

  void addToQueue(Song song) {
    if (!_queue.any((s) => s.id == song.id)) {
      _queue.add(song);
      notifyListeners();
    }
  }

  void removeFromQueue(int index) {
    _queue.removeAt(index);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void _addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed = _recentlyPlayed.take(20).toList();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _favorites.map((s) => s.id).toList();
    await prefs.setStringList('favorites', ids);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    for (var song in _songs) {
      if (ids.contains(song.id)) {
        song.isFavorite = true;
        _favorites.add(song);
      }
    }
    notifyListeners();
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    _youtube.dispose();
    super.dispose();
  }
}
