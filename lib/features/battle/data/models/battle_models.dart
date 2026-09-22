// Battle (1v1 matematik duel) — barcha model klasslari.
// iqmath_student veb ilovasi ishlatadigan API/WebSocket javob shakllari
// bilan bir xil maydon nomlariga mos qilib yozilgan.

import 'package:collection/collection.dart';

class BattleSubjectModel {
  final int id;
  final String className;
  final String nameUz;
  final String nameRu;

  BattleSubjectModel({
    required this.id,
    required this.className,
    required this.nameUz,
    required this.nameRu,
  });

  factory BattleSubjectModel.fromJson(Map<String, dynamic> json) {
    return BattleSubjectModel(
      id: json['id'] ?? 0,
      className: json['class_name']?.toString() ?? '',
      nameUz: json['name_uz']?.toString() ?? '',
      nameRu: json['name_ru']?.toString() ?? '',
    );
  }

  String name(String locale) => locale == 'ru' ? nameRu : nameUz;
}

class BattleGradeStatModel {
  final String name;
  final int totalMatches;
  final num winRate;

  BattleGradeStatModel({
    required this.name,
    required this.totalMatches,
    required this.winRate,
  });

  factory BattleGradeStatModel.fromJson(Map<String, dynamic> json) {
    return BattleGradeStatModel(
      name: json['name']?.toString() ?? '',
      totalMatches: json['total_matches'] ?? 0,
      winRate: json['win_rate'] ?? 0,
    );
  }
}

class BattleLevelProgressModel {
  final num? pctToNext;
  final num? ceiling;

  BattleLevelProgressModel({this.pctToNext, this.ceiling});

  factory BattleLevelProgressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BattleLevelProgressModel();
    return BattleLevelProgressModel(
      pctToNext: json['pct_to_next'],
      ceiling: json['ceiling'],
    );
  }
}

class BattleRatingModel {
  final bool isInPlacement;
  final int matchesPlayed;
  final int matchesLeftForPlacement;
  final int elo;
  final int level;
  final int wins;
  final int losses;
  final int draws;
  final int winStreak;
  final BattleLevelProgressModel levelProgress;

  BattleRatingModel({
    required this.isInPlacement,
    required this.matchesPlayed,
    required this.matchesLeftForPlacement,
    required this.elo,
    required this.level,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winStreak,
    required this.levelProgress,
  });

  factory BattleRatingModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : json;
    return BattleRatingModel(
      isInPlacement: data['is_in_placement'] == true,
      matchesPlayed: data['matches_played'] ?? 0,
      matchesLeftForPlacement: data['matches_left_for_placement'] ?? 0,
      elo: data['elo'] ?? 0,
      level: data['level'] ?? 1,
      wins: data['wins'] ?? 0,
      losses: data['losses'] ?? 0,
      draws: data['draws'] ?? 0,
      winStreak: data['win_streak'] ?? 0,
      levelProgress: BattleLevelProgressModel.fromJson(
          data['level_progress'] as Map<String, dynamic>?),
    );
  }

  int get totalMatches => wins + losses + draws;

  num get winRate => totalMatches == 0 ? 0 : (wins / totalMatches * 100);
}

class BattleChoiceModel {
  final int id;
  final String letter;
  final String textUz;
  final String textRu;

  BattleChoiceModel({
    required this.id,
    required this.letter,
    required this.textUz,
    required this.textRu,
  });

  factory BattleChoiceModel.fromJson(Map<String, dynamic> json) {
    return BattleChoiceModel(
      id: json['id'] ?? 0,
      letter: json['letter']?.toString() ?? '',
      textUz: json['text_uz']?.toString() ?? '',
      textRu: json['text_ru']?.toString() ?? '',
    );
  }

  String text(String locale) => locale == 'ru' ? textRu : textUz;
}

class BattleSubQuestionModel {
  final int id;
  final String text1Uz;
  final String text1Ru;

  BattleSubQuestionModel({
    required this.id,
    required this.text1Uz,
    required this.text1Ru,
  });

  factory BattleSubQuestionModel.fromJson(Map<String, dynamic> json) {
    return BattleSubQuestionModel(
      id: json['id'] ?? 0,
      text1Uz: json['text1_uz']?.toString() ?? '',
      text1Ru: json['text1_ru']?.toString() ?? '',
    );
  }

  String text(String locale) => locale == 'ru' ? text1Ru : text1Uz;
}

class BattleQuestionDataModel {
  final int id;
  final String questionType; // choice | image_choice | text | composite
  final String? questionCategory; // 'checkbox' bo'lsa — ko'p tanlovli
  final String questionTextUz;
  final String questionTextRu;
  final List<BattleChoiceModel> choices;
  final List<BattleSubQuestionModel> subQuestions;

