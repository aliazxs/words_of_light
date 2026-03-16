/// Core models for كلامكم نور - Arabic audiobook library
library;

class Book {
  final String id;
  final String titleAr;
  final String titleEn;
  final String author;
  final String description;
  final String? coverPath;
  final List<Chapter> chapters;
  final List<Reader> availableReaders;

  const Book({
    required this.id,
    required this.titleAr,
    this.titleEn = '',
    required this.author,
    this.description = '',
    this.coverPath,
    required this.chapters,
    this.availableReaders = const [],
  });

  String get displayTitle => titleAr;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String? ?? '',
      author: json['author'] as String,
      description: json['description'] as String? ?? '',
      coverPath: json['coverPath'] as String?,
      chapters: (json['chapters'] as List)
          .map((c) => Chapter.fromJson(c as Map<String, dynamic>))
          .toList(),
      availableReaders: (json['availableReaders'] as List?)
              ?.map((r) => Reader.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'author': author,
        'description': description,
        'coverPath': coverPath,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'availableReaders': availableReaders.map((r) => r.toJson()).toList(),
      };
}

class Chapter {
  final String id;
  final String title;
  final String content;
  final List<AudioRecording> audioRecordings;

  const Chapter({
    required this.id,
    required this.title,
    required this.content,
    this.audioRecordings = const [],
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      audioRecordings: (json['audioRecordings'] as List?)
              ?.map((r) => AudioRecording.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'audioRecordings': audioRecordings.map((r) => r.toJson()).toList(),
      };
}

class AudioRecording {
  final String readerId;
  final String readerName;
  final String audioPath;
  final List<AudioSegment> segments;

  const AudioRecording({
    required this.readerId,
    required this.readerName,
    required this.audioPath,
    this.segments = const [],
  });

  factory AudioRecording.fromJson(Map<String, dynamic> json) {
    return AudioRecording(
      readerId: json['readerId'] as String,
      readerName: json['readerName'] as String,
      audioPath: json['audioPath'] as String,
      segments: (json['segments'] as List?)
              ?.map((s) => AudioSegment.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'readerId': readerId,
        'readerName': readerName,
        'audioPath': audioPath,
        'segments': segments.map((s) => s.toJson()).toList(),
      };
}

/// Maps character range in text to audio timestamp for sync highlighting
class AudioSegment {
  final int startChar;
  final int endChar;
  final double startTime;
  final double endTime;

  const AudioSegment({
    required this.startChar,
    required this.endChar,
    required this.startTime,
    required this.endTime,
  });

  factory AudioSegment.fromJson(Map<String, dynamic> json) {
    return AudioSegment(
      startChar: json['startChar'] as int,
      endChar: json['endChar'] as int,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'startChar': startChar,
        'endChar': endChar,
        'startTime': startTime,
        'endTime': endTime,
      };
}

class Reader {
  final String id;
  final String name;
  final String? imagePath;

  const Reader({
    required this.id,
    required this.name,
    this.imagePath,
  });

  factory Reader.fromJson(Map<String, dynamic> json) {
    return Reader(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
      };
}
