# إضافة الكتب والملفات الصوتية — Adding Books & Audio

كلامكم نور يقرأ الكتب من مجلد التطبيق. لا توجد حزمة سحابية — كل شيء محلي.

---

## 1. أين أضع الكتب؟

**مسار المجلد:**
```
{مجلد التطبيق}/books/{book_id}/
```

**مثال (حسب المنصة):**
- **macOS:** `~/Library/Application Support/com.aliadnan.words_of_light/books/`
- **Windows:** `%APPDATA%\com.aliadnan.words_of_light\books\`
- **Android:** مجلد التطبيق الداخلي (استخدم إدارة الملفات أو ADB)

---

## 2. بنية المجلد

```
books/
└── nahj_al_balagha/
    ├── catalog.json
    ├── cover.png
    └── audio/
        ├── reader1/
        │   └── khutba1.ogg
        └── reader2/
            └── khutba1.ogg
```

---

## 3. ملف catalog.json

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
          "readerName": "اسم القارئ",
          "audioPath": "audio/reader1/khutba1.ogg",
          "segments": [
            {"startChar": 0, "endChar": 50, "startTime": 0.0, "endTime": 3.5}
          ]
        }
      ]
    }
  ],
  "availableReaders": [
    {"id": "reader1", "name": "اسم القارئ", "imagePath": null}
  ]
}
```

---

## 4. إضافة كتاب جديد

1. أنشئ مجلداً باسم فريد للكتاب داخل `books/`
2. أنشئ ملف `catalog.json` بالصيغة أعلاه
3. انسخ ملفات الصوت (MP3 أو OGG) إلى المسارات المحددة في `audioPath`
4. أعد تشغيل التطبيق أو اسحب للتحديث في المكتبة

---

## 5. إضافة المزيد من الصوت

- **مسار الصوت:** `audioPath` داخل كل فصل هو مسار نسبي لمجلد الكتاب
- **مثال:** `"audioPath": "audio/reader1/khutba1.ogg"` → الملف في `{book_folder}/audio/reader1/khutba1.ogg`
- **قارئ جديد:** أضف عنصراً جديداً في `audioRecordings` و `availableReaders` بنفس `readerId`

---

## 6. مزامنة النص مع الصوت (segments)

لتظليل النص أثناء التشغيل، أضف `segments`:

```json
"segments": [
  {"startChar": 0, "endChar": 50, "startTime": 0.0, "endTime": 3.5},
  {"startChar": 50, "endChar": 120, "startTime": 3.5, "endTime": 7.2}
]
```

- `startChar` / `endChar`: نطاق الأحرف في النص
- `startTime` / `endTime`: نطاق الوقت بالثواني في الملف الصوتي

يمكنك إنشاء هذه القيم يدوياً أو بأداة توقيت.

---

## 7. مصادر صوتية لنهج البلاغة

- **ويكيميديا كومنز:** [Category:Audio files in Arabic](https://commons.wikimedia.org/wiki/Category:Audio_files_in_Arabic)
- **Hussainiat.com:** محاضرات (إنجليزي عادة) — [Nahjul Balagha Lectures](https://hussainiat.com/album/3672/01-lecture-nahjul-balagha-the-worlds-greatest-boo/25464.aspx)
- **Al-Islam.org:** [Nahj al-Balagha](https://al-islam.org/nahjul-balagha)
- **balaghah.net:** [موقع نهج البلاغة](http://arabic.balaghah.net/)

الكتاب المدمج (عرض توضيحي) يستخدم الخطبة الأولى من نهج البلاغة مع ثلاثة خيارات للقارئ ومقاطع قصيرة (~15 حرف) للتظليل. الصوت من دار الكتاب العربي (مصدر: كتّاب / أرشيف الإنترنت).
