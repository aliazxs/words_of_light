import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/book.dart';
import '../models/bookmark.dart';
import '../models/mistake_report.dart';
import '../models/reading_progress.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// Main app state - books, progress, bookmarks, mistake reports, audio.
class AppProvider extends ChangeNotifier {
  final StorageService storage = StorageService();
  final AppAudioService audio = AppAudioService();

  List<Book> _books = [];
  bool _initialized = false;
  String? _themeMode; // 'light', 'dark', 'system'

  List<Book> get books => _books;
  bool get initialized => _initialized;
  String get themeMode => _themeMode ?? 'system';

  Future<void> init() async {
    if (_initialized) return;
    await storage.init();
    _themeMode = storage.themeMode;
    _books = await storage.loadBooks();
    if (_books.isEmpty) {
      await _createSampleBook();
      _books = await storage.loadBooks();
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _createSampleBook() async {
    final dir = storage.appDirectory;
    final booksDir = Directory('${dir.path}/books');
    final demoDir = Directory('${booksDir.path}/nahj_demo');
    if (await demoDir.exists()) return;
    await demoDir.create(recursive: true);

    try {
      // Copy bundled demo from assets
      final catalogBytes =
          await rootBundle.load('assets/books/nahj_demo/catalog.json');
      await File('${demoDir.path}/catalog.json')
          .writeAsBytes(catalogBytes.buffer.asUint8List());

      for (var i = 1; i <= 3; i++) {
        final readerDir = Directory('${demoDir.path}/audio/reader$i');
        await readerDir.create(recursive: true);
        final audio = await rootBundle.load('assets/books/nahj_demo/audio/reader$i/khutba1.mp3');
        await File('${readerDir.path}/khutba1.mp3')
            .writeAsBytes(audio.buffer.asUint8List());
      }
    } catch (_) {
      // Fallback: create minimal sample if assets unavailable
      final catalog = {
        'id': 'nahj_demo',
        'titleAr': 'نهج البلاغة (عينة)',
        'titleEn': 'Nahj al-Balagha (Sample)',
        'author': 'الإمام علي بن أبي طالب عليه السلام',
        'description': 'عينة. راجع ADD_BOOKS.md لإضافة الكتب والملفات الصوتية.',
        'coverPath': null,
        'chapters': [
          {
            'id': 'ch1',
            'title': 'الخطبة الأولى',
            'content': 'بسم الله الرحمن الرحيم\n\nالحمد لله الذي لا يبلغ مدحته القائلون ولا يحصي نعماءه العادون ولا يؤدي حقه المجتهدون.',
            'audioRecordings': [],
          },
        ],
        'availableReaders': [],
      };
      await File('${demoDir.path}/catalog.json')
          .writeAsString(jsonEncode(catalog));
    }
  }

  Future<void> refreshBooks() async {
    _books = await storage.loadBooks();
    notifyListeners();
  }

  Book? getBook(String id) =>
      _books.cast<Book?>().firstWhere((b) => b?.id == id, orElse: () => null);

  Future<ReadingProgress?> getProgress(String bookId) =>
      storage.getProgress(bookId);

  Future<void> saveProgress(ReadingProgress progress) async {
    await storage.saveProgress(progress);
    notifyListeners();
  }

  Future<List<Bookmark>> getBookmarks(String bookId) =>
      storage.getBookmarks(bookId);

  Future<void> addBookmark(String bookId, Bookmark b) async {
    await storage.addBookmark(bookId, b);
    notifyListeners();
  }

  Future<void> removeBookmark(String bookId, String bookmarkId) async {
    await storage.removeBookmark(bookId, bookmarkId);
    notifyListeners();
  }

  Future<List<MistakeReport>> getMistakeReports() =>
      storage.getMistakeReports();

  Future<List<MistakeReport>> getMistakeReportsForBook(String bookId) =>
      storage.getMistakeReportsForBook(bookId);

  Future<void> addMistakeReport(MistakeReport report) async {
    await storage.addMistakeReport(report);
    notifyListeners();
  }

  Future<void> markMistakeResolved(String reportId) async {
    await storage.markMistakeReportResolved(reportId);
    notifyListeners();
  }

  Future<void> removeMistakeReport(String reportId) async {
    await storage.removeMistakeReport(reportId);
    notifyListeners();
  }

  Future<String?> getLastReader(String bookId) =>
      storage.getLastReaderForBook(bookId);

  Future<void> setLastReader(String bookId, String readerId) async {
    await storage.setLastReaderForBook(bookId, readerId);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await storage.setThemeMode(mode);
    notifyListeners();
  }

  String resolveBookPath(String bookId, String relativePath) =>
      storage.resolveBookAssetPath(bookId, relativePath);
}
