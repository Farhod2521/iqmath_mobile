part of 'battle_setup_bloc.dart';

enum BattleSetupStatus { initial, loading, loaded, error }

class BattleSetupState extends Equatable {
  final BattleSetupStatus status;
  final List<BattleSubjectModel> subjects;
  final List<BattleGradeStatModel> gradeStats;
  final BattleRatingModel? rating;
  final String? selectedGrade;
  final Set<int> selectedSubjectIds;
  final int questionCount;
  final int secondsPerQuestion;
  final String joinCode;
  final bool isSubmitting;
  final int? readyRoomId;
  final ({String title, String message})? errorMessage;

  const BattleSetupState({
    required this.status,
    required this.subjects,
    required this.gradeStats,
    required this.rating,
    required this.selectedGrade,
    required this.selectedSubjectIds,
    required this.questionCount,
    required this.secondsPerQuestion,
    required this.joinCode,
    required this.isSubmitting,
    required this.readyRoomId,
    required this.errorMessage,
  });

  factory BattleSetupState.initial() => const BattleSetupState(
        status: BattleSetupStatus.initial,
        subjects: [],
        gradeStats: [],
        rating: null,
        selectedGrade: null,
        selectedSubjectIds: {},
        questionCount: 10,
        secondsPerQuestion: 60,
        joinCode: '',
        isSubmitting: false,
        readyRoomId: null,
        errorMessage: null,
      );

  List<String> get availableGrades =>
      subjects.map((s) => s.className).toSet().toList()
        ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

  List<BattleSubjectModel> get subjectsForSelectedGrade => selectedGrade == null
      ? []
      : subjects.where((s) => s.className == selectedGrade).toList();

  bool get canCreateRoom =>
      selectedGrade != null && selectedSubjectIds.isNotEmpty && !isSubmitting;

  bool get canJoinRoom => joinCode.trim().isNotEmpty && !isSubmitting;

  BattleSetupState copyWith({
    BattleSetupStatus? status,
    List<BattleSubjectModel>? subjects,
    List<BattleGradeStatModel>? gradeStats,
    BattleRatingModel? rating,
    String? selectedGrade,
    Set<int>? selectedSubjectIds,
    int? questionCount,
    int? secondsPerQuestion,
    String? joinCode,
    bool? isSubmitting,
    int? readyRoomId,
    ({String title, String message})? errorMessage,
  }) {
    return BattleSetupState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      gradeStats: gradeStats ?? this.gradeStats,
      rating: rating ?? this.rating,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedSubjectIds: selectedSubjectIds ?? this.selectedSubjectIds,
      questionCount: questionCount ?? this.questionCount,
      secondsPerQuestion: secondsPerQuestion ?? this.secondsPerQuestion,
      joinCode: joinCode ?? this.joinCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      readyRoomId: readyRoomId ?? this.readyRoomId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        subjects,
        gradeStats,
        rating,
        selectedGrade,
        selectedSubjectIds,
        questionCount,
        secondsPerQuestion,
        joinCode,
        isSubmitting,
        readyRoomId,
        errorMessage,
      ];
}
