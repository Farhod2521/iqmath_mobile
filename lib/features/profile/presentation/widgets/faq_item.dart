import 'dart:math';

import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const FaqItem({super.key, required this.question, required this.answer});

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: pi, end: pi / 2)
        .animate(_animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        widget.question,
        style: context.textStyle.fontSize16FontWeight700,
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      trailing: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value,
            child: SizedBox(
              height: 18,
              width: 18,
              child: SvgPicture.asset(
                Assets.svgAngelLeft,
                color: context.color.blackWhiteColor,
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      onExpansionChanged: (value) {
        if (value) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        side: BorderSide(
          color: Colors.transparent,
        ),
      ),
      expandedAlignment: Alignment.topLeft,
      children: [
        Text(
          widget.answer,
          style: context.textStyle.fontSize16FontWeight400.copyWith(
            color: context.color.blackWhiteColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
