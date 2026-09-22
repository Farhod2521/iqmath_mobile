import 'dart:async';

abstract class Service {
  FutureOr<void> init();

  FutureOr<void> dispose();
}
