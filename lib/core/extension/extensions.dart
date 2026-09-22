import 'package:my_flutter_template/router/app_routes.dart';
import 'package:flutter/widgets.dart';

extension ResponsiveX on num {
  double get width =>
      MediaQuery.of(rootNavigatorKey.currentContext!).size.width / 375 * this;

  double get height =>
      MediaQuery.of(rootNavigatorKey.currentContext!).size.height / 812 * this;
}
