import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

/// Settings screen - theme, about, and instructions for adding books.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionTitle(title: 'المظهر'),
            _ThemeTile(),
            const Divider(height: 32),
            const _SectionTitle(title: 'إضافة الكتب'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لإضافة كتب جديدة بشكل يدوي:\n\n'
                '1. أنشئ مجلداً باسم الكتاب في: Documents/books/{book_id}\n'
                '2. أنشئ ملف catalog.json يصف الكتاب والفصول والصوت\n'
                '3. أضف غلافاً (cover.png) وملفات الصوت (mp3) كما في catalog.json\n\n'
                'راجع الملفات التوضيحية في المشروع لمعرفة صيغة catalog.json.',
                style: TextStyle(height: 1.6),
                textAlign: TextAlign.right,
              ),
            ),
            const Divider(height: 32),
            const _SectionTitle(title: 'حول التطبيق'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('كلامكم نور'),
              subtitle: Text('كلامهم يحيي القلوب — خزانة صوتية متواضعة لأنوار حديثهم الطاهر، نُقدّمها بين أيديكم لاستماع ما يحيي القلوب ويُنير الصدور عليهم السلام'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        return Card(
          child: RadioGroup<String>(
            groupValue: app.themeMode,
            onChanged: (value) {
              if (value != null) app.setThemeMode(value);
            },
            child: const Column(
              children: [
                RadioListTile<String>(title: Text('نظام'), value: 'system'),
                RadioListTile<String>(title: Text('فاتح'), value: 'light'),
                RadioListTile<String>(title: Text('داكن'), value: 'dark'),
              ],
            ),
          ),
        );
      },
    );
  }
}
