part of 'subject_bloc.dart';

class SubjectState extends Equatable {
  final SubjectStateStatus status;
  final SubjectResponse? subjectResponse;
  final ({String title, String message})? errorMessage;
  final Map<String, List<SubjectResponse>>? groupedSubjects;

  SubjectState copyWith({
    SubjectStateStatus? status,
    SubjectResponse? subjectResponse,
    ({String title, String message})? errorMessage,
    Map<String, List<SubjectResponse>>? groupedSubjects,
  }) {
    return SubjectState(
      status: status ?? this.status,
      subjectResponse: subjectResponse ?? this.subjectResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      groupedSubjects: groupedSubjects ?? this.groupedSubjects,
    );
  }

  const SubjectState({
    this.status = SubjectStateStatus.initial,
    this.subjectResponse,
    this.errorMessage,
    this.groupedSubjects,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        status,
        subjectResponse,
        errorMessage,
        groupedSubjects,
      ];
}

enum SubjectStateStatus { initial, loading, loaded, error }

extension SubjectStateStatusX on SubjectStateStatus {
  bool get isInitial => this == SubjectStateStatus.initial;

  bool get isLoading => this == SubjectStateStatus.loading;

  bool get isLoaded => this == SubjectStateStatus.loaded;

  bool get isError => this == SubjectStateStatus.error;
}
