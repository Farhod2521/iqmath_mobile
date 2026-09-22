import 'package:flutter/material.dart';

class ThemeGradients extends ThemeExtension<ThemeGradients> {
  final LinearGradient errorFlushBarGradient;
  final LinearGradient floatingActionButtonGradient;
  final LinearGradient sliverAppBarGradient;

  const ThemeGradients({
    required this.errorFlushBarGradient,
    required this.floatingActionButtonGradient,
    required this.sliverAppBarGradient,
  });

  static final light = ThemeGradients(
    errorFlushBarGradient: const LinearGradient(
      colors: [
        Color(0xFFFF0808),
        Color(0xFFFF3D3D),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    floatingActionButtonGradient: const LinearGradient(
      colors: [
        Color(0xFFD95C35),
        Color(0xFFE17F60),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    sliverAppBarGradient: LinearGradient(
      colors: [
        const Color(0xFF000000),
        const Color(0xFF000000).withOpacity(0.5),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
  );
  static final dark = ThemeGradients(
    errorFlushBarGradient: const LinearGradient(
      colors: [
        Color(0xFFFF0808),
        Color(0xFFFF3D3D),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    floatingActionButtonGradient: const LinearGradient(
      colors: [
        Color(0xFFD95C35),
        Color(0xFFE17F60),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    sliverAppBarGradient: LinearGradient(
      colors: [
        const Color(0xFF000000),
        const Color(0xFF000000).withOpacity(0.5),
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
  );

  @override
  ThemeExtension<ThemeGradients> copyWith({
    LinearGradient? errorFlushBarGradient,
    LinearGradient? floatingActionButtonGradient,
    LinearGradient? sliverAppBarGradient,
  }) {
    return ThemeGradients(
      errorFlushBarGradient:
          errorFlushBarGradient ?? this.errorFlushBarGradient,
      floatingActionButtonGradient:
          floatingActionButtonGradient ?? this.floatingActionButtonGradient,
      sliverAppBarGradient: sliverAppBarGradient ?? this.sliverAppBarGradient,
    );
  }

  @override
  ThemeExtension<ThemeGradients> lerp(
      ThemeExtension<ThemeGradients>? other, double t) {
    if (other is! ThemeGradients) {
      return this;
    }
    return ThemeGradients(
      errorFlushBarGradient: LinearGradient.lerp(
        errorFlushBarGradient,
        other.errorFlushBarGradient,
        t,
      )!,
      floatingActionButtonGradient: LinearGradient.lerp(
        floatingActionButtonGradient,
        other.floatingActionButtonGradient,
        t,
      )!,
      sliverAppBarGradient: LinearGradient.lerp(
        sliverAppBarGradient,
        other.sliverAppBarGradient,
        t,
      )!,
    );
  }
}

extension BuildContextZ on BuildContext {
  ThemeGradients get gradients => Theme.of(this).extension<ThemeGradients>()!;
}
