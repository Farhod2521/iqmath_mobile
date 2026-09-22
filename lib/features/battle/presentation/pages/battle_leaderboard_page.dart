import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/domain/usecases/battle_usecases.dart';
import 'package:my_flutter_template/features/battle/presentation/blocs/leaderboard/battle_leaderboard_bloc.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_player_avatar.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_theme.dart';
import 'package:my_flutter_template/injector_container.dart';

class BattleLeaderboardPage extends StatelessWidget {
  const BattleLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BattleLeaderboardBloc(
        getBattleLeaderboardUseCase: sl<GetBattleLeaderboardUseCase>(),
      )..add(const LoadBattleLeaderboardEvent()),
      child: const _BattleLeaderboardView(),
    );
  }
}

class _BattleLeaderboardView extends StatelessWidget {
  const _BattleLeaderboardView();

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
            title: Text(locale == 'ru' ? 'Рейтинг' : 'Reyting jadvali'),
          ),
          body: BlocBuilder<BattleLeaderboardBloc, BattleLeaderboardState>(
            builder: (context, state) {
              if (state.status == BattleLeaderboardStatus.loading ||
                  state.status == BattleLeaderboardStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == BattleLeaderboardStatus.error) {
                return Center(
                  child: Text(
                    state.errorMessage?.message ??
                        (locale == 'ru' ? 'Ошибка' : 'Xatolik yuz berdi'),
                    style: const TextStyle(color: BattleColors.muted),
                  ),
                );
              }

              final entries = state.entries;
              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    locale == 'ru' ? 'Рейтинг пуст' : "Reyting bo'sh",
                    style: const TextStyle(fontSize: 12.5, color: BattleColors.muted),
                  ),
                );
              }

              final podium = entries.take(3).toList();
              final rest = entries.length > 3 ? entries.sublist(3) : <BattleLeaderboardEntryModel>[];

              return RefreshIndicator(
                onRefresh: () async => context
                    .read<BattleLeaderboardBloc>()
                    .add(const LoadBattleLeaderboardEvent()),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    if (podium.isNotEmpty) _podium(podium),
                    const SizedBox(height: 20),
                    ...rest.map((entry) => _leaderboardTile(entry, locale)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _podium(List<BattleLeaderboardEntryModel> top) {
    final first = top.isNotEmpty ? top[0] : null;
    final second = top.length > 1 ? top[1] : null;
    final third = top.length > 2 ? top[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BattleColors.primary, BattleColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (second != null) _podiumEntry(second, height: 84, medalColor: const Color(0xFFC0C0C0)),
          if (first != null) _podiumEntry(first, height: 108, medalColor: const Color(0xFFFFD700)),
          if (third != null) _podiumEntry(third, height: 66, medalColor: const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _podiumEntry(BattleLeaderboardEntryModel entry, {required double height, required Color medalColor}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
            child: Text('${entry.rank}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(height: 6),
          BattlePlayerAvatar(name: entry.fullName, level: entry.level, size: 48),
          const SizedBox(height: 6),
          Text(
            entry.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          Text('${entry.elo}',
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: height * 0.35,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaderboardTile(BattleLeaderboardEntryModel entry, String locale) {
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
          SizedBox(
            width: 28,
            child: Text('${entry.rank}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: BattleColors.muted)),
          ),
          BattlePlayerAvatar(name: entry.fullName, level: entry.level, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: BattleColors.ink)),
                const SizedBox(height: 3),
                Text(entry.classUz,
                    style: const TextStyle(fontSize: 11.5, color: BattleColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.elo}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BattleColors.primary)),
              const SizedBox(height: 2),
              Text(
                '${entry.wins}W ${entry.losses}L ${entry.draws}D',
                style: const TextStyle(fontSize: 10.5, color: BattleColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
