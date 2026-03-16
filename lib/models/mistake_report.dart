library;

/// User highlights text that was read incorrectly - for reader to fix
class MistakeReport {
  final String id;
  final String bookId;
  final String chapterId;
  final String readerId;
  final String readerName;
  final String highlightedText;
  final int startChar;
  final int endChar;
  final String? userNote;
  final DateTime reportedAt;
  final bool resolved;

  const MistakeReport({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.readerId,
    required this.readerName,
    required this.highlightedText,
    required this.startChar,
    required this.endChar,
    this.userNote,
    required this.reportedAt,
    this.resolved = false,
  });

  factory MistakeReport.fromJson(Map<String, dynamic> json) {
    return MistakeReport(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      chapterId: json['chapterId'] as String,
      readerId: json['readerId'] as String,
      readerName: json['readerName'] as String,
      highlightedText: json['highlightedText'] as String,
      startChar: json['startChar'] as int,
      endChar: json['endChar'] as int,
      userNote: json['userNote'] as String?,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      resolved: json['resolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'chapterId': chapterId,
        'readerId': readerId,
        'readerName': readerName,
        'highlightedText': highlightedText,
        'startChar': startChar,
        'endChar': endChar,
        'userNote': userNote,
        'reportedAt': reportedAt.toIso8601String(),
        'resolved': resolved,
      };

  MistakeReport copyWith({bool? resolved}) => MistakeReport(
        id: id,
        bookId: bookId,
        chapterId: chapterId,
        readerId: readerId,
        readerName: readerName,
        highlightedText: highlightedText,
        startChar: startChar,
        endChar: endChar,
        userNote: userNote,
        reportedAt: reportedAt,
        resolved: resolved ?? this.resolved,
      );
}