  BattleQuestionDataModel({
    required this.id,
    required this.questionType,
    this.questionCategory,
    required this.questionTextUz,
    required this.questionTextRu,
    required this.choices,
    required this.subQuestions,
  });

  factory BattleQuestionDataModel.fromJson(Map<String, dynamic> json) {
    return BattleQuestionDataModel(
      id: json['id'] ?? 0,
      questionType: json['question_type']?.toString() ?? 'choice',
      questionCategory: json['question_category']?.toString(),
      questionTextUz: json['question_text_uz']?.toString() ?? '',
      questionTextRu: json['question_text_ru']?.toString() ?? '',
      choices: (json['choices'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BattleChoiceModel.fromJson)
          .toList(),
      subQuestions: (json['sub_questions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BattleSubQuestionModel.fromJson)
          .toList(),
    );
  }

  bool get isMultiSelect =>
      questionType == 'choice' && questionCategory == 'checkbox';

  String text(String locale) => locale == 'ru' ? questionTextRu : questionTextUz;
}

class BattleQuestionModel {
  final int order;
  final BattleQuestionDataModel question;

  BattleQuestionModel({required this.order, required this.question});

  factory BattleQuestionModel.fromJson(Map<String, dynamic> json) {
    return BattleQuestionModel(
      order: json['order'] ?? 0,
      question: BattleQuestionDataModel.fromJson(
          json['question'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class BattleParticipantModel {
  final String participantId;
  final bool isSelf;
  final String name;
  final int elo;
  final int level;
  final bool isPlacement;

  BattleParticipantModel({
    required this.participantId,
    required this.isSelf,
    required this.name,
    required this.elo,
    required this.level,
    required this.isPlacement,
  });

  factory BattleParticipantModel.fromJson(Map<String, dynamic> json) {
    return BattleParticipantModel(
      participantId: json['participant_id']?.toString() ?? '',
      isSelf: json['is_self'] == true,
      name: json['name']?.toString() ?? '',
      elo: json['elo'] ?? 0,
      level: json['level'] ?? 1,
      isPlacement: json['is_placement'] == true,
    );
  }
}

class BattleRoomModel {
  final String status; // waiting | active | finished | voided
  final int currentQuestionIndex;
  final BattleQuestionModel? currentQuestion;
  final int questionSecondsElapsed;
  final int secondsPerQuestion;
  final int questionCount;
  final String grade;
  final bool chatEnabled;
  final List<String> subjects;
  final List<BattleParticipantModel> participants;

  BattleRoomModel({
    required this.status,
    required this.currentQuestionIndex,
    required this.currentQuestion,
    required this.questionSecondsElapsed,
    required this.secondsPerQuestion,
    required this.questionCount,
    required this.grade,
    required this.chatEnabled,
    required this.subjects,
    required this.participants,
  });

  factory BattleRoomModel.fromJson(Map<String, dynamic> json) {
    return BattleRoomModel(
      status: json['status']?.toString() ?? 'waiting',
      currentQuestionIndex: json['current_question_index'] ?? 0,
      currentQuestion: json['current_question'] is Map<String, dynamic>
          ? BattleQuestionModel.fromJson(
              json['current_question'] as Map<String, dynamic>)
          : null,
      questionSecondsElapsed: json['question_seconds_elapsed'] ?? 0,
      secondsPerQuestion: json['seconds_per_question'] ?? 60,
      questionCount: json['question_count'] ?? 0,
      grade: json['grade']?.toString() ?? '',
      chatEnabled: json['chat_enabled'] == true,
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      participants: (json['participants'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BattleParticipantModel.fromJson)
          .toList(),
    );
  }

  BattleParticipantModel? get me =>
      participants.where((p) => p.isSelf).firstOrNull;

  BattleParticipantModel? get opponent =>
      participants.where((p) => !p.isSelf).firstOrNull;
}

class BattleResultEntryModel {
  final String participantId;
  final String result; // win | loss | draw
  final int score;
  final bool stillCalibrating;
  final int matchesPlayed;
  final int placementMatchesTotal;
  final bool isPlacementReveal;
  final int level;
  final int eloBefore;
  final int eloAfter;
  final int eloChange;

  BattleResultEntryModel({
    required this.participantId,
    required this.result,
    required this.score,
    required this.stillCalibrating,
    required this.matchesPlayed,
    required this.placementMatchesTotal,
    required this.isPlacementReveal,
    required this.level,
    required this.eloBefore,
    required this.eloAfter,
    required this.eloChange,
  });

  factory BattleResultEntryModel.fromJson(Map<String, dynamic> json) {
    return BattleResultEntryModel(
      participantId: json['participant_id']?.toString() ?? '',
      result: json['result']?.toString() ?? 'draw',
      score: json['score'] ?? 0,
      stillCalibrating: json['still_calibrating'] == true,
      matchesPlayed: json['matches_played'] ?? 0,
      placementMatchesTotal: json['placement_matches_total'] ?? 0,
      isPlacementReveal: json['is_placement_reveal'] == true,
      level: json['level'] ?? 1,
      eloBefore: json['elo_before'] ?? 0,
      eloAfter: json['elo_after'] ?? 0,
      eloChange: json['elo_change'] ?? 0,
    );
  }
}

class BattleFinishedResultModel {
  final List<BattleResultEntryModel> results;

  BattleFinishedResultModel({required this.results});

  factory BattleFinishedResultModel.fromJson(Map<String, dynamic> json) {
    return BattleFinishedResultModel(
      results: (json['results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BattleResultEntryModel.fromJson)
          .toList(),
    );
  }
}

class BattleChatMessageModel {
  final String participantId;
  final String name;
  final String text;
  final bool isSelf;

  BattleChatMessageModel({
    required this.participantId,
    required this.name,
    required this.text,
    this.isSelf = false,
  });

  factory BattleChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? selfParticipantId,
  }) {
    final participantId = json['participant_id']?.toString() ?? '';
    return BattleChatMessageModel(
      participantId: participantId,
      name: json['name']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isSelf: selfParticipantId != null && participantId == selfParticipantId,
    );
  }
}

class BattleHistoryOpponentModel {
  final String name;
  final int level;

  BattleHistoryOpponentModel({required this.name, required this.level});

  factory BattleHistoryOpponentModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BattleHistoryOpponentModel(name: '', level: 1);
    return BattleHistoryOpponentModel(
      name: json['name']?.toString() ?? '',
      level: json['level'] ?? 1,
    );
  }
}

class BattleHistoryItemModel {
  final BattleHistoryOpponentModel opponent;
  final List<String> subjects;
  final String result; // win | loss | draw
  final bool isPlacement;
  final bool isPlacementReveal;
  final int eloChange;

  BattleHistoryItemModel({
    required this.opponent,
    required this.subjects,
    required this.result,
    required this.isPlacement,
    required this.isPlacementReveal,
    required this.eloChange,
  });

  factory BattleHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return BattleHistoryItemModel(
      opponent: BattleHistoryOpponentModel.fromJson(
          json['opponent'] as Map<String, dynamic>?),
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      result: json['result']?.toString() ?? 'draw',
      isPlacement: json['is_placement'] == true,
      isPlacementReveal: json['is_placement_reveal'] == true,
      eloChange: json['elo_change'] ?? 0,
    );
  }
}

class BattleHistoryStatsModel {
  final int totalMatches;
  final int wins;
  final int losses;
  final num winRate;

  BattleHistoryStatsModel({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.winRate,
  });

  factory BattleHistoryStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BattleHistoryStatsModel(
          totalMatches: 0, wins: 0, losses: 0, winRate: 0);
    }
    return BattleHistoryStatsModel(
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      winRate: json['win_rate'] ?? 0,
    );
  }
}

class BattleHistoryResponseModel {
  final BattleHistoryStatsModel stats;
  final List<BattleHistoryItemModel> results;

  BattleHistoryResponseModel({required this.stats, required this.results});

  factory BattleHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : json;
    return BattleHistoryResponseModel(
      stats: BattleHistoryStatsModel.fromJson(
          data['stats'] as Map<String, dynamic>?),
      results: (data['results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BattleHistoryItemModel.fromJson)
          .toList(),
    );
  }
}

class BattleEloHistoryPointModel {
  final int eloAfter;
  final DateTime createdAt;

  BattleEloHistoryPointModel({required this.eloAfter, required this.createdAt});

  factory BattleEloHistoryPointModel.fromJson(Map<String, dynamic> json) {
    return BattleEloHistoryPointModel(
      eloAfter: json['elo_after'] ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}

class BattleLeaderboardEntryModel {
  final int studentId;
  final int rank;
  final String fullName;
  final String classUz;
  final int level;
  final int elo;
  final int wins;
  final int losses;
  final int draws;

  BattleLeaderboardEntryModel({
    required this.studentId,
    required this.rank,
    required this.fullName,
    required this.classUz,
    required this.level,
    required this.elo,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  factory BattleLeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return BattleLeaderboardEntryModel(
      studentId: json['student_id'] ?? 0,
      rank: json['rank'] ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      classUz: json['class_uz']?.toString() ?? '',
      level: json['level'] ?? 1,
      elo: json['elo'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
    );
  }
}
