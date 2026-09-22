part of 'subject_bloc.dart';

sealed class SubjectEvent extends Equatable {
  const SubjectEvent();
}

class GetSubjectEvent extends SubjectEvent {
  const GetSubjectEvent();

  @override
  List<Object?> get props => [];
}
