import 'package:flutter/material.dart';

import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/math_html_text.dart';
import 'liga_texts.dart';
import 'liga_widgets.dart';

String ligaAbsUrl(String url) => url.startsWith('http') ? url : 'https://api.iqmath.uz$url';

/// Test natijasi tahlili: har bir savol — o'quvchi belgilagani, to'g'ri javob, to'g'ri/xato/javobsiz va olingan gol.
/// To'g'ri javoblar test oynasi yopilgandan keyin ochiladi (review_available).
class LigaReviewSection extends StatefulWidget {
  const LigaReviewSection({super.key, required this.attempt, required this.locale});

  final Map<String, dynamic> attempt;
  final String locale;

  @override
  State<LigaReviewSection> createState() => _LigaReviewSectionState();
}

class _LigaReviewSectionState extends State<LigaReviewSection> {
  String _filter = 'all';
  final Set<int> _open = {};

  String get _locale => widget.locale;

  static const _styles = {
    'correct': (LigaColors.greenSoft, LigaColors.green, Icons.check_circle_rounded),
    'wrong': (LigaColors.redSoft, LigaColors.red, Icons.cancel_rounded),
    'skipped': (Color(0xFFF1F5FB), Color(0xFF64748B), Icons.remove_circle_outline_rounded),
  };

