import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/mini_player.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
                          onChanged: music.setSearchQuery,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Songs, artists, albums...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: music.searchResults.isEmpty
                      ? const Center(
                          child: Text('No results found',
                            style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: music.searchResults.length,
                          itemBuilder: (ctx, i) {
                            final song = music.searchResults[i];
                            return ListTile(
                              onTap: () => music.playSong(song,
                                playlist: music.searchResults),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.music_note,
                                  color: Colors.white54),
                              ),
                              title: Text(song.title,
                                style: const TextStyle(color: Colors.white)),
                              subtitle: Text('${song.artist} • ${song.album}',
                                style: const TextStyle(color: Colors.white54)),
                              trailing: Icon(
                                song.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                                color: song.isFavorite
                                  ? Colors.pinkAccent
                                  : Colors.white54,
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
}
