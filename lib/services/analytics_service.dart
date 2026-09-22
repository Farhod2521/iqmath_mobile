import 'dart:async';

// import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:my_flutter_template/constants/constants.dart';
import 'package:my_flutter_template/services/service.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

class AnalyticsService implements Service {
  @override
  FutureOr<void> dispose() {}

  @override
  FutureOr<void> init() async {
    // await AppMetrica.activate(
    //   const AppMetricaConfig(
    //     Constants.appMetricaKey,
    //     logs: true,
    //   ),
    // );
  }

  Future<void> logEvents(String eventName,
      {required Map<String, Object> parameters}) async {
    // await AppMetrica.reportEventWithMap(
    //   eventName,
    //   parameters,
    // );
    // await FirebaseAnalytics.instance.logEvent(
    //   name: eventName,
    //   parameters: parameters,
    // );
  }
}