  String _pick(Map item, String field) {
    final ru = item['${field}_ru'];
    return '${_locale == 'ru' && ru != null && '$ru'.isNotEmpty ? ru : item['${field}_uz'] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;
    if (attempt['review_available'] == false) {
      return LigaCard(
        child: Row(children: [
          const LigaIconBox(icon: Icons.lock_clock_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lt(_locale, 'rvTitle'),
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                const SizedBox(height: 4),
                Text(ltf(_locale, 'rvLocked', fmtDateTime(attempt['review_available_at'])),
                    style: const TextStyle(fontSize: 13, color: LigaColors.text, height: 1.35)),
              ],
            ),
          ),
        ]),
      );
    }

    final items = asMapList(attempt['review']);
    if (items.isEmpty) return const SizedBox.shrink();
    int count(String r) => items.where((i) => i['result'] == r).length;
    final visible = _filter == 'all' ? items : items.where((i) => i['result'] == _filter).toList();

    return LigaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.fact_check_outlined, color: LigaColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(lt(_locale, 'rvTitle'),
                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(lt(_locale, 'rvHint'), style: const TextStyle(fontSize: 12.5, color: LigaColors.muted)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip('all', '${lt(_locale, 'all')} (${items.length})'),
              _chip('correct', '${lt(_locale, 'correct')} (${count('correct')})'),
              _chip('wrong', '${lt(_locale, 'wrong')} (${count('wrong')})'),
              _chip('skipped', '${lt(_locale, 'unanswered')} (${count('skipped')})'),
            ]),
          ),
          const SizedBox(height: 12),
          // Savollar xaritasi: rang — natija, bosilsa savol ochiladi
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                Builder(builder: (_) {
                  final style = _styles[item['result']] ?? _styles['skipped']!;
                  final n = asInt(item['number']);
                  return InkWell(
                    onTap: () => setState(() {
                      _filter = 'all';
                      _open.add(n);
                    }),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: style.$1, borderRadius: BorderRadius.circular(10)),
                      child: Text('$n', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: style.$2)),
                    ),
                  );
                }),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in visible) _tile(item),
        ],
      ),
    );
  }

  Widget _chip(String key, String label) {
    final active = _filter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _filter = key),
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : const Color(0xFF334155),
        ),
        selectedColor: LigaColors.primary,
        backgroundColor: LigaColors.chip,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _tile(Map<String, dynamic> item) {
    final n = asInt(item['number']);
    final q = Map<String, dynamic>.from(item['question'] as Map? ?? {});
    final result = '${item['result']}';
    final style = _styles[result] ?? _styles['skipped']!;
    final open = _open.contains(n);
    final earned = asInt(item['earned_score']);
    final maxScore = asInt(item['max_score']);
    final label = result == 'correct'
        ? lt(_locale, 'correct')
        : result == 'wrong'
            ? lt(_locale, 'wrong')
            : lt(_locale, 'unanswered');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.$2.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => open ? _open.remove(n) : _open.add(n)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: style.$1, borderRadius: BorderRadius.circular(12)),
                  child: Text('$n', style: TextStyle(fontWeight: FontWeight.w800, color: style.$2)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(style.$3, size: 16, color: style.$2),
                        const SizedBox(width: 4),
                        Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: style.$2)),
                      ]),
                      Text(
                        '${q['subject_name'] ?? ''}  •  ${_answerLine(item)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: LigaColors.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: earned > 0 ? LigaColors.greenSoft : LigaColors.chip,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('+$earned / $maxScore',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: earned > 0 ? LigaColors.green : LigaColors.muted,
                      )),
                ),
                Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: LigaColors.muted),
              ]),
            ),
          ),
          if (open) _details(item, q),
        ],
      ),
    );
  }

  /// "Siz: B • To'g'ri: C"
  String _answerLine(Map<String, dynamic> item) {
    final q = item['question'] as Map? ?? {};
    final mine = q['question_type'] == 'choice' ? item['selected_letter'] : item['text_answer'];
    final right = q['question_type'] == 'choice' ? item['correct_letter'] : q['correct_text_answer'];
    return '${lt(_locale, 'rvYours')}: ${mine ?? '—'}  •  ${lt(_locale, 'rvRight')}: ${right ?? '—'}';
  }

  Widget _details(Map<String, dynamic> item, Map<String, dynamic> q) {
    final selected = item['selected_choice'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFEDF1F8)),
          const SizedBox(height: 10),
          MathHtmlText(
            _pick(q, 'question_text'),
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: LigaColors.ink, height: 1.4),
            imageMaxHeight: 200,
          ),
          if (q['image'] != null && '${q['image']}'.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(ligaAbsUrl('${q['image']}'), fit: BoxFit.contain),
            ),
          ],
          const SizedBox(height: 12),
          if (q['question_type'] == 'choice')
            for (final choice in asMapList(q['choices']))
              _choice(choice, isMine: selected != null && asInt(selected) == asInt(choice['id']))
          else ...[
            _textRow(lt(_locale, 'rvYours'), item['text_answer'],
                item['result'] == 'correct' ? LigaColors.green : (item['result'] == 'wrong' ? LigaColors.red : LigaColors.muted)),
            _textRow(lt(_locale, 'rvRight'), q['correct_text_answer'], LigaColors.green),
          ],
        ],
      ),
    );
  }

  Widget _choice(Map<String, dynamic> choice, {required bool isMine}) {
    final isRight = choice['is_correct'] == true;
    final Color border;
    final Color bg;
    if (isRight) {
      border = LigaColors.green;
      bg = LigaColors.greenSoft;
    } else if (isMine) {
      border = LigaColors.red;
      bg = LigaColors.redSoft;
    } else {
      border = const Color(0xFFDFE6F2);
      bg = Colors.white;
    }
    final tag = isMine && isRight
        ? lt(_locale, 'rvYourRight')
        : isMine
            ? lt(_locale, 'rvYourWrong')
            : isRight
                ? lt(_locale, 'rvRight')
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: isRight || isMine ? 1.5 : 1),
      ),
      child: Row(children: [
        Container(
          width: 34,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isRight || isMine ? border : LigaColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('${choice['letter'] ?? ''}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isRight || isMine ? Colors.white : LigaColors.primary,
              )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MathHtmlText(
                _pick(choice, 'text'),
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: LigaColors.ink),
              ),
              if (choice['image'] != null && '${choice['image']}'.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(ligaAbsUrl('${choice['image']}'), height: 100, fit: BoxFit.contain),
                  ),
                ),
              if (tag != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(tag, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: border)),
                ),
            ],
          ),
        ),
        if (isRight) const Icon(Icons.check_circle_rounded, color: LigaColors.green, size: 20),
        if (isMine && !isRight) const Icon(Icons.cancel_rounded, color: LigaColors.red, size: 20),
      ]),
    );
  }

  Widget _textRow(String label, dynamic value, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Text.rich(TextSpan(children: [
        TextSpan(text: '$label: ', style: const TextStyle(fontSize: 13.5, color: LigaColors.text)),
        TextSpan(
          text: value == null || '$value'.isEmpty ? '—' : '$value',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: color),
        ),
      ])),
    );
  }
}
