import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);
    final song = music.currentSong;
    if (song == null) return const SizedBox();

    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const PlayerScreen())),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note, color: Colors.white54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(song.title,
                    style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(song.artist,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white, size: 22),
              onPressed: music.previousSong,
            ),
            IconButton(
              icon: Icon(
                music.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
              onPressed: music.togglePlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 22),
              onPressed: music.nextSong,
            ),
          ],
        ),
      ),
    );
  }
}
