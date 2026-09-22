import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/widgets/force_update_dialog.dart';
import 'package:my_flutter_template/features/soon/presentation/soon_page.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/widgets/no_connection_snackbar.dart';
import 'generated/l10n.dart';
import 'injector_container.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      sl<LocalSource>().setAppVersion(packageInfo.version);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state.isForceUpdate) {
          showDialog(
            context: context,
            barrierDismissible: false,
            useSafeArea: true,
            builder: (_) => const ForceUpdateDialog(),
          );
        }
      },
      child: BlocBuilder<AppBloc, AppState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode ||
            previous.lightTheme != current.lightTheme ||
            previous.darkTheme != current.darkTheme ||
            previous.appLocale != current.appLocale,
        builder: (context, state) {
          return KeyboardDismisser(
            gestures: const [
              GestureType.onTap,
            ],
            child: MaterialApp(
              title: 'my_flutter_template',
              debugShowCheckedModeBanner: false,
              navigatorKey: rootNavigatorKey,
              themeMode: state.themeMode,
              theme: state.lightTheme,
              darkTheme: state.darkTheme,
              onUnknownRoute: (settings) => PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: const SoonPage(),
                ),
              ),
              builder: (context, child) {
                DevicePreview.appBuilder(context, child);
                return Column(
                  children: [
                    Expanded(child: child!),
                    const NoConnectionSnackbar(),
                  ],
                );
              },
              onGenerateRoute: AppRoutes.onGenerateRoute,
              themeAnimationCurve: Curves.slowMiddle,
              locale: state.appLocale == null
                  ? const Locale.fromSubtags(languageCode: 'ru')
                  : Locale.fromSubtags(
                      languageCode: state.appLocale!,
                    ),
              initialRoute: sl<LocalSource>().getAccessToken() != null
                  ? Routes.screenLockClone
                  // : Routes.onBoarding,
                  : Routes.auth,
              supportedLocales: AppLocalization.delegate.supportedLocales,
              localizationsDelegates: const [
                AppLocalization.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            ),
          );
        },
      ),
    );
  }
}
