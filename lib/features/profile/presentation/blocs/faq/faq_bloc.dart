import 'dart:async';

import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/faq_response_entity.dart';
import '../../../domain/usecases/get_faq_usecase.dart';

part 'faq_event.dart';

part 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> with BaseBlocMixin {
  final GetFaqUseCase getFaqUseCase;

  FaqBloc(this.getFaqUseCase) : super(const FaqState()) {
    on<FaqEvent>(_initializeHandler);
  }

  FutureOr<void> _initializeHandler(
      FaqEvent event, Emitter<FaqState> emit) async {
    emit(state.copyWith(status: FaqStatus.loading));
    final response = await getFaqUseCase(NoParams());
    response.fold(
      (failure) => emit(
        state.copyWith(
          status: FaqStatus.error,
          errorMessage: getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          status: FaqStatus.success,
          faqs: success.faqs,
        ),
      ),
    );
  }
}
