import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/mini_player.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          )),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search YouTube music...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.search,
                              color: Colors.white54),
                            suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                    color: Colors.white54),
                                  onPressed: () {
                                    _controller.clear();
                                    music.searchYoutube('');
                                  },
                                )
                              : null,
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (q) => music.searchYoutube(q),
                          textInputAction: TextInputAction.search,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: music.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.purpleAccent))
                      : music.searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search,
                                  color: Colors.white24, size: 64),
                                const SizedBox(height: 16),
                                Text(
                                  music.searchQuery.isEmpty
                                    ? 'Search for music on YouTube'
                                    : 'No results for "${music.searchQuery}"',
                                  style: const TextStyle(color: Colors.white54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: music.searchResults.length,
                            itemBuilder: (ctx, i) {
                              final song = music.searchResults[i];
                              final isPlaying = music.currentSong?.id == song.id
                                && music.isPlaying;
                              return ListTile(
                                onTap: () => music.playSong(song,
                                  playlist: music.searchResults),
                                leading: Stack(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(8),
                                        image: song.thumbnailUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                song.thumbnailUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      ),
                                      child: song.thumbnailUrl == null
                                        ? const Icon(Icons.music_note,
                                            color: Colors.white54)
                                        : null,
                                    ),
                                    if (isPlaying)
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius:
                                            BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.equalizer,
                                          color: Colors.purpleAccent),
                                      ),
                                  ],
                                ),
                                title: Text(song.title,
                                  style: TextStyle(
                                    color: isPlaying
                                      ? Colors.purpleAccent
                                      : Colors.white,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(song.artist,
                                  style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                                trailing: music.isBuffering &&
                                    music.currentSong?.id == song.id
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.purpleAccent,
                                      ))
                                  : PopupMenuButton(
                                      icon: const Icon(Icons.more_vert,
                                        color: Colors.white38),
                                      color: const Color(0xFF1A1A2E),
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          child: const Text('Add to Queue',
                                            style: TextStyle(
                                              color: Colors.white)),
                                          onTap: () => music.addToQueue(song),
                                        ),
                                        PopupMenuItem(
                                          child: const Text('Add to Playlist',
                                            style: TextStyle(
                                              color: Colors.white)),
                                          onTap: () => _showAddToPlaylist(
                                            context, music, song),
                                        ),
                                      ],
                                    ),
                              );
                            },
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

  void _showAddToPlaylist(BuildContext context, MusicProvider music, song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (ctx) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Add to Playlist',
              style: TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (music.playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No playlists yet',
                style: TextStyle(color: Colors.white54)),
            )
          else
            ...music.playlists.map((p) => ListTile(
              title: Text(p.name,
                style: const TextStyle(color: Colors.white)),
              subtitle: Text('${p.songs.length} songs',
                style: const TextStyle(color: Colors.white54)),
              onTap: () {
                music.addToPlaylist(p, song);
                Navigator.pop(ctx);
              },
            )),
        ],
      ),
    );
  }
}
