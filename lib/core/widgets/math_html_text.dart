import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:html/parser.dart' as html_parser;

/// Backend'dan keladigan savol / variant HTML matnini ko'rsatadi:
/// teglar olib tashlanadi, HTML entity'lar ochiladi, `\( \)` va `\[ \]`
/// ichidagi LaTeX formulalar chiziladi, `<img>` (base64 yoki URL) rasm
/// sifatida chiqadi. Savol sahifasidagi `_buildQuestionText` bilan bir xil
/// mantiq — natijalar sahifasida qayta ishlatish uchun alohida vidjet.
class MathHtmlText extends StatelessWidget {
  final String html;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final double imageMaxHeight;

  const MathHtmlText(
    this.html, {
    super.key,
    this.style = const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.imageMaxHeight = 180,
  });

  static final _imgPattern =
      RegExp(r'''<img[^>]*src=["']([^"']+)["'][^>]*>''', caseSensitive: false);
  static final _latexPattern =
      RegExp(r'\\\((.+?)\\\)|\\\[(.+?)\\\]', dotAll: true);
  static final Map<String, Uint8List> _imageCache = {};

  /// Teglarsiz, entity'lari ochilgan oddiy matn.
  static String plainText(String html) {
    final prepared = html
        .replaceAll(RegExp(r'</p>\s*', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    final text = html_parser.parseFragment(prepared).text ?? '';
    return text.replaceAll(' ', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final images = _imgPattern.allMatches(html).toList();
    final textPart = html.replaceAll(_imgPattern, '');
    final text = plainText(textPart);

    final children = <Widget>[
      if (text.isNotEmpty) _richText(text),
      for (final match in images) _image(match.group(1)!),
    ];
    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) return children.first;
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          children[i],
        ],
      ],
    );
  }

  Widget _richText(String text) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in _latexPattern.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      final latex = (match.group(1) ?? match.group(2) ?? '').trim();
      if (latex.isNotEmpty) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Math.tex(
              latex,
              textStyle: style.copyWith(fontSize: (style.fontSize ?? 15) + 1),
              mathStyle: MathStyle.text,
              onErrorFallback: (_) => Text(latex, style: style),
            ),
          ),
        ));
      }
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }

  Widget _image(String src) {
    Widget image;
    if (src.startsWith('data:image')) {
      final base64Part = src.substring(src.indexOf(',') + 1);
      final bytes = _imageCache.putIfAbsent(base64Part, () {
        try {
          return base64Decode(base64Part);
        } catch (_) {
          return Uint8List(0);
        }
      });
      if (bytes.isEmpty) return const SizedBox.shrink();
      image = Image.memory(bytes, fit: BoxFit.contain, gaplessPlayback: true);
    } else {
      final url = src.startsWith('http') ? src : 'https://api.iqmath.uz$src';
      image = Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined,
            color: Color(0xFF8E8E93)),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: imageMaxHeight),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: image),
    );
  }
}
