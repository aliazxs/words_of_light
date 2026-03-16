import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/book.dart';
import '../models/bookmark.dart';
import '../models/mistake_report.dart';
import '../models/reading_progress.dart';
import '../providers/app_provider.dart';
import '../widgets/highlightable_text.dart';

/// Book reader - read or listen with sync highlighting, reader picker,
/// bookmarks, progress, and mistake reporting.
class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  int _chapterIndex = 0;
  String? _selectedReaderId;
  bool _readerPickerExpanded = false;
  final int _lastScrollCharOffset = 0; // for bookmarking current position

  @override
  void initState() {
    super.initState();
    _loadLastReader();
    _loadProgress();
  }

  Future<void> _loadLastReader() async {
    final readerId = await context.read<AppProvider>().getLastReader(widget.book.id);
    if (readerId != null && mounted) {
      setState(() => _selectedReaderId = readerId);
    }
  }

  Future<void> _loadProgress() async {
    final progress = await context.read<AppProvider>().getProgress(widget.book.id);
    if (progress != null && mounted) {
      final idx = widget.book.chapters.indexWhere((c) => c.id == progress.chapterId);
      if (idx >= 0) {
        setState(() => _chapterIndex = idx);
      }
    }
  }

  Chapter get _currentChapter => widget.book.chapters[_chapterIndex];

  AudioRecording? _getRecordingForReader(String readerId) {
    return _currentChapter.audioRecordings
        .cast<AudioRecording?>()
        .firstWhere(
          (r) => r?.readerId == readerId,
          orElse: () => null,
        );
  }

  Future<void> _saveProgress(int charOffset) async {
    final app = context.read<AppProvider>();
    final totalChars = widget.book.chapters.fold<int>(
      0,
      (sum, c) => sum + c.content.length,
    );
    var readChars = 0;
    for (var i = 0; i < _chapterIndex; i++) {
      readChars += widget.book.chapters[i].content.length;
    }
    readChars += charOffset;
    final progress = readChars / totalChars.clamp(1, totalChars);

    await app.saveProgress(ReadingProgress(
      bookId: widget.book.id,
      chapterId: _currentChapter.id,
      charOffset: charOffset,
      progress: progress,
      lastReadAt: DateTime.now(),
    ));
  }

  Future<void> _playPause() async {
    final app = context.read<AppProvider>();
    final readerId = _selectedReaderId;
    if (readerId == null) return;

    final rec = _getRecordingForReader(readerId);
    if (rec == null) return;

    final fullPath = app.resolveBookPath(widget.book.id, rec.audioPath);
    if (!File(fullPath).existsSync()) return;

    final reader = widget.book.availableReaders
        .cast<Reader?>()
        .firstWhere(
          (r) => r?.id == readerId,
          orElse: () => null,
        );

    if (app.audio.playing) {
      await app.audio.pause();
    } else {
      if (app.audio.currentChapterId != _currentChapter.id ||
          app.audio.currentReaderId != readerId) {
        await app.audio.loadChapterAudio(
          bookId: widget.book.id,
          chapterId: _currentChapter.id,
          readerId: readerId,
          readerName: reader?.name ?? rec.readerName,
          bookTitle: widget.book.displayTitle,
          chapterTitle: _currentChapter.title,
          audioPath: fullPath,
          segments: rec.segments,
        );
        await app.setLastReader(widget.book.id, readerId);
      }
      await app.audio.play();
    }
    setState(() {});
  }

  Future<void> _reportMistake(String text, int start, int end) async {
    final readerId = _selectedReaderId;
    if (readerId == null) return;

    final rec = _getRecordingForReader(readerId);
    if (rec == null) return;

    final report = MistakeReport(
      id: const Uuid().v4(),
      bookId: widget.book.id,
      chapterId: _currentChapter.id,
      readerId: readerId,
      readerName: rec.readerName,
      highlightedText: text,
      startChar: start,
      endChar: end,
      userNote: null,
      reportedAt: DateTime.now(),
    );
    await context.read<AppProvider>().addMistakeReport(report);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال تنبيه الخطأ للقارئ')),
      );
    }
  }

  Future<void> _addBookmark(int charOffset, [String? text]) async {
    final app = context.read<AppProvider>();
    final b = Bookmark(
      id: const Uuid().v4(),
      bookId: widget.book.id,
      chapterId: _currentChapter.id,
      title: _currentChapter.title,
      charOffset: charOffset,
      highlightedText: text,
      createdAt: DateTime.now(),
    );
    await app.addBookmark(widget.book.id, b);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الصفحة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.book.displayTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: 'حفظ الصفحة',
              onPressed: () => _addBookmark(_lastScrollCharOffset),
            ),
            IconButton(
              icon: const Icon(Icons.bookmarks),
              tooltip: 'الصفحات المحفوظة',
              onPressed: () => _showBookmarksSheet(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Reader picker
            _buildReaderPicker(context),
            // Chapter tabs
            _buildChapterBar(context),
            // Content
            Expanded(
              child: HighlightableText(
                key: ValueKey(_currentChapter.id),
                text: _currentChapter.content,
                highlightStream: context.read<AppProvider>().audio.highlightStream,
                onScrollOffset: _saveProgress,
                onReportMistake: _reportMistake,
                onBookmark: _addBookmark,
              ),
            ),
            // Audio bar
            _buildAudioBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderPicker(BuildContext context) {
    final readers = widget.book.availableReaders;
    if (readers.isEmpty) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: _readerPickerExpanded,
        onExpansionChanged: (v) => setState(() => _readerPickerExpanded = v),
        title: Text(
          _selectedReaderId == null
              ? 'اختر القارئ'
              : readers
                      .cast<Reader?>()
                      .firstWhere(
                        (r) => r?.id == _selectedReaderId,
                        orElse: () => null,
                      )
                      ?.name ??
                  'القارئ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: readers
            .map(
              (r) => ListTile(
                leading: _selectedReaderId == r.id
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                title: Text(r.name),
                subtitle: _getRecordingForReader(r.id) != null
                    ? const Text('متوفر صوت', style: TextStyle(fontSize: 12))
                    : null,
                onTap: () {
                  setState(() => _selectedReaderId = r.id);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildChapterBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(
          widget.book.chapters.length,
          (i) => Padding(
            padding: const EdgeInsets.only(left: 4),
            child: FilterChip(
              label: Text(
                widget.book.chapters[i].title,
                overflow: TextOverflow.ellipsis,
              ),
              selected: i == _chapterIndex,
              onSelected: (_) => setState(() => _chapterIndex = i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioBar(BuildContext context) {
    final app = context.read<AppProvider>();
    final hasAudio = _getRecordingForReader(_selectedReaderId ?? '') != null;

    if (!hasAudio) return const SizedBox.shrink();

    return StreamBuilder<Duration>(
      stream: app.audio.positionStream,
      builder: (context, _) {
        final audio = app.audio;
        final duration = audio.duration;
        final position = audio.position;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: position.inMilliseconds /
                      (duration?.inMilliseconds ?? 1).clamp(1, double.infinity),
                  onChanged: (v) {
                    audio.seek(Duration(
                      milliseconds: ((duration?.inMilliseconds ?? 0) * v).round(),
                    ));
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(audio.playing ? Icons.pause : Icons.play_arrow),
                    onPressed: _playPause,
                  ),
                  Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration ?? Duration.zero)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showBookmarksSheet(BuildContext context) {
    final app = context.read<AppProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => FutureBuilder<List<Bookmark>>(
          future: app.getBookmarks(widget.book.id),
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final bookmarks = snap.data!;
            if (bookmarks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'لا توجد صفحات محفوظة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              );
            }
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'الصفحات المحفوظة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: bookmarks.length,
                      itemBuilder: (ctx, i) {
                        final b = bookmarks[i];
                        final chapterIdx = widget.book.chapters
                            .indexWhere((c) => c.id == b.chapterId);
                        return ListTile(
                          title: Text(
                            b.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: b.highlightedText != null &&
                                  b.highlightedText!.isNotEmpty
                              ? Text(
                                  b.highlightedText!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () async {
                              await app.removeBookmark(widget.book.id, b.id);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                          ),
                          onTap: () {
                            if (chapterIdx >= 0) {
                              setState(() => _chapterIndex = chapterIdx);
                            }
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
