import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../models/mistake_report.dart';
import '../providers/app_provider.dart';

/// Screen listing all mistake reports for readers to review and fix.
class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقارير الأخطاء'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<AppProvider>().refreshBooks(),
            ),
          ],
        ),
        body: Consumer<AppProvider>(
          builder: (context, app, _) {
            return FutureBuilder<List<MistakeReport>>(
              future: app.getMistakeReports(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = snap.data!;
                if (reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد تقارير أخطاء',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'عندما يبلغ المستخدمون عن نص قُرئ بشكل خاطئ، سيظهر هنا',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    app.refreshBooks();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, i) => _MistakeCard(report: reports[i]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final MistakeReport report;

  const _MistakeCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.highlightedText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'inherit',
                        ),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (report.resolved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('مُصلح'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'القارئ: ${report.readerName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              dateFormat.format(report.reportedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (report.userNote != null && report.userNote!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('ملاحظة: ${report.userNote}'),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!report.resolved)
                  TextButton(
                    onPressed: () {
                      context.read<AppProvider>().markMistakeResolved(report.id);
                    },
                    child: const Text('تحديد كمُصلح'),
                  ),
                TextButton(
                  onPressed: () {
                    _confirmRemove(context);
                  },
                  child: Text(
                    'حذف',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التقرير'),
        content: const Text('هل تريد حذف هذا التقرير؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().removeMistakeReport(report.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
