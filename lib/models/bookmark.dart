library;

/// User-saved page or passage they liked
class Bookmark {
  final String id;
  final String bookId;
  final String chapterId;
  final String title;
  final int charOffset;
  final String? highlightedText;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.title,
    required this.charOffset,
    this.highlightedText,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      title: json['title'] as String,
      charOffset: json['charOffset'] as int,
      highlightedText: json['highlightedText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'chapterId': chapterId,
        'title': title,
        'charOffset': charOffset,
        'highlightedText': highlightedText,
        'createdAt': createdAt.toIso8601String(),
      };
}
