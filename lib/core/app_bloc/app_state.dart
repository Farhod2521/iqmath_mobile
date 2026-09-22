part of 'app_bloc.dart';

class AppState extends Equatable {
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final String? appLocale;
  final bool isOnline;
  final bool isGuest;
  final bool isForceUpdate;

  const AppState({
    this.appLocale,
    this.lightTheme,
    this.darkTheme,
    this.themeMode,
    this.isOnline = false,
    this.isGuest = true,
    this.isForceUpdate = false,
  });

  AppState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ThemeMode? themeMode,
    String? appLocale,
    bool? isOnline,
    bool? isGuest,
    bool? isForceUpdate,
  }) {
    return AppState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
      appLocale: appLocale ?? this.appLocale,
      isOnline: isOnline ?? this.isOnline,
      isGuest: isGuest ?? this.isGuest,
      isForceUpdate: isForceUpdate ?? this.isForceUpdate,
    );
  }

  @override
  List<Object?> get props => [
        lightTheme,
        darkTheme,
        themeMode,
        appLocale,
        isOnline,
        isGuest,
        isForceUpdate,
      ];
}
