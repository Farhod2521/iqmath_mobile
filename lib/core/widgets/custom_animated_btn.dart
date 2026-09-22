import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isAnimated;
  final bool isHorizontal;

  const CustomAnimatedButton(
      {Key? key,
      required this.child,
      this.onTap,
      this.isHorizontal = false,
      this.isAnimated = true})
      : super(key: key);

  @override
  State<CustomAnimatedButton> createState() => _CustomAnimatedButtonState();
}

class _CustomAnimatedButtonState extends State<CustomAnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    animation = Tween<double>(begin: 1, end: 0.95).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (widget.isAnimated) {
          controller.forward();
        }
      },
      onPanCancel: () {
        if (widget.isAnimated) {
          controller.reverse();
        }
      },
      onHorizontalDragCancel: widget.isHorizontal
          ? null
          : () {
              if (widget.isAnimated) {
                controller.reverse();
              }
            },
      onTapUp: (details) {
        if (widget.isAnimated) {
          controller.reverse();
        }
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTap: widget.onTap != null
          ? () {
              HapticFeedback.lightImpact();
            }
          : null,
      child: ScaleTransition(
        scale: animation,
        child: widget.child,
      ),
    );
  }
}
