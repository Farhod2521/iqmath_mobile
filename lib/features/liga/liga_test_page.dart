import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/math_html_text.dart';
import '../../core/widgets/top_notification.dart';
import '../rewards/rewards_api.dart';
import 'liga_api.dart';
import 'liga_review.dart';
import 'liga_texts.dart';
import 'liga_widgets.dart';

/// Haftalik liga testini ishlash (saytdagi LigaTestRun): vaqt serverdan olinadi, har javob darhol saqlanadi,
/// ilova yopilib qayta ochilsa o'sha joyidan davom etadi. Testdan chiqish — test yakunlanadi.
class LigaTestPage extends StatefulWidget {
  const LigaTestPage({super.key, required this.attemptId});

  final int attemptId;

  @override
  State<LigaTestPage> createState() => _LigaTestPageState();
}

class _LigaTestPageState extends State<LigaTestPage> {
  Map<String, dynamic>? _attempt;
  final Map<int, Map<String, dynamic>> _answers = {};
  final _textController = TextEditingController();
  final _scroll = ScrollController();
  int _index = 0;
  int _remaining = 0;
  DateTime _endAt = DateTime.now();
  Timer? _timer;
  bool _error = false;
  bool _finishing = false;

  bool get _running => _attempt?['status'] == 'in_progress';
  List<Map<String, dynamic>> get _questions => asMapList(_attempt?['questions']);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await LigaApi.attempt(widget.attemptId);
      if (!mounted) return;
      setState(() {
        _attempt = data;
        _error = false;
      });
      if (data['status'] != 'in_progress') {
        _timer?.cancel();
        GolStore.refresh(); // test uchun gol qo'shilgan bo'lishi mumkin
        return;
      }
      final remaining = asInt(data['remaining_seconds']);
      _endAt = DateTime.now().add(Duration(seconds: remaining));
      _remaining = remaining;
      _answers
        ..clear()
        ..addEntries(asMapList(data['answers']).map((a) => MapEntry(asInt(a['question']), a)));
      _syncTextField();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _tick() {
    final left = _endAt.difference(DateTime.now()).inSeconds;
    if (!mounted) return;
    setState(() => _remaining = left < 0 ? 0 : left);
    if (left <= 0) {
      _timer?.cancel();
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    _timer?.cancel();
    try {
      await LigaApi.finish(widget.attemptId);
    } catch (_) {}
    await _load(); // natija (by_subject bilan) qayta o'qiladi
    if (mounted) setState(() => _finishing = false);
  }

  void _go(int index) {
    if (index < 0 || index >= _questions.length) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
    _syncTextField();
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _syncTextField() {
    if (_questions.isEmpty) return;
    final q = _questions[_index.clamp(0, _questions.length - 1)];
    _textController.text = '${_answers[asInt(q['id'])]?['text_answer'] ?? ''}';
  }

  Future<void> _save(int questionId, {int? choice, String? textAnswer}) async {
    setState(() => _answers[questionId] = {
          'question': questionId,
          if (choice != null) 'choice': choice,
          if (textAnswer != null) 'text_answer': textAnswer,
        });
    try {
      await LigaApi.answer(widget.attemptId, questionId, choice: choice, textAnswer: textAnswer);
    } catch (e) {
      if (!mounted) return;
      if (LigaApi.statusCode(e) == 400) {
        _load(); // vaqt tugagan yoki test yopilgan
      } else {
        TopNotification.showError(context, message: lt(_locale, 'saveError'));
      }
    }
  }

  String get _locale => context.read<AppBloc>().state.appLocale ?? 'uz';

  Future<void> _confirmFinish() async {
    final left = _questions.where((q) => !_answers.containsKey(asInt(q['id']))).length;
    final ok = await showLigaDialog(
      context,
      icon: Icons.check_circle_outline_rounded,
      title: lt(_locale, 'finishTitle'),
      text: left > 0 ? ltf(_locale, 'finishConfirmLeft', left) : lt(_locale, 'finishConfirm'),
      confirmLabel: lt(_locale, 'finish'),
      cancelLabel: lt(_locale, 'stay'),
    );
    if (ok) _finish();
  }

  Future<void> _confirmLeave() async {
    final ok = await showLigaDialog(
      context,
      icon: Icons.warning_amber_rounded,
      title: lt(_locale, 'leaveTitle'),
      text: lt(_locale, 'leave'),
      confirmLabel: lt(_locale, 'leaveConfirm'),
      cancelLabel: lt(_locale, 'stay'),
      danger: true,
    );
    if (!ok) return;
    _timer?.cancel();
    try {
      await LigaApi.finish(widget.attemptId);
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  void _showRules() {
    showLigaDialog(
      context,
      icon: Icons.info_outline_rounded,
      title: lt(_locale, 'rulesTitle'),
      confirmLabel: lt(_locale, 'rulesOk'),
      body: Column(
        children: [
          for (final rule in ligaRules(_locale))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_rounded, size: 18, color: LigaColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rule, style: const TextStyle(fontSize: 13.5, color: LigaColors.text, height: 1.4))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppBloc, String>((b) => b.state.appLocale ?? 'uz');
    final attempt = _attempt;
    Widget body;
    if (_error && attempt == null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lt(locale, 'error'), style: const TextStyle(color: LigaColors.red)),
            TextButton(onPressed: _load, child: Text(lt(locale, 'retry'))),
          ],
        ),
      );
    } else if (attempt == null) {
      body = const Center(child: CircularProgressIndicator(color: LigaColors.primary));
    } else if (!_running) {
      body = _Result(attempt: attempt, locale: locale);
    } else {
      body = _runView(locale, attempt);
    }

    return PopScope(
      canPop: !_running,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _running) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: LigaColors.bg,
        body: SafeArea(
          child: LigaWatermark(viewer: attempt?['viewer'] as String?, child: body),
        ),
      ),
    );
  }

