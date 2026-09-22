import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/mixins/base_bloc_mixin.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../data/models/subject_response.dart';
import '../../../domain/usecases/get_subject_usecase.dart';

part 'subject_event.dart';

part 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> with BaseBlocMixin {
  final GetSubjectUseCase getSubjectUseCase;

  SubjectBloc({
    required this.getSubjectUseCase,
  }) : super(SubjectState()) {
    on<GetSubjectEvent>(_getSubjectHandler);
  }

  FutureOr<void> _getSubjectHandler(
      GetSubjectEvent event, Emitter<SubjectState> emit) async {
    emit(state.copyWith(status: SubjectStateStatus.loading));
    final result = await getSubjectUseCase.call(NoParams());
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SubjectStateStatus.error,
            errorMessage: getErrorMessage(failure),
          ),
        );
      },
      (subjectResponse) {
        final Map<String, List<SubjectResponse>> bookCategories = {};
        for (var subject in subjectResponse) {
          if (!bookCategories.containsKey(subject.nameUz)) {
            bookCategories[subject.nameUz ?? ''] = [];
          }
          bookCategories[subject.nameUz]?.add(subject);
        }
        emit(
          state.copyWith(
            status: SubjectStateStatus.loaded,
            groupedSubjects: bookCategories,
          ),
        );
      },
    );
  }
}
