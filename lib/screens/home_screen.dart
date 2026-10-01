import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_card.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good ${_greeting()}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              )),
                            const Text('Music App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              )),
                          ],
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (music.recentlyPlayed.isNotEmpty) ...[
                      const Text('Recently Played',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: music.recentlyPlayed.length,
                          itemBuilder: (ctx, i) => SongCard(
                            song: music.recentlyPlayed[i],
                            onTap: () => music.playSong(
                              music.recentlyPlayed[i],
                              playlist: music.recentlyPlayed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Text('All Songs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: music.songs.length,
                      itemBuilder: (ctx, i) => _SongTile(
                        song: music.songs[i],
                        onTap: () => music.playSong(
                          music.songs[i],
                          playlist: music.songs,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (music.currentSong != null) const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning ☀️';
    if (h < 17) return 'Afternoon 🌤️';
    return 'Evening 🌙';
  }
}

class _SongTile extends StatelessWidget {
  final song;
  final VoidCallback onTap;
  const _SongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: Colors.white54),
      ),
      title: Text(song.title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(song.artist,
        style: const TextStyle(color: Colors.white54)),
      trailing: IconButton(
        icon: Icon(
          song.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: song.isFavorite ? Colors.pinkAccent : Colors.white54,
        ),
        onPressed: () {
          Provider.of<MusicProvider>(context, listen: false)
            .toggleFavorite(song);
        },
      ),
    );
  }
}