  Widget _runView(String locale, Map<String, dynamic> attempt) {
    final questions = _questions;
    if (questions.isEmpty) return const SizedBox.shrink();
    final index = _index.clamp(0, questions.length - 1);
    final q = questions[index];
    final qid = asInt(q['id']);
    final current = _answers[qid];
    final subjects = questions.map((e) => '${e['subject_name'] ?? ''}').toSet().join(', ');
    final percent = ((index + 1) / questions.length * 100).round();
    final isLast = index == questions.length - 1;
    String pick(Map item, String field) {
      final ru = item['${field}_ru'];
      return '${locale == 'ru' && ru != null && '$ru'.isNotEmpty ? ru : item['${field}_uz'] ?? ''}';
    }

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        // Sarlavha
        Row(
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _confirmLeave,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.arrow_back_rounded, color: LigaColors.ink),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ltf(locale, 'weekTest', attempt['week_number']),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                  Text('$subjects • ${ltf(locale, 'questions', questions.length)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: LigaColors.muted)),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showRules,
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              label: Text(lt(locale, 'rules')),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFDFE6F2)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TimerCard(remaining: _remaining, label: lt(locale, 'remaining')),
        const SizedBox(height: 12),
        LigaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: LigaColors.chip, borderRadius: BorderRadius.circular(12)),
                    child: Text('${index + 1} / ${questions.length}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 9,
                        backgroundColor: const Color(0xFFE4ECF8),
                        color: LigaColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$percent%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: LigaColors.text)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: LigaColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                    child: Text(ltf(locale, 'questionTitle', index + 1),
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: LigaColors.primary)),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: LigaColors.chip, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.layers_outlined, size: 15, color: Color(0xFF334155)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text('${q['subject_name'] ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MathHtmlText(
                pick(q, 'question_text'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: LigaColors.ink, height: 1.45),
                imageMaxHeight: 240,
              ),
              if (q['image'] != null && '${q['image']}'.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(_absUrl('${q['image']}'), fit: BoxFit.contain),
                ),
              ],
              const SizedBox(height: 18),
              if (q['question_type'] == 'choice')
                for (final choice in asMapList(q['choices'])) ...[
                  _choiceTile(locale, qid, choice, current?['choice'] == choice['id'], pick),
                  const SizedBox(height: 10),
                ]
              else
                _textAnswer(locale, qid),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: index == 0 ? null : () => _go(index - 1),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(lt(locale, 'prev')),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(0, 48),
                        backgroundColor: const Color(0xFFEEF2F8),
                        foregroundColor: const Color(0xFF334155),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: isLast
                        ? LigaButton(
                            label: lt(locale, 'finish'),
                            icon: null,
                            color: LigaColors.teal,
                            busy: _finishing,
                            expand: true,
                            onTap: _confirmFinish,
                          )
                        : LigaButton(label: lt(locale, 'next'), expand: true, onTap: () => _go(index + 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _questionMap(locale, questions, index),
        const SizedBox(height: 12),
        _info(locale, attempt, questions, subjects),
      ],
    );
  }

  String _absUrl(String url) => ligaAbsUrl(url);

  Widget _choiceTile(
    String locale,
    int qid,
    Map<String, dynamic> choice,
    bool active,
    String Function(Map, String) pick,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _save(qid, choice: asInt(choice['id']));
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? LigaColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? LigaColors.primary : const Color(0xFFDFE6F2), width: active ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? LigaColors.primary : LigaColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${choice['letter'] ?? ''}',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: active ? Colors.white : LigaColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MathHtmlText(
                    pick(choice, 'text'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: LigaColors.ink),
                  ),
                  if (choice['image'] != null && '${choice['image']}'.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(_absUrl('${choice['image']}'), height: 120, fit: BoxFit.contain),
                      ),
                    ),
                ],
              ),
            ),
            if (active) const Icon(Icons.check_circle_rounded, color: LigaColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _textAnswer(String locale, int qid) {
    final saved = '${_answers[qid]?['text_answer'] ?? ''}';
    void submit() {
      final value = _textController.text.trim();
      if (value.isEmpty) return;
      FocusScope.of(context).unfocus();
      _save(qid, textAnswer: value);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _textController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: LigaColors.ink),
            decoration: InputDecoration(
              hintText: lt(locale, 'answerPlaceholder'),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFDFE6F2))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFDFE6F2))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: LigaColors.primary, width: 1.6)),
              suffixIcon: IconButton(
                onPressed: submit,
                icon: const Icon(Icons.check_circle_rounded, color: LigaColors.primary),
                tooltip: lt(locale, 'save'),
              ),
            ),
          ),
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 16, color: LigaColors.green),
                  const SizedBox(width: 4),
                  Text('${lt(locale, 'saved')}: $saved',
                      style: const TextStyle(fontSize: 12.5, color: LigaColors.green, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _questionMap(String locale, List<Map<String, dynamic>> questions, int index) {
    Widget legend(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 12, color: LigaColors.text)),
          ],
        );
    return LigaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ltf(locale, 'questionsTitle', questions.length),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: LigaColors.ink)),
          const SizedBox(height: 6),
          Wrap(spacing: 12, runSpacing: 4, children: [
            legend(const Color(0xFF22C55E), lt(locale, 'answered')),
            legend(LigaColors.primary, lt(locale, 'currentQuestion')),
            legend(const Color(0xFFCBD9EE), lt(locale, 'unanswered')),
          ]),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.15,
            children: [
              for (var i = 0; i < questions.length; i++)
                Builder(builder: (_) {
                  final answered = _answers.containsKey(asInt(questions[i]['id']));
                  final isCurrent = i == index;
                  return InkWell(
                    onTap: () => _go(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? LigaColors.primary
                            : answered
                                ? const Color(0xFFDFF7EA)
                                : const Color(0xFFEEF3FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${i + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? Colors.white
                                : answered
                                    ? LigaColors.green
                                    : const Color(0xFF334155),
                          )),
                    ),
                  );
                }),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: _finishing ? null : _confirmFinish,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE6F8F2),
                foregroundColor: const Color(0xFF0F8A68),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(lt(locale, 'finish'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String locale, Map<String, dynamic> attempt, List<Map<String, dynamic>> questions, String subjects) {
    final maxScore = questions.fold<int>(0, (sum, q) => sum + asInt(q['score']));
    final start = parseDate(attempt['started_at']);
    final end = parseDate(attempt['deadline_at']);
    final minutes = start != null && end != null ? end.difference(start).inMinutes : 0;
    final rows = [
      (Icons.layers_outlined, lt(locale, 'subject'), subjects),
      (Icons.bar_chart_rounded, lt(locale, 'questionCount'), ltf(locale, 'questions', questions.length)),
      (Icons.schedule_rounded, lt(locale, 'allotted'), ltf(locale, 'minutes', minutes)),
      (Icons.track_changes_rounded, lt(locale, 'maxScore'), ltf(locale, 'golN', maxScore)),
    ];
    return LigaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.description_outlined, color: LigaColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(lt(locale, 'infoTitle'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LigaColors.ink)),
          ]),
          const Divider(height: 22, color: Color(0xFFEDF1F8)),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(r.$1, size: 18, color: LigaColors.text),
                  const SizedBox(width: 8),
                  Text('${r.$2}: ', style: const TextStyle(fontSize: 13.5, color: LigaColors.text)),
                  Expanded(
                    child: Text(r.$3,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: LigaColors.ink)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Qolgan vaqt: ko'k, oxirgi daqiqada qizil
class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.remaining, required this.label});

  final int remaining;
  final String label;

  @override
  Widget build(BuildContext context) {
    final danger = remaining <= 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: danger ? const [Color(0xFFF87171), Color(0xFFDC2626)] : const [Color(0xFF46B1F4), Color(0xFF1F6FEB)],
        ),
        boxShadow: [
          BoxShadow(
            color: (danger ? const Color(0xFFDC2626) : LigaColors.primary).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 38),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
              Text(
                ligaClock(remaining),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 125 -> "02:05", 3725 -> "01:02:05"
String ligaClock(dynamic seconds) {
  final total = asInt(seconds) < 0 ? 0 : asInt(seconds);
  String two(int v) => v.toString().padLeft(2, '0');
  final h = total ~/ 3600;
  return '${h > 0 ? '${two(h)}:' : ''}${two((total % 3600) ~/ 60)}:${two(total % 60)}';
}

/// Test natijasi: gol, foiz, to'g'ri / xato / vaqt va fanlar bo'yicha
class _Result extends StatelessWidget {
  const _Result({required this.attempt, required this.locale});

  final Map<String, dynamic> attempt;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final total = asInt(attempt['total_questions']);
    final correct = asInt(attempt['correct_count']);
    final unanswered = (total - asInt(attempt['answered_count'])).clamp(0, total);
    final percent = total > 0 ? (correct / total * 100).round() : 0;
    final subjects = asMapList(attempt['by_subject']);
    final tiles = [
      (Icons.check_circle_outline_rounded, LigaColors.greenSoft, LigaColors.green, lt(locale, 'correct'), '$correct', null),
      (Icons.cancel_outlined, LigaColors.redSoft, LigaColors.red, lt(locale, 'wrong'), '${asInt(attempt['wrong_count'])}',
          unanswered > 0 ? ltf(locale, 'unansweredPart', unanswered) : null),
      (Icons.schedule_rounded, LigaColors.primarySoft, LigaColors.primary, lt(locale, 'time'),
          ligaClock(attempt['duration_seconds']), null),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        Row(children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.arrow_back_rounded, color: LigaColors.ink)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              [
                lt(locale, 'navLiga'),
                if (attempt['grade_name'] != null) ltf(locale, 'grade', attempt['grade_name']),
                if (attempt['week_number'] != null) ltf(locale, 'weekTest', attempt['week_number']),
              ].join('  ›  '),
              style: const TextStyle(fontSize: 13.5, color: LigaColors.text),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        LigaCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const LigaIconBox(icon: Icons.emoji_events_outlined, size: 64),
              const SizedBox(height: 14),
              Text(lt(locale, 'resultTitle'),
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: LigaColors.ink)),
              if (attempt['status'] == 'expired') ...[
                const SizedBox(height: 6),
                Text(lt(locale, 'expired'),
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: LigaColors.muted)),
              ],
              const SizedBox(height: 18),
              Text(lt(locale, 'score'), style: const TextStyle(fontSize: 13.5, color: LigaColors.muted)),
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: '${asInt(attempt['score'])}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: LigaColors.primary),
                ),
                TextSpan(
                  text: ' / ${asInt(attempt['max_score'])}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                ),
              ])),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE4ECF8),
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('$percent%', style: const TextStyle(fontWeight: FontWeight.w700, color: LigaColors.text)),
              ]),
              const SizedBox(height: 18),
              for (final t in tiles)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEDF1F8)),
                  ),
                  child: Row(children: [
                    LigaIconBox(icon: t.$1, bg: t.$2, color: t.$3),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$4, style: const TextStyle(fontSize: 12.5, color: LigaColors.muted)),
                          Text(t.$5, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                          if (t.$6 != null) Text(t.$6!, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ]),
                ),
            ],
          ),
        ),
        if (subjects.isNotEmpty) ...[
          const SizedBox(height: 12),
          LigaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.layers_outlined, color: LigaColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(lt(locale, 'bySubject'),
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                ]),
                const SizedBox(height: 12),
                for (final row in subjects)
                  Builder(builder: (_) {
                    final rowTotal = asInt(row['total']) > 0 ? asInt(row['total']) : asInt(row['answered']);
                    final rowCorrect = asInt(row['correct']);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text('${row['subject'] ?? ''}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LigaColors.ink)),
                            ),
                            Text(ltf(locale, 'correctOf', rowCorrect, rowTotal),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: LigaColors.text)),
                          ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: rowTotal > 0 ? rowCorrect / rowTotal : 0,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE4ECF8),
                              color: LigaColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        LigaReviewSection(attempt: attempt, locale: locale),
        const SizedBox(height: 16),
        Center(
          child: LigaButton(
            label: lt(locale, 'back'),
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}
