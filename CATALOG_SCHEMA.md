# كلامكم نور - دليل إضافة الكتب

كلامهم يحيي القلوب — خزانة صوتية متواضعة لأنوار حديثهم الطاهر، نُقدّمها بين أيديكم لاستماع ما يحيي القلوب ويُنير الصدور عليهم السلام.

## بنية المجلدات

يتم تخزين كل كتاب في مجلد مستقل:

```
Documents/books/{book_id}/
├── catalog.json      # وصف الكتاب (إلزامي)
├── cover.png         # غلاف الكتاب (اختياري)
└── audio/            # مجلد ملفات الصوت
    └── reader_id/
        └── chapter1.mp3
```

**ملاحظة:** مسار `Documents` يختلف حسب المنصة:
- **Android:** `/data/data/com.aliadnan.words_of_light/app_flutter/` أو مسار التطبيق (معرف الحزمة لم يتغير)
- **iOS:** مجلد التطبيق في الـ Sandbox
- **Desktop:** مجلد المستندات

## صيغة catalog.json

```json
{
  "id": "nahj_al_balagha",
  "titleAr": "نهج البلاغة",
  "titleEn": "Nahj al-Balagha",
  "author": "الإمام علي بن أبي طالب عليه السلام",
  "description": "مجموعة خطب ووصايا الإمام علي",
  "coverPath": "cover.png",
  "chapters": [
    {
      "id": "ch1",
      "title": "الخطبة الأولى",
      "content": "الحمد لله الذي لا يبلغ مدحته القائلون...",
      "audioRecordings": [
        {
          "readerId": "reader1",
          "readerName": "القارئ أحمد",
          "audioPath": "audio/reader1/ch1.mp3",
          "segments": [
            {
              "startChar": 0,
              "endChar": 50,
              "startTime": 0.0,
              "endTime": 3.5
            }
          ]
        }
      ]
    }
  ],
  "availableReaders": [
    {
      "id": "reader1",
      "name": "القارئ أحمد",
      "imagePath": null
    }
  ]
}
```

## توضيح الحقول

### الكتاب
| الحقل | النوع | الوصف |
|-------|------|-------|
| id | string | معرف فريد للكتاب |
| titleAr | string | العنوان بالعربية |
| titleEn | string | العنوان بالإنجليزية (اختياري) |
| author | string | اسم المؤلف |
| description | string | وصف موجز |
| coverPath | string? | مسار الغلاف نسبياً لمجلد الكتاب |
| chapters | array | قائمة الفصول |
| availableReaders | array | قائمة القراء |

### الفصل (Chapter)
| الحقل | النوع | الوصف |
|-------|------|-------|
| id | string | معرف الفصل |
| title | string | عنوان الفصل |
| content | string | نص الفصل الكامل |
| audioRecordings | array | تسجيلات صوتية (قارئ واحد أو أكثر) |

### التسجيل الصوتي (AudioRecording)
| الحقل | النوع | الوصف |
|-------|------|-------|
| readerId | string | معرف القارئ |
| readerName | string | اسم القارئ |
| audioPath | string | مسار ملف MP3 نسبياً لمجلد الكتاب |
| segments | array | مقاطع لمزامنة النص مع الصوت |

### المقطع (Segment) - لمزامنة التظليل
| الحقل | النوع | الوصف |
|-------|------|-------|
| startChar | int | بداية النص (حرف) |
| endChar | int | نهاية النص (حرف) |
| startTime | number | بداية الصوت (ثانية) |
| endTime | number | نهاية الصوت (ثانية) |

**مثال:** إذا كان `content` يبدأ بـ "الحمد لله" و"الحمد" من 0 إلى 5، فالمقطع سيكون:
```json
{"startChar": 0, "endChar": 5, "startTime": 0.0, "endTime": 0.8}
```

## إضافة الكتب

1. أنشئ مجلداً باسم فريد للكتاب داخل `Documents/books/`
2. انسخ ملف الغلاف كـ `cover.png` (إن وجد)
3. أنشئ ملف `catalog.json` بالصيغة أعلاه
4. انسخ ملفات الصوت إلى المسارات المحددة في `audioPath`
5. أعد تشغيل التطبيق أو اسحب للتحديث في المكتبة

## القارئ (Reader)

يمكن أن يكون للفصل الواحد أكثر من قارئ. يختار المستخدم القارئ من القائمة. كل قارئ له تسجيله ومقاطعه الخاصة.
