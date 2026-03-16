import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/book.dart';

/// Audio playback service with background support.
/// Handles play/pause, seek, and position streaming for text-audio sync.
class AppAudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  PlayerState get playerState => _player.playerState;
  bool get playing => _player.playing;
  bool get hasNext => _player.hasNext;
  bool get hasPrevious => _player.hasPrevious;

  /// Currently loaded book/chapter/reader context for UI
  String? currentBookId;
  String? currentChapterId;
  String? currentReaderId;

  /// Segments for text-audio sync: character range -> (startTime, endTime)
  List<AudioSegment> _segments = [];
  List<AudioSegment> get segments => _segments;

  /// Current segment index being played (for highlighting)
  int _currentSegmentIndex = -1;
  int get currentSegmentIndex => _currentSegmentIndex;

  /// Stream of current character range to highlight
  final StreamController<HighlightRange?> _highlightController =
      StreamController<HighlightRange?>.broadcast();
  Stream<HighlightRange?> get highlightStream => _highlightController.stream;

  StreamSubscription? _positionSub;

  AppAudioService() {
    _positionSub = _player.positionStream.listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Duration position) {
    final sec = position.inMilliseconds / 1000.0;
    for (var i = 0; i < _segments.length; i++) {
      final s = _segments[i];
      if (sec >= s.startTime && sec <= s.endTime) {
        if (_currentSegmentIndex != i) {
          _currentSegmentIndex = i;
          _highlightController.add(HighlightRange(s.startChar, s.endChar));
        }
        return;
      }
    }
    if (_currentSegmentIndex != -1) {
      _currentSegmentIndex = -1;
      _highlightController.add(null);
    }
  }

  /// Load a chapter's audio for a specific reader.
  Future<void> loadChapterAudio({
    required String bookId,
    required String chapterId,
    required String readerId,
    required String readerName,
    required String bookTitle,
    required String chapterTitle,
    required String audioPath,
    required List<AudioSegment> segments,
  }) async {
    currentBookId = bookId;
    currentChapterId = chapterId;
    currentReaderId = readerId;
    _segments = List.from(segments);

    final mediaItem = MediaItem(
      id: '${bookId}_${chapterId}_$readerId',
      album: bookTitle,
      title: chapterTitle,
      artist: readerName,
    );

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.file(audioPath),
        tag: mediaItem,
      ),
    );
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> seekToSegment(int index) async {
    if (index >= 0 && index < _segments.length) {
      await _player.seek(
        Duration(milliseconds: (_segments[index].startTime * 1000).round()),
      );
    }
  }

  Future<void> stop() => _player.stop();
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _highlightController.close();
    await _player.dispose();
  }

  /// Get current highlight range based on position (for external use)
  HighlightRange? getCurrentHighlight() {
    final sec = _player.position.inMilliseconds / 1000.0;
    for (final s in _segments) {
      if (sec >= s.startTime && sec <= s.endTime) {
        return HighlightRange(s.startChar, s.endChar);
      }
    }
    return null;
  }
}

class HighlightRange {
  final int startIndex;
  final int endIndex;
  HighlightRange(this.startIndex, this.endIndex);
}
