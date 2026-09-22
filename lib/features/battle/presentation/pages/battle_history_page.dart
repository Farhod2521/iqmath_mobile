import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/domain/usecases/battle_usecases.dart';
import 'package:my_flutter_template/features/battle/presentation/blocs/history/battle_history_bloc.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_player_avatar.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_theme.dart';
import 'package:my_flutter_template/injector_container.dart';

class BattleHistoryPage extends StatelessWidget {
  const BattleHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BattleHistoryBloc(
        getBattleHistoryUseCase: sl<GetBattleHistoryUseCase>(),
        getBattleEloHistoryUseCase: sl<GetBattleEloHistoryUseCase>(),
      )..add(const LoadBattleHistoryEvent()),
      child: const _BattleHistoryView(),
    );
  }
}

class _BattleHistoryView extends StatelessWidget {
  const _BattleHistoryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return Scaffold(
          backgroundColor: BattleColors.background,
          appBar: AppBar(
            backgroundColor: BattleColors.background,
            elevation: 0,
            foregroundColor: BattleColors.ink,
            title: Text(locale == 'ru' ? 'История матчей' : "O'yinlar tarixi"),
          ),
          body: BlocBuilder<BattleHistoryBloc, BattleHistoryState>(
            builder: (context, state) {
              if (state.status == BattleHistoryStatus.loading ||
                  state.status == BattleHistoryStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == BattleHistoryStatus.error) {
                return Center(
                  child: Text(
                    state.errorMessage?.message ??
                        (locale == 'ru' ? 'Ошибка' : 'Xatolik yuz berdi'),
                    style: const TextStyle(color: BattleColors.muted),
                  ),
                );
              }

              final history = state.history!;
              return RefreshIndicator(
                onRefresh: () async => context
                    .read<BattleHistoryBloc>()
                    .add(const LoadBattleHistoryEvent()),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _statsCard(history.stats, locale),
                    if (state.eloHistory.length > 1) ...[
                      const SizedBox(height: 16),
                      _eloChartCard(state.eloHistory, locale),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      locale == 'ru' ? 'Последние матчи' : "So'nggi o'yinlar",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800, color: BattleColors.ink),
                    ),
                    const SizedBox(height: 10),
                    if (history.results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            locale == 'ru' ? 'Пока нет матчей' : "Hozircha o'yin yo'q",
                            style: const TextStyle(fontSize: 12.5, color: BattleColors.muted),
                          ),
                        ),
                      )
                    else
                      ...history.results.map((item) => _historyTile(item, locale)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statsCard(BattleHistoryStatsModel stats, String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BattleColors.primary, BattleColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _statTile('${stats.totalMatches}', locale == 'ru' ? 'Матчи' : "O'yinlar"),
          _statDivider(),
          _statTile('${stats.wins}', locale == 'ru' ? 'Победы' : "G'alaba"),
          _statDivider(),
          _statTile('${stats.winRate.toStringAsFixed(0)}%',
              locale == 'ru' ? '% побед' : "G'alaba %"),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 1, height: 32, color: Colors.white24);

  Widget _statTile(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _eloChartCard(List<BattleEloHistoryPointModel> points, String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0E1A4C).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ru' ? 'Динамика ELO' : 'ELO dinamikasi',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: BattleColors.ink),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _EloSparklinePainter(points.map((p) => p.eloAfter).toList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(BattleHistoryItemModel item, String locale) {
    final resultColor = item.result == 'win'
        ? BattleColors.historyWin
        : item.result == 'loss'
            ? BattleColors.historyLoss
            : BattleColors.muted;
    final resultLabel = item.result == 'win'
        ? (locale == 'ru' ? 'Победа' : "G'alaba")
        : item.result == 'loss'
            ? (locale == 'ru' ? 'Поражение' : "Mag'lubiyat")
            : (locale == 'ru' ? 'Ничья' : 'Durrang');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BattleColors.border),
      ),
      child: Row(
        children: [
          BattlePlayerAvatar(
              name: item.opponent.name, level: item.opponent.level, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.opponent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: BattleColors.ink)),
                const SizedBox(height: 3),
                Text(item.subjects.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: BattleColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(resultLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: resultColor)),
              ),
              const SizedBox(height: 4),
              if (item.isPlacementReveal)
                Text(locale == 'ru' ? 'Уровень определён' : 'Daraja aniqlandi',
                    style: const TextStyle(fontSize: 10.5, color: BattleColors.muted))
              else if (item.isPlacement)
                Text(locale == 'ru' ? 'Квалификация' : 'Saralash',
                    style: const TextStyle(fontSize: 10.5, color: BattleColors.muted))
              else
                Text(
                  '${item.eloChange > 0 ? '+' : ''}${item.eloChange} ELO',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: item.eloChange >= 0 ? BattleColors.historyWin : BattleColors.historyLoss,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EloSparklinePainter extends CustomPainter {
  final List<int> values;

  _EloSparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    final range = (maxV - minV).abs() < 1 ? 1.0 : (maxV - minV);

    final path = Path();
    final stepX = size.width / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final x = stepX * i;
      final normalized = (values[i] - minV) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = BattleColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [BattleColors.primary.withOpacity(0.18), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _EloSparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}
