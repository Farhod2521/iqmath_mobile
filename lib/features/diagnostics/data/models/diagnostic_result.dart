// "Natijalarim" (diagnostika xatolar tahlili) sahifasi modellari.
// Backend: app_student/View/app_diagnost.py
//   GET /func_student/my-diagnost/subjects/<subject_id>/attempts/
//   GET /func_student/my-diagnost/<diagnost_id>/mistakes/

String _pick(Map<String, dynamic> json, String field, String lang) {
  final uz = json['${field}_uz']?.toString() ?? '';
  if (lang != 'ru') return uz;
  final ru = json['${field}_ru']?.toString() ?? '';
  return ru.isNotEmpty ? ru : uz;
}

class DiagnosticSubjectInfo {
  final int id;
  final String nameUz;
  final String nameRu;
  final String className;

  const DiagnosticSubjectInfo({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.className,
  });

  factory DiagnosticSubjectInfo.fromJson(Map<String, dynamic> json) =>
      DiagnosticSubjectInfo(
        id: (json['id'] as num?)?.toInt() ?? 0,
        nameUz: json['name_uz']?.toString() ?? '',
        nameRu: json['name_ru']?.toString() ?? '',
        className: json['class_name']?.toString() ?? '',
      );

  String name(String lang) =>
      lang == 'ru' && nameRu.isNotEmpty ? nameRu : nameUz;
}

/// Bitta diagnostika urinishi (qisqa ma'lumot).
class DiagnosticAttempt {
  final int id;
  final String? date; // "dd.MM.yyyy HH:mm"
  final double score;
  final int total;
  final int correct;
  final int wrong;
  final int unanswered;
  final int? durationSeconds;
  final bool hasAnswers;

  const DiagnosticAttempt({
    required this.id,
    required this.date,
    required this.score,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.durationSeconds,
    required this.hasAnswers,
  });

  int get scoreInt => score.round().clamp(0, 100);

  String get day => (date ?? '').split(' ').first;

  String get time {
    final parts = (date ?? '').split(' ');
    return parts.length > 1 ? parts[1] : '';
  }

  factory DiagnosticAttempt.fromJson(Map<String, dynamic> json) =>
      DiagnosticAttempt(
        id: (json['id'] as num?)?.toInt() ?? 0,
        date: json['date']?.toString(),
        score: (json['score'] as num?)?.toDouble() ?? 0,
        total: (json['total_answers'] as num?)?.toInt() ?? 0,
        correct: (json['correct_answers'] as num?)?.toInt() ?? 0,
        wrong: (json['wrong_answers'] as num?)?.toInt() ?? 0,
        unanswered: (json['unanswered_answers'] as num?)?.toInt() ?? 0,
        durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
        hasAnswers: json['has_answers'] == true,
      );
}

class DiagnosticChoice {
  final int id;
  final String letter;
  final Map<String, dynamic> raw;
  final String? imageUrl;
  final bool isCorrect;
  final bool isSelected;

  const DiagnosticChoice({
    required this.id,
    required this.letter,
    required this.raw,
    required this.imageUrl,
    required this.isCorrect,
    required this.isSelected,
  });

  String text(String lang) => _pick(raw, 'text', lang);

  factory DiagnosticChoice.fromJson(Map<String, dynamic> json) =>
      DiagnosticChoice(
        id: (json['id'] as num?)?.toInt() ?? 0,
        letter: json['letter']?.toString() ?? '',
        raw: json,
        imageUrl: (json['image_url']?.toString().isNotEmpty ?? false)
            ? json['image_url'].toString()
            : null,
        isCorrect: json['is_correct'] == true,
        isSelected: json['is_selected'] == true,
      );
}

class DiagnosticSubQuestion {
  final String correctAnswer;
  final String? studentAnswer;

  const DiagnosticSubQuestion({
    required this.correctAnswer,
    required this.studentAnswer,
  });

  factory DiagnosticSubQuestion.fromJson(Map<String, dynamic> json) =>
      DiagnosticSubQuestion(
        correctAnswer: json['correct_answer']?.toString() ?? '',
        studentAnswer: (json['student_answer']?.toString().trim().isEmpty ??
                true)
            ? null
            : json['student_answer'].toString(),
      );
}

/// Savol holati: to'g'ri / xato / javoblanmagan.
enum QuestionStatus { correct, wrong, unanswered }

class DiagnosticQuestion {
  final int number;
  final int questionId;
  final String type; // choice | image_choice | text | composite
  final Map<String, dynamic> raw;
  final bool isCorrect;
  final bool hasAnswer;
  final bool isAnswered;
  final List<DiagnosticChoice> choices;
  final List<DiagnosticSubQuestion> subQuestions;
  final String? studentAnswer;

  const DiagnosticQuestion({
    required this.number,
    required this.questionId,
    required this.type,
    required this.raw,
    required this.isCorrect,
    required this.hasAnswer,
    required this.isAnswered,
    required this.choices,
    required this.subQuestions,
    required this.studentAnswer,
  });

  QuestionStatus get status => isCorrect
      ? QuestionStatus.correct
      : !isAnswered
          ? QuestionStatus.unanswered
          : QuestionStatus.wrong;

  bool get isChoice => type == 'choice' || type == 'image_choice';

  String text(String lang) => _pick(raw, 'question_text', lang);

  String topic(String lang) => _pick(raw, 'topic', lang);

  String correctTextAnswer(String lang) => _pick(raw, 'correct_answer', lang);

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) => ((json[key] as List?) ??
            const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final answer = json['student_answer'];
    return DiagnosticQuestion(
      number: (json['number'] as num?)?.toInt() ?? 0,
      questionId: (json['question_id'] as num?)?.toInt() ?? 0,
      type: json['question_type']?.toString() ?? 'choice',
      raw: json,
      isCorrect: json['is_correct'] == true,
      hasAnswer: json['has_answer'] == true,
      isAnswered: json['is_answered'] != false,
      choices: list('choices').map(DiagnosticChoice.fromJson).toList(),
      subQuestions:
          list('sub_questions').map(DiagnosticSubQuestion.fromJson).toList(),
      studentAnswer:
          (answer == null || answer.toString().trim().isEmpty) ? null : '$answer',
    );
  }
}
