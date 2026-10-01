import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = Provider.of<MusicProvider>(context);
    final song = music.currentSong;
    if (song == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing',
          style: TextStyle(color: Colors.white54, fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: () => _showQueue(context, music),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Artwork
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C3483), Color(0xFF1A5276)],
                ),
              ),
              child: const Icon(Icons.music_note, size: 100, color: Colors.white38),
            ),
            const SizedBox(height: 32),
            // Song info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(song.artist,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        )),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    song.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: song.isFavorite ? Colors.pinkAccent : Colors.white54,
                    size: 28,
                  ),
                  onPressed: () => music.toggleFavorite(song),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Progress bar
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.purpleAccent,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: Colors.purpleAccent.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: music.totalDuration.inSeconds > 0
                      ? music.currentPosition.inSeconds
                          .toDouble()
                          .clamp(0, music.totalDuration.inSeconds.toDouble())
                      : 0,
                    min: 0,
                    max: music.totalDuration.inSeconds > 0
                      ? music.totalDuration.inSeconds.toDouble()
                      : 1,
                    onChanged: (val) => music.seekTo(
                      Duration(seconds: val.toInt())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(music.formatDuration(music.currentPosition),
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(music.formatDuration(music.totalDuration),
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.shuffle,
                    color: music.isShuffle ? Colors.purpleAccent : Colors.white54,
                    size: 24,
                  ),
                  onPressed: music.toggleShuffle,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                  onPressed: music.previousSong,
                ),
                GestureDetector(
                  onTap: music.togglePlayPause,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.purpleAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      music.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                  onPressed: music.nextSong,
                ),
                IconButton(
                  icon: Icon(
                    music.repeatMode == RepeatMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                    color: music.repeatMode != RepeatMode.off
                      ? Colors.purpleAccent
                      : Colors.white54,
                    size: 24,
                  ),
                  onPressed: music.toggleRepeat,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Volume
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    music.isMuted ? Icons.volume_off : Icons.volume_down,
                    color: Colors.white54,
                  ),
                  onPressed: music.toggleMute,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: music.isMuted ? 0 : music.volume,
                      min: 0,
                      max: 1,
                      onChanged: music.setVolume,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white54),
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQueue(BuildContext context, MusicProvider music) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (ctx) => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Queue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: music.queue.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: Text('${i + 1}',
                  style: const TextStyle(color: Colors.white54)),
                title: Text(music.queue[i].title,
                  style: TextStyle(
                    color: music.currentSong?.id == music.queue[i].id
                      ? Colors.purpleAccent
                      : Colors.white,
                  )),
                subtitle: Text(music.queue[i].artist,
                  style: const TextStyle(color: Colors.white54)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.white38),
                  onPressed: () => music.removeFromQueue(i),
                ),
                onTap: () => music.playSong(music.queue[i],
                  playlist: music.queue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
