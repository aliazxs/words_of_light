import 'dart:async';

import 'package:flutter/material.dart';

import '../services/audio_service.dart';

/// Displays book text with sync highlighting during audio playback.
/// Supports selectable text with "Report mistake" in context menu.
class HighlightableText extends StatefulWidget {
  final String text;
  final Stream<HighlightRange?> highlightStream;
  final void Function(int charOffset) onScrollOffset;
  final void Function(String text, int start, int end) onReportMistake;
  final void Function(int charOffset, [String? text]) onBookmark;

  const HighlightableText({
    super.key,
    required this.text,
    required this.highlightStream,
    required this.onScrollOffset,
    required this.onReportMistake,
    required this.onBookmark,
  });

  @override
  State<HighlightableText> createState() => _HighlightableTextState();
}

class _HighlightableTextState extends State<HighlightableText> {
  final ScrollController _scrollController = ScrollController();
  HighlightRange? _currentHighlight;
  StreamSubscription<HighlightRange?>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.highlightStream.listen((range) {
      if (mounted) setState(() => _currentHighlight = range);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Approximate char offset from scroll position (rough)
    final extent = _scrollController.position.extentInside;
    final offset = _scrollController.offset;
    if (extent > 0 && widget.text.isNotEmpty) {
      final ratio = offset / extent;
      final charOffset = (widget.text.length * ratio).clamp(0, widget.text.length).toInt();
      widget.onScrollOffset(charOffset);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.6);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: SelectableText.rich(
        _buildTextSpan(highlightColor),
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 20,
          height: 1.8,
          fontFamily: theme.textTheme.bodyLarge?.fontFamily,
        ),
        contextMenuBuilder: (context, editableTextState) {
          final selection = editableTextState.currentTextEditingValue.selection;
          if (!selection.isValid || selection.isCollapsed) {
            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: editableTextState.contextMenuButtonItems,
            );
          }
          final start = selection.start;
          final end = selection.end;
          final selectedText = widget.text.substring(
            start.clamp(0, widget.text.length),
            end.clamp(0, widget.text.length),
          );
          if (selectedText.isEmpty) {
            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: editableTextState.contextMenuButtonItems,
            );
          }
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: [
              ...editableTextState.contextMenuButtonItems,
              ContextMenuButtonItem(
                label: 'الإبلاغ عن خطأ في القراءة',
                onPressed: () {
                  widget.onReportMistake(selectedText, start, end);
                  editableTextState.hideToolbar();
                },
              ),
              ContextMenuButtonItem(
                label: 'حفظ الصفحة',
                onPressed: () {
                  widget.onBookmark(start, selectedText);
                  editableTextState.hideToolbar();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  TextSpan _buildTextSpan(Color highlightColor) {
    if (widget.text.isEmpty) {
      return const TextSpan(text: '');
    }
    final range = _currentHighlight;
    if (range == null) {
      return TextSpan(text: widget.text);
    }
    final start = range.startIndex.clamp(0, widget.text.length);
    final end = range.endIndex.clamp(0, widget.text.length);
    if (start >= end) {
      return TextSpan(text: widget.text);
    }
    final before = widget.text.substring(0, start);
    final highlighted = widget.text.substring(start, end);
    final after = widget.text.substring(end);
    return TextSpan(
      children: [
        TextSpan(text: before),
        TextSpan(
          text: highlighted,
          style: TextStyle(backgroundColor: highlightColor),
        ),
        TextSpan(text: after),
      ],
    );
  }
}
