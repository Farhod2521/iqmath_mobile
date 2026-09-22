import 'package:my_flutter_template/features/screen_lock/presentation/mixins/screen_lock_mixin.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/widgets/check_screen_lock.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/widgets/update_screen_lock.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/widgets/screen_lock_upper_layout.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../blocs/screen_lock_bloc.dart';
import 'create_screen_lock.dart';

class UpperTextWidget extends StatelessWidget {
  final ScreenLockStatus status;

  const UpperTextWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ScreenLockStatus.create => CreateScreenLock(),
      ScreenLockStatus.check => CheckScreenLock(),
      ScreenLockStatus.update => UpdateScreenLock(),
    };
  }
}
