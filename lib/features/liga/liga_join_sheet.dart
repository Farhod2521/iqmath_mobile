import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/dash_ui.dart';
import 'liga_texts.dart';

const _blue = Color(0xFF1F6FEB);
const _blueTop = Color(0xFF2F80FF);
const _blueBottom = Color(0xFF1764E8);
const _navy = Color(0xFF0B1B3F);
const _line = Color(0xFFDCE5F2);

/// "Asosiy qoidalar" bloki hozircha ko'rsatilmaydi — qaytarish uchun true qiling
const _showRules = false;

/// Qoidalar ikonkalari — ligaJoinRules() tartibida (saytdagi LigaJoinModal bilan bir xil)
const _ruleIcons = [
  Icons.track_changes_rounded,
  Icons.event_note_rounded,
  Icons.bar_chart_rounded,
  Icons.workspace_premium_rounded,
  Icons.balance_rounded,
  Icons.lock_outline_rounded,
];

/// Ligaga qo'shilish oynasi: sinf tanlash, sovg'a va hujjat haqida eslatma, asosiy qoidalar, rozilik.
/// G'olib sovg'ani guvohnoma / pasport bilan oladi — sinf hujjatdagi bilan bir xil bo'lishi shart.
/// Qaytaradi: tanlangan sinf id'si yoki null (bekor qilindi).
Future<int?> showLigaJoinSheet(
  BuildContext context, {
  required String locale,
  required List<Map<String, dynamic>> grades,
  int? initialGrade,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: _navy.withOpacity(0.45),
    builder: (_) => _JoinSheet(locale: locale, grades: grades, initialGrade: initialGrade),
  );
}

class _JoinSheet extends StatefulWidget {
  const _JoinSheet({required this.locale, required this.grades, this.initialGrade});

  final String locale;
  final List<Map<String, dynamic>> grades;
  final int? initialGrade;

  @override
  State<_JoinSheet> createState() => _JoinSheetState();
}

class _JoinSheetState extends State<_JoinSheet> {
  int? _grade;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    // Profildagi sinf ro'yxatda bo'lsa — oldindan belgilanadi
    final ids = widget.grades.map((g) => asInt(g['id'])).toSet();
    _grade = ids.contains(widget.initialGrade) ? widget.initialGrade : null;
  }

  String get locale => widget.locale;

  bool _isNumeric(String name) => RegExp(r'\d').hasMatch(name);

  @override
  Widget build(BuildContext context) {
    final canJoin = _grade != null && _accepted;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(Icons.school_outlined, lt(locale, 'chooseGrade')),
                  const SizedBox(height: 10),
                  _gradeGrid(),
                  const SizedBox(height: 16),
                  _banner(),
                  const SizedBox(height: 16),
                  if (_showRules) ...[
                    _rules(),
                    const SizedBox(height: 16),
                  ],
                  _acceptRow(),
                ],
              ),
            ),
          ),
          _buttons(canJoin),
        ],
      ),
    );
  }

  // Sarlavha: yumshoq ko'k fon, ikonka, sarlavha, kubok va yopish tugmasi
  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F8FF), Colors.white, Color(0xFFE6F0FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 54,
            top: 6,
            child: Image.asset('assets/images/join_trophy.png', width: 92, height: 92, fit: BoxFit.contain),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: _navy.withOpacity(0.3),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(padding: EdgeInsets.all(9), child: Icon(Icons.close_rounded, color: _navy, size: 22)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(color: const Color(0xFFD3DCEA), borderRadius: BorderRadius.circular(3)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3B8BFF), _blueBottom],
                        ),
                        boxShadow: [BoxShadow(color: _blueBottom.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.groups_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lt(locale, 'joinDialogTitle'),
                                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _navy, height: 1.15)),
                            const SizedBox(height: 4),
                            Text(lt(locale, 'joinDialogText'),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.35)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(icon, color: _blue, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _navy)),
          ],
        ),
      );

  Widget _gradeGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.35,
      children: [
        for (final g in widget.grades)
          Builder(builder: (_) {
            final id = asInt(g['id']);
            final name = '${g['name'] ?? ''}';
            final numeric = _isNumeric(name);
            final active = _grade == id;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _grade = id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: active
                      ? const LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_blueTop, _blueBottom])
                      : null,
                  color: active ? null : Colors.white,
                  border: Border.all(color: active ? Colors.transparent : _line),
                  boxShadow: active
                      ? [BoxShadow(color: _blueBottom.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (active) ...[
                      const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 3),
                    ],
                    Icon(numeric ? Icons.menu_book_outlined : Icons.science_outlined,
                        size: 17, color: active ? Colors.white : _blue),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        numeric ? ltf(locale, 'grade', name) : name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: active ? Colors.white : _navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // Sovg'a va hujjat haqida eslatma (to'q sariq banner)
  Widget _banner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFBE3B6)),
        gradient: const LinearGradient(colors: [Color(0xFFFFF8EA), Color(0xFFFFF1DA)]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lt(locale, 'bannerTitle'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFC2410C))),
                const SizedBox(height: 4),
                Text(lt(locale, 'gradeWarning'),
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF9A3412), height: 1.45)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Image.asset('assets/images/join_gift.png', width: 64, height: 64, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _rules() {
    final rules = ligaJoinRules(locale);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEEF4FD), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: _blue, size: 22),
              const SizedBox(width: 8),
              Text(lt(locale, 'rulesMain'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _navy)),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rules.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == rules.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_ruleIcons[i % _ruleIcons.length], color: _blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(rules[i],
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B), height: 1.45)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _acceptRow() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _accepted = !_accepted);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(4, 6, 14, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _accepted ? const Color(0xFFF2F7FF) : Colors.white,
          border: Border.all(color: _accepted ? _blue : _line, width: _accepted ? 1.4 : 1),
        ),
        child: Row(
          children: [
            Checkbox(
              value: _accepted,
              activeColor: _blue,
              side: const BorderSide(color: Color(0xFF94A3B8), width: 1.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              onChanged: (v) => setState(() => _accepted = v ?? false),
            ),
            Expanded(
              child: Text(lt(locale, 'accept'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _navy, height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttons(bool canJoin) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: _navy.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  label: Text(lt(locale, 'cancel'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF2F8),
                    foregroundColor: _navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: canJoin ? 1 : 0.5,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_blueTop, _blueBottom]),
                    boxShadow: canJoin
                        ? [BoxShadow(color: _blueBottom.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: canJoin
                          ? () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).pop(_grade);
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 21),
                          const SizedBox(width: 8),
                          Text(lt(locale, 'joinConfirm'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
