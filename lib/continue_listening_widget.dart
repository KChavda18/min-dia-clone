import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:min_dia/listener_page.dart';
import 'audio_service.dart';

/// A widget that displays the current audio item and provides playback controls.
/// It appears at the bottom of the screen and navigates to the player screen on tap.
class ContinueListeningWidget extends StatelessWidget {
  const ContinueListeningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();

    // Use a StreamBuilder to listen for changes in the audio source.
    return StreamBuilder<SequenceState?>(
      stream: audioService.player.sequenceStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        // If there's no audio loaded, don't show the widget.
        if (state?.sequence.isEmpty ?? true) {
          return const SizedBox.shrink();
        }
        final mediaItem = state!.currentSource!.tag as MediaItem;

        // The entire widget is now tappable to navigate to the player screen.
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // Ensures the whole area is tappable
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PodcastListenerWidget(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    mediaItem.artUri.toString(),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.music_note, size: 40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mediaItem.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        mediaItem.artist ?? '',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // This StreamBuilder handles the play/pause button state.
                StreamBuilder<PlayerState>(
                  stream: audioService.player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 24.0,
                        height: 24.0,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.black,
                        ),
                      );
                    } else if (playing != true) {
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed: audioService.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 32.0,
                        onPressed: audioService.pause,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.replay),
                        iconSize: 32.0,
                        onPressed: () =>
                            audioService.player.seek(Duration.zero),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}