import 'package:flutter/material.dart';
import '../models/song.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongCard({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C3483), Color(0xFF1A5276)],
                ),
              ),
              child: const Icon(Icons.music_note, color: Colors.white38, size: 40),
            ),
            const SizedBox(height: 8),
            Text(song.title,
              style: const TextStyle(color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w600),
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
    );
  }
}
