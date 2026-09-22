import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

List<Effect> slideAndFadeEffect = [
  const SlideEffect(
    begin: Offset(0, 0.5),
    end: Offset.zero,
    curve: Curves.decelerate,
  ),
  const FadeEffect(
    curve: Curves.decelerate,
    duration: Duration(milliseconds: 750),
  ),
];

List<Effect> fadeEffect = [
  const FadeEffect(
    curve: Curves.decelerate,
    duration: Duration(milliseconds: 750),
  ),
];
