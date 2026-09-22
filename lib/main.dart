import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_flutter_template/app.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/services/geolocator_service.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injector_container.dart' as di;
import 'injector_container.dart';

void main() async {
  WidgetsBinding widgetsFlutterBinding =
      WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsFlutterBinding);
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  await Hive.initFlutter();
  // Hive.registerAdapter(ItemModelAdapter());
  await di.init();
  // await sl<GeoLocatorService>().init();
  // FlutterNativeSplash.remove();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    DevicePreview(
      builder: (context) => const MyApp(),
      enabled: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: MediaQuery.of(context).platformBrightness,
      ),
    );
    return BlocProvider(
      create: (context) => AppBloc(
          // sl<InternetConnectionCheckerPlus>()
      )
        ..add(const AppNetworkStatusCheck())
        ..add(const AppUserProfileCheckEvent()),
      child: const App(),
    );
  }
}
