import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_template/core/theme/app_theme.dart';

import '../../constants/constants.dart';
import '../../injector_container.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  // final InternetConnectionCheckerPlus internetConnectionCheckerPlus;
  AppBloc(// this.internetConnectionCheckerPlus
      )
      : super(
          AppState(
            lightTheme: lightThemes.values.first,
            darkTheme: darkThemes.values.first,
            themeMode: ThemeMode.light,
            appLocale: _detectInitialLocale(),
          ),
        ) {
    on<AppThemeSwitchLight>(_switchToLightHandler);
    on<AppThemeSwitchDark>(_switchToDarkHandler);
    on<AppChangeLocale>(_changeLocale);
    on<AppNetworkStatusCheck>(_networkStatusCheckHandler);
    on<AppUserProfileCheckEvent>(_checkProfileHandler);
    on<AppCheckAppVersionEvent>(_checkAppVersionHandler);
  }

  // --- Locale detection helper ---
  static String _detectInitialLocale() {
    final localSource = sl<LocalSource>();
    final saved = localSource.getLocale();
    if (saved != null) return saved;
    final deviceLang = PlatformDispatcher.instance.locale.languageCode;
    const supported = ['uz', 'ru'];
    return supported.contains(deviceLang) ? deviceLang : 'uz';
  }

  void _changeLocale(AppChangeLocale event, Emitter<AppState> emit) {
    sl<LocalSource>().setLocale(event.appLocale);
    emit(
      state.copyWith(
        appLocale: event.appLocale,
      ),
    );
  }

  void _switchToLightHandler(
      AppThemeSwitchLight event, Emitter<AppState> emit) {
    emit(
      state.copyWith(
        lightTheme: event.lightTheme,
        themeMode: ThemeMode.light,
      ),
    );
  }

  void _switchToDarkHandler(AppThemeSwitchDark event, Emitter<AppState> emit) {
    emit(
      state.copyWith(
        darkTheme: event.darkTheme,
        themeMode: ThemeMode.dark,
      ),
    );
  }

  FutureOr<void> _networkStatusCheckHandler(
    AppNetworkStatusCheck event,
    Emitter<AppState> emit,
  ) async {
    // await emit.forEach(
    //   internetConnectionCheckerPlus.onStatusChange,
    //   onData: (status) {
    //     return state.copyWith(
    //       isOnline: status == InternetConnectionStatus.connected,
    //     );
    //   },
    // );
  }

  FutureOr<void> _checkProfileHandler(
      AppUserProfileCheckEvent event, Emitter<AppState> emit) async {
    final localSource = sl<LocalSource>();
    emit(
      state.copyWith(
        isGuest: localSource.getAccessToken()?.isEmpty ?? true,
      ),
    );
    await emit.forEach(localSource.box.watch(key: AppKeys.ACCESSTOKEN),
        onData: (data) {
      bool isGuest = data.value?.isEmpty ?? true;
      return state.copyWith(
        isGuest: isGuest,
      );
    });
  }

  void _checkAppVersionHandler(
      AppCheckAppVersionEvent event, Emitter<AppState> emit) {
    final localSource = sl<LocalSource>();
    emit.forEach(
      localSource.box.watch(key: AppKeys.FORCEUPDATE),
      onData: (forceUpdate) {
        return state.copyWith(
          isForceUpdate: forceUpdate.value ?? false,
        );
      },
    );
  }
}
