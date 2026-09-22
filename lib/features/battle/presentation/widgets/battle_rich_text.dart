import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Savol/variant matnini (HTML + LaTeX aralash) chizadi.
///
/// `question_page.dart`dagi `_buildLatexText` bilan bir xil yondashuv:
/// oddiy HTML teglari regex bilan tozalanadi, `\(...\)`/`\[...\]` ichidagi
/// LaTeX qismlar esa `Math.tex` orqali chiziladi. Bu ilova hech qayerda
/// `flutter_html` paketidan (Html widget) foydalanmaydi — shu pattern
/// takrorlanadi, izchillik uchun.
class BattleRichText extends StatelessWidget {
  final String html;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const BattleRichText(
    this.html, {
    super.key,
    this.fontSize = 15,
    this.color = const Color(0xFF191C1D),
    this.fontWeight = FontWeight.w500,
    this.textAlign = TextAlign.start,
  });

  static String _stripHtmlTags(String html) {
    var text = html;
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    return text;
  }

  static String _cleanHtmlEntities(String text) {
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&deg;', '°')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final cleaned = _cleanHtmlEntities(_stripHtmlTags(html));
    final pattern = RegExp(r'\\\((.*?)\\\)|\\\[(.*?)\\\]', dotAll: true);
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in pattern.allMatches(cleaned)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: cleaned.substring(lastEnd, match.start)));
      }
      final latex = (match.group(1) ?? match.group(2) ?? '').trim();
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _safeMath(latex),
          ),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < cleaned.length) {
      spans.add(TextSpan(text: cleaned.substring(lastEnd)));
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }

  Widget _safeMath(String latex) {
    try {
      return Math.tex(
        latex,
        textStyle: TextStyle(fontSize: fontSize + 2, color: color),
        mathStyle: MathStyle.text,
      );
    } catch (_) {
      return Text(latex, style: const TextStyle(color: Color(0xFFE5484D)));
    }
  }
}
