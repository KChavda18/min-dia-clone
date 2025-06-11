import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:min_dia/audio_book.dart';
import 'package:min_dia/audio_service.dart';

class PodcastListenerWidget extends StatefulWidget {
  // --- UPDATED: Expect an AudioBook to be passed in ---
  final AudioBook book;
  const PodcastListenerWidget({super.key, required this.book});

  @override
  State<PodcastListenerWidget> createState() => _PodcastListenerWidgetState();
}

class _PodcastListenerWidgetState extends State<PodcastListenerWidget>
    with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  late final AudioPlayer _player;
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    _player = _audioService.player;
    WidgetsBinding.instance.addObserver(this);

    // --- UPDATED: Tell the service to play the specific book from the widget ---
    _audioService.playBook(widget.book);
  }

  void _togglePlayback() {
    _player.playing ? _audioService.pause() : _audioService.play();
  }

  void _rewind30() {
    final newPosition = _player.position - const Duration(seconds: 30);
    _player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _forward30() {
    final totalDuration = _player.duration ?? Duration.zero;
    final newPosition = _player.position + const Duration(seconds: 30);
    _player.seek(newPosition > totalDuration ? totalDuration : newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: StreamBuilder<SequenceState?>(
                      stream: _player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        if (state?.sequence.isEmpty ?? true) {
                          return const CircularProgressIndicator();
                        }
                        final metadata =
                        state!.currentSource!.tag as MediaItem;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                metadata.artUri.toString(),
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.cover,
                                errorBuilder: (c,e,s) => const Icon(Icons.book, size: 100),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(metadata.album ?? '', // The book title is in the album field
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(metadata.artist ?? '',
                                style: Theme.of(context).textTheme.titleLarge),
                          ],
                        );
                      }),
                ),
              ),
              _buildAudioSeekBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioSeekBar() {
    return Column(
      children: [
        StreamBuilder<Duration?>(
          stream: _player.durationStream,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                var position = snapshot.data ?? Duration.zero;
                if (position > duration) {
                  position = duration;
                }
                return Column(
                  children: [
                    Slider(
                      value: position.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _player.seek(Duration(milliseconds: value.round()));
                      },
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position)),
                          Text(_formatDuration(duration)),
                        ],
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.replay_30, color: Colors.black),
              onPressed: _rewind30,
              tooltip: 'Rewind 30 seconds',
            ),
            const SizedBox(width: 10),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing;
                return IconButton(
                  iconSize: 64,
                  icon: Icon(
                    playing == true
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.black,
                  ),
                  onPressed: _togglePlayback,
                );
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.forward_30, color: Colors.black),
              onPressed: _forward30,
              tooltip: 'Forward 30 seconds',
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      _audioService.dispose();
    }
  }

  @override
  void dispose() {
    // The AudioService now handles saving state on pause/stop.
    // No complex logic is needed here anymore.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}