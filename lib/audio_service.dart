import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:min_dia/audio_book.dart';
import 'package:min_dia/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  // --- REMOVED: The 'showContinueListening' ValueNotifier is gone. ---

  static const String _lastPlayedBookIdKey = 'last_played_book_id';
  String _getPositionKey(String bookId) => 'last_audio_position_$bookId';

  Future<void> init() async {
    await _loadLastPlayedBook();
    _listenForPositionChanges();
  }

  Future<void> _savePosition(String bookId, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getPositionKey(bookId), position.inMilliseconds);
  }

  Future<void> playBook(AudioBook book) async {
    final currentMediaItem = _player.sequenceState?.currentSource?.tag as MediaItem?;

    if (currentMediaItem?.id == book.id) {
      if (!_player.playing) await _player.play();
      return;
    }

    if (currentMediaItem != null && _player.position > Duration.zero) {
      await _savePosition(currentMediaItem.id, _player.position);
    }

    final prefs = await SharedPreferences.getInstance();
    final lastPositionMillis = prefs.getInt(_getPositionKey(book.id)) ?? 0;
    final lastPosition = Duration(milliseconds: lastPositionMillis);

    final audioSource = AudioSource.uri(
      Uri.parse(book.url),
      tag: MediaItem(
        id: book.id,
        album: book.title,
        title: book.title,
        artist: book.artist,
        artUri: Uri.parse(book.artUrl),
      ),
    );

    await _player.setAudioSource(audioSource, initialPosition: lastPosition);
    await _player.play();
    await prefs.setString(_lastPlayedBookIdKey, book.id);
  }

  Future<void> _loadLastPlayedBook() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPlayedBookId = prefs.getString(_lastPlayedBookIdKey);

    if (lastPlayedBookId != null) {
      final book = books.firstWhere((b) => b.id == lastPlayedBookId, orElse: () => books[0]);
      final lastPositionMillis = prefs.getInt(_getPositionKey(book.id)) ?? 0;

      if (lastPositionMillis > 0) {
        // The service now just preloads the player. The UI will react to this.
        final lastPosition = Duration(milliseconds: lastPositionMillis);
        final audioSource = AudioSource.uri(
          Uri.parse(book.url),
          tag: MediaItem(
            id: book.id,
            album: book.title,
            title: book.title,
            artist: book.artist,
            artUri: Uri.parse(book.artUrl),
          ),
        );
        await _player.setAudioSource(audioSource, initialPosition: lastPosition, preload: true);
      }
    }
  }

  void _listenForPositionChanges() {
    _player.positionStream.listen((position) {
      final currentMediaItem = _player.sequenceState?.currentSource?.tag as MediaItem?;
      if (_player.playing && currentMediaItem != null) {
        if (position.inSeconds > 0 && position.inSeconds % 5 == 0) {
          _savePosition(currentMediaItem.id, position);
        }
      }
    });

    _player.playerStateStream.listen((state) {
      final currentMediaItem = _player.sequenceState?.currentSource?.tag as MediaItem?;
      if (!state.playing && currentMediaItem != null) {
        _savePosition(currentMediaItem.id, _player.position);
      }
    });
  }

  Future<void> play() => _player.play();

  Future<void> pause() async {
    final currentMediaItem = _player.sequenceState?.currentSource?.tag as MediaItem?;
    if (currentMediaItem != null) {
      await _savePosition(currentMediaItem.id, _player.position);
    }
    await _player.pause();
  }

  void dispose() {
    final currentMediaItem = _player.sequenceState?.currentSource?.tag as MediaItem?;
    if (currentMediaItem != null) {
      _savePosition(currentMediaItem.id, _player.position);
    }
    _player.dispose();
  }
}