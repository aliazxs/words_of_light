import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/reading_progress.dart';
import '../providers/app_provider.dart';
import 'book_reader_screen.dart';

/// Library screen - displays all books with progress indicators.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'كلامكم نور',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
            IconButton(
              icon: const Icon(Icons.error_outline),
              onPressed: () => Navigator.pushNamed(context, '/mistakes'),
            ),
          ],
        ),
        body: Consumer<AppProvider>(
          builder: (context, app, _) {
            if (!app.initialized) {
              return const Center(child: CircularProgressIndicator());
            }
            if (app.books.isEmpty) {
              return _EmptyLibrary();
            }
            return RefreshIndicator(
              onRefresh: app.refreshBooks,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: app.books.length,
                itemBuilder: (context, i) => _BookCard(book: app.books[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReadingProgress?>(
      future: context.read<AppProvider>().getProgress(book.id),
      builder: (context, snap) {
        final progress = snap.data;
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookReaderScreen(book: book),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildCover(context),
                      if (progress != null && progress.progress > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LinearProgressIndicator(
                            value: progress.progress,
                            backgroundColor: Colors.black26,
                            valueColor: const AlwaysStoppedAnimation(Colors.amber),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    book.displayTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(BuildContext context) {
    if (book.coverPath == null || book.coverPath!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        child: Icon(
          Icons.menu_book,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    final path = context.read<AppProvider>().resolveBookPath(book.id, book.coverPath!);
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.menu_book,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد كتب في المكتبة',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'أضف الكتب يدوياً في مجلد التطبيق:\n'
              'Documents/books/{book_id}/catalog.json',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
