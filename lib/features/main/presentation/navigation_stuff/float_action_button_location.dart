import 'package:my_flutter_template/core/extension/extensions.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:flutter/material.dart';

class CustomFloatActionButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final bottomAppBarHeight = 59.width;
    return Offset(
      scaffoldGeometry.scaffoldSize.width / 2 - bottomAppBarHeight / 2,
      scaffoldGeometry.scaffoldSize.height - bottomAppBarHeight - 42.width,
    );
  }
}
