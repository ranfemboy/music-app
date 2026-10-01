import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/mini_player.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Library',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          )),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => _showCreatePlaylist(context, music),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.purpleAccent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    tabs: const [
                      Tab(text: 'Favorites'),
                      Tab(text: 'Playlists'),
                      Tab(text: 'Recent'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFavorites(music),
                        _buildPlaylists(music, context),
                        _buildRecent(music),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (music.currentSong != null) const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorites(MusicProvider music) {
    if (music.favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet',
          style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: music.favorites.length,
      itemBuilder: (ctx, i) {
        final song = music.favorites[i];
        return ListTile(
          onTap: () => music.playSong(song, playlist: music.favorites),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note, color: Colors.white54),
          ),
          title: Text(song.title,
            style: const TextStyle(color: Colors.white)),
          subtitle: Text(song.artist,
            style: const TextStyle(color: Colors.white54)),
          trailing: const Icon(Icons.favorite, color: Colors.pinkAccent),
        );
      },
    );
  }

  Widget _buildPlaylists(MusicProvider music, BuildContext context) {
    if (music.playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No playlists yet',
              style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showCreatePlaylist(context, music),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
              ),
              child: const Text('Create Playlist'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: music.playlists.length,
      itemBuilder: (ctx, i) {
        final playlist = music.playlists[i];
        return ListTile(
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.queue_music, color: Colors.purpleAccent),
          ),
          title: Text(playlist.name,
            style: const TextStyle(color: Colors.white)),
          subtitle: Text('${playlist.songs.length} songs',
            style: const TextStyle(color: Colors.white54)),
          onTap: () {
            if (playlist.songs.isNotEmpty) {
              music.playSong(playlist.songs[0], playlist: playlist.songs);
            }
          },
        );
      },
    );
  }

  Widget _buildRecent(MusicProvider music) {
    if (music.recentlyPlayed.isEmpty) {
      return const Center(
        child: Text('No recently played',
          style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: music.recentlyPlayed.length,
      itemBuilder: (ctx, i) {
        final song = music.recentlyPlayed[i];
        return ListTile(
          onTap: () => music.playSong(song, playlist: music.recentlyPlayed),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history, color: Colors.white54),
          ),
          title: Text(song.title,
            style: const TextStyle(color: Colors.white)),
          subtitle: Text(song.artist,
            style: const TextStyle(color: Colors.white54)),
        );
      },
    );
  }

  void _showCreatePlaylist(BuildContext context, MusicProvider music) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('New Playlist',
          style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
              style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                music.createPlaylist(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create',
              style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }
}
