library;

/// Saves where the user stopped reading in a book
class ReadingProgress {
  final String bookId;
  final String chapterId;
  final int charOffset;
  final double progress; // 0.0 - 1.0 for display
  final DateTime lastReadAt;

  const ReadingProgress({
    required this.bookId,
    required this.chapterId,
    required this.charOffset,
    this.progress = 0,
    required this.lastReadAt,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      charOffset: json['charOffset'] as int,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'chapterId': chapterId,
        'charOffset': charOffset,
        'progress': progress,
        'lastReadAt': lastReadAt.toIso8601String(),
      };
}
