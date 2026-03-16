import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../models/bookmark.dart';
import '../models/mistake_report.dart';
import '../models/reading_progress.dart';

/// Manages all local storage: books catalog, progress, bookmarks, mistake reports.
/// All content is stored offline in app documents directory.
class StorageService {
  static const String _progressPrefix = 'progress_';
  static const String _bookmarksPrefix = 'bookmarks_';
  static const String _mistakeReportsKey = 'mistake_reports';
  static const String _lastReaderPrefix = 'last_reader_';
  static const String _themeKey = 'theme_mode';

  late Directory _appDir;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _appDir = await getApplicationDocumentsDirectory();
    _prefs = await SharedPreferences.getInstance();
  }

  String get themeMode => _prefs.getString(_themeKey) ?? 'system';
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  /// Base directory for all app data (books, audio, covers)
  Directory get appDirectory => _appDir;

  /// Path to books data folder
  String get booksPath => p.join(_appDir.path, 'books');

  /// Path to a specific book's folder
  String bookPath(String bookId) => p.join(booksPath, bookId);

  /// Path to a book's catalog json
  String bookCatalogPath(String bookId) => p.join(bookPath(bookId), 'catalog.json');

  // ─── Books Catalog ────────────────────────────────────────────────────────

  /// Load all books from the books folder.
  /// Each book is stored in a subfolder: books/{bookId}/catalog.json
  Future<List<Book>> loadBooks() async {
    final books = <Book>[];
    final booksDir = Directory(booksPath);

    if (!await booksDir.exists()) {
      return books;
    }

    await for (final entity in booksDir.list()) {
      if (entity is Directory) {
        try {
          final catalogFile = File(p.join(entity.path, 'catalog.json'));
          if (await catalogFile.exists()) {
            final json = jsonDecode(await catalogFile.readAsString());
            books.add(Book.fromJson(Map<String, dynamic>.from(json)));
          }
        } catch (_) {}
      }
    }

    return books;
  }

  /// Save or update a book's catalog.
  Future<void> saveBookCatalog(Book book) async {
    final dir = Directory(bookPath(book.id));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(bookCatalogPath(book.id));
    await file.writeAsString(jsonEncode(book.toJson()));
  }

  /// Resolve path relative to book folder (for audio, cover paths in catalog).
  String resolveBookAssetPath(String bookId, String relativePath) {
    if (relativePath.isEmpty) return '';
    if (p.isAbsolute(relativePath)) return relativePath;
    return p.join(bookPath(bookId), relativePath);
  }

  // ─── Reading Progress ─────────────────────────────────────────────────────

  Future<ReadingProgress?> getProgress(String bookId) async {
    final json = _prefs.getString('$_progressPrefix$bookId');
    if (json == null) return null;
    try {
      return ReadingProgress.fromJson(
        Map<String, dynamic>.from(jsonDecode(json)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProgress(ReadingProgress progress) async {
    await _prefs.setString(
      '$_progressPrefix${progress.bookId}',
      jsonEncode(progress.toJson()),
    );
  }

  // ─── Bookmarks ────────────────────────────────────────────────────────────

  Future<List<Bookmark>> getBookmarks(String bookId) async {
    final json = _prefs.getString('$_bookmarksPrefix$bookId');
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => Bookmark.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBookmarks(String bookId, List<Bookmark> bookmarks) async {
    await _prefs.setString(
      '$_bookmarksPrefix$bookId',
      jsonEncode(bookmarks.map((b) => b.toJson()).toList()),
    );
  }

  Future<void> addBookmark(String bookId, Bookmark bookmark) async {
    final list = await getBookmarks(bookId);
    list.add(bookmark);
    await saveBookmarks(bookId, list);
  }

  Future<void> removeBookmark(String bookId, String bookmarkId) async {
    final list = await getBookmarks(bookId);
    list.removeWhere((b) => b.id == bookmarkId);
    await saveBookmarks(bookId, list);
  }

  // ─── Mistake Reports ──────────────────────────────────────────────────────

  Future<List<MistakeReport>> getMistakeReports() async {
    final json = _prefs.getString(_mistakeReportsKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => MistakeReport.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<MistakeReport>> getMistakeReportsForBook(String bookId) async {
    final all = await getMistakeReports();
    return all.where((r) => r.bookId == bookId).toList();
  }

  Future<void> addMistakeReport(MistakeReport report) async {
    final list = await getMistakeReports();
    list.add(report);
    await _prefs.setString(
      _mistakeReportsKey,
      jsonEncode(list.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> removeMistakeReport(String reportId) async {
    final list = await getMistakeReports();
    list.removeWhere((r) => r.id == reportId);
    await _prefs.setString(
      _mistakeReportsKey,
      jsonEncode(list.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> markMistakeReportResolved(String reportId) async {
    final list = await getMistakeReports();
    final idx = list.indexWhere((r) => r.id == reportId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(resolved: true);
      await _prefs.setString(
        _mistakeReportsKey,
        jsonEncode(list.map((r) => r.toJson()).toList()),
      );
    }
  }

  // ─── Last Selected Reader ─────────────────────────────────────────────────

  Future<String?> getLastReaderForBook(String bookId) async {
    return _prefs.getString('$_lastReaderPrefix$bookId');
  }

  Future<void> setLastReaderForBook(String bookId, String readerId) async {
    await _prefs.setString('$_lastReaderPrefix$bookId', readerId);
  }
}
