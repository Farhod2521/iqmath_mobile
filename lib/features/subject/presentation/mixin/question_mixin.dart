mixin QuestionMixin {
  String parseLatexInHtml(String html) {
    // Format 1: <em>\\(...\\)</em> yoki <em>\(...\)</em>
    html = html.replaceAllMapped(
      RegExp(r'<em>\\\\?\((.+?)\\\\?\)</em>', dotAll: true),
      (match) {
        String latex = match.group(1)!;
        // Double backslash ni single ga
        latex = latex.replaceAll(r'\\', r'\');
        return '<latex>$latex</latex>';
      },
    );

    // Format 2: \\(...\\) - <em> tagsiz
    html = html.replaceAllMapped(
      RegExp(r'\\\\?\((.+?)\\\\?\)', dotAll: true),
      (match) {
        String latex = match.group(1)!;
        latex = latex.replaceAll(r'\\', r'\');
        return '<latex>$latex</latex>';
      },
    );

    // Format 3: <em>\\[...\\]</em> - Display math
    html = html.replaceAllMapped(
      RegExp(r'<em>\\\\?\[(.+?)\\\\?\]</em>', dotAll: true),
      (match) {
        String latex = match.group(1)!;
        latex = latex.replaceAll(r'\\', r'\');
        return '<latex>$latex</latex>';
      },
    );

    // Format 4: \\[...\\] - tagsiz
    html = html.replaceAllMapped(
      RegExp(r'\\\\?\[(.+?)\\\\?\]', dotAll: true),
      (match) {
        String latex = match.group(1)!;
        latex = latex.replaceAll(r'\\', r'\');
        return '<latex>$latex</latex>';
      },
    );

    // Format 5: $$...$$ - Display math
    html = html.replaceAllMapped(
      RegExp(r'\$\$(.+?)\$\$', dotAll: true),
      (match) {
        String latex = match.group(1)!;
        return '<latex>$latex</latex>';
      },
    );

    // Format 6: $...$ - Inline math
    html = html.replaceAllMapped(
      RegExp(r'\$(.+?)\$'),
      (match) {
        String latex = match.group(1)!;
        return '<latex>$latex</latex>';
      },
    );

    return html;
  }
}
