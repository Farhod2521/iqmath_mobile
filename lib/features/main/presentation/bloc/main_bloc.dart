import 'dart:async';

import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/features/main/domain/entities/user_response_entity.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../injector_container.dart';
import '../../../../services/geolocator_service.dart';
import '../../domain/usecases/get_user_info_usecase.dart';

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> with BaseBlocMixin {
  final GetUserInfoUseCase getUserInfoUseCase;

  MainBloc(this.getUserInfoUseCase) : super(const MainState()) {
    on<MainInitialEvent>(_initializeHandler);
    on<MainPageChangeEvent>(_onMainPageChangeHandler);
    on<MainSearchRoutesObserverEvent>(_searchRoutesObserverHandler);
  }

  FutureOr<void> _onMainPageChangeHandler(
      MainPageChangeEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(currentPage: event.page));
  }

  FutureOr<void> _initializeHandler(
      MainInitialEvent event, Emitter<MainState> emit) async {
    final localSource = sl<LocalSource>();
    emit(state.copyWith(status: MainStatus.loading));
    final response = await getUserInfoUseCase(
      NoParams(),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: getErrorMessage(failure),
          status: MainStatus.error,
        ),
      ),
      (success) {
        localSource.setFirstName(success.fullName ?? '');
        localSource.setReferralCode(success.identification ?? '');
        localSource.setUserId(success.identification.toString());
        localSource.setUserProfileID(success.id.toString());
        // localSource.setPhoneNumber(success.phone?.replaceAll('998', '') ?? '');
        localSource.setUserAddress(success.address ?? '');
        emit(
          state.copyWith(
            status: MainStatus.success,
            userInfo: success,
          ),
        );
      },
    );
  }

  FutureOr<void> _searchRoutesObserverHandler(
    MainSearchRoutesObserverEvent event,
    Emitter<MainState> emit,
  ) {
    emit(
      state.copyWith(searchRoutes: event.route),
    );
  }
}
