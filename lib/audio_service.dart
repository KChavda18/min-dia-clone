import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton class to manage the app's audio player.
/// This allows for a single source of truth for audio playback,
/// which can be controlled from any widget in the app.
class AudioService {
  // Singleton setup
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  // State to control the visibility of the ContinueListeningWidget
  final showContinueListening = ValueNotifier<bool>(false);

  // Keys for storing playback position in SharedPreferences
  static const String _lastPositionKey = 'last_audio_position';

  /// Initializes the audio service.
  /// This should be called once when the app starts.
  Future<void> init() async {
    // Load the last saved playback position and determine if the widget should be visible.
    await _loadLastPositionAndSetup();
    // Set up listeners to save the position during playback.
    _listenForPositionChanges();
  }

  /// Saves the current playback position to SharedPreferences.
  Future<void> _savePosition(Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPositionKey, position.inMilliseconds);
  }

  /// Loads the last playback position and decides whether to show the continue listening widget.
  Future<void> _loadLastPositionAndSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPositionMillis = prefs.getInt(_lastPositionKey) ?? 0;

    // Only show the widget and load the audio if there's a saved position greater than zero.
    if (lastPositionMillis > 0) {
      showContinueListening.value = true;
      final lastPosition = Duration(milliseconds: lastPositionMillis);

      final audioSource = AudioSource.uri(
        Uri.parse('http://daq7nasbr6dck.cloudfront.net/7habits/1.mp3'),
        tag: MediaItem(
          id: '1',
          album: '7 Habits of Highly Effective People',
          title: 'Chapter 1',
          artist: 'Stephen R. Covey',
          artUri: Uri.parse(
              'http://daq7nasbr6dck.cloudfront.net/7habits/cover.jpg'),
        ),
      );

      await _player.setAudioSource(audioSource,
          initialPosition: lastPosition, preload: true);
    }
  }

  /// Sets up stream listeners to automatically save the playback position.
  void _listenForPositionChanges() {
    _player.positionStream.listen((position) {
      if (_player.playing) {
        if (position.inSeconds > 0 && position.inSeconds % 5 == 0) {
          _savePosition(position);
        }
      }
    });

    _player.playerStateStream.listen((state) {
      if (!state.playing) {
        _savePosition(_player.position);
      }
    });
  }

  // --- Playback Controls ---

  Future<void> play() async {
    // When play is called, we ensure the widget becomes visible.
    if (!showContinueListening.value) {
      showContinueListening.value = true;
    }
    // If the player doesn't have a source (first play), load it.
    if (_player.audioSource == null) {
      final audioSource = AudioSource.uri(
        Uri.parse('http://daq7nasbr6dck.cloudfront.net/7habits/1.mp3'),
        tag: MediaItem(
          id: '1',
          album: '7 Habits of Highly Effective People',
          title: 'Chapter 1',
          artist: 'Stephen R. Covey',
          artUri: Uri.parse(
              'http://daq7nasbr6dck.cloudfront.net/7habits/cover.jpg'),
        ),
      );
      await _player.setAudioSource(audioSource, preload: true);
    }
    _player.play();
  }

  Future<void> pause() async {
    await _savePosition(_player.position);
    await _player.pause();
  }

  Future<void> stop() async {
    await _savePosition(_player.position);
    await _player.stop();
  }

  /// Disposes of the player resources.
  /// Should be called when the app is closing.
  void dispose() {
    _savePosition(_player.position);
    _player.dispose();
    showContinueListening.dispose();
  }
}