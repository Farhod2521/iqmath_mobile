import 'dart:async';

import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_bloc/app_bloc.dart';

class NoConnectionSnackbar extends StatefulWidget {
  const NoConnectionSnackbar({
    super.key,
  });

  @override
  State<NoConnectionSnackbar> createState() => _NoConnectionSnackbarState();
}

class _NoConnectionSnackbarState extends State<NoConnectionSnackbar> {
  var show = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<AppBloc, AppState>(
      listenWhen: (previous, current) => previous.isOnline != current.isOnline,
      listener: (context, state) {
        if (state.isOnline) {
          setState(() {
            show = true;
          });
          Timer(const Duration(seconds: 2), () {
            setState(() {
              show = false;
            });
          });
        } else {
          setState(() {
            show = true;
          });
        }
      },
      builder: (context, state) => Material(
        child: TweenAnimationBuilder(
            tween: Tween<double>(begin: show ? 0 : 1, end: show ? 1 : 0),
            duration: const Duration(milliseconds: 500),
            builder: (context, animation, child) {
              return AnimatedContainer(
                color: state.isOnline
                    ? context.color.accentColor
                    : context.color.blackWhiteColor,
                duration: const Duration(milliseconds: 500),
                alignment: Alignment.center,
                child: SizedBox(
                  height: (size.height > 700 ? 50 : 30) * animation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.isOnline ? "Connected" : "No connection",
                      style: context.textStyle.fontSize14FontWeight500.copyWith(
                        color: context.color.bg1,
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
