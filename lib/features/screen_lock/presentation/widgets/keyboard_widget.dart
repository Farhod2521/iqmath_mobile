import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/screen_lock_bloc.dart';
import 'button_item.dart';

class KeyboardWidget extends StatelessWidget {
  final ScreenLockStatus status;

  const KeyboardWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonItem(number: 1, status: status),
              ButtonItem(number: 2, status: status),
              ButtonItem(number: 3, status: status),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonItem(number: 4, status: status),
              ButtonItem(number: 5, status: status),
              ButtonItem(number: 6, status: status),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonItem(number: 7, status: status),
              ButtonItem(number: 8, status: status),
              ButtonItem(number: 9, status: status),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bo'sh joy
              const SizedBox(width: 72),
              ButtonItem(number: 0, status: status),
              ButtonItem(
                icon: Assets.svgArrowLeft,
                onTap: () {
                  context.read<ScreenLockBloc>().add(
                        ScreenLockArrowBackTapped(status),
                      );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
