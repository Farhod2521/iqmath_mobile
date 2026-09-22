import 'dart:async';

import 'package:my_flutter_template/services/service.dart';

class SnackBarService extends Service {
  final bool isOpen;

  SnackBarService({required this.isOpen});

  @override
  FutureOr<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  FutureOr<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }
}
