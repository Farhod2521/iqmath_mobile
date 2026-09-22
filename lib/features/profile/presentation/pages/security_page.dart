import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/widgets/custom_animation_effects.dart';
import 'package:my_flutter_template/core/widgets/custom_exit_dialog.dart';
import 'package:my_flutter_template/core/widgets/custom_loading_indicator.dart';
import 'package:my_flutter_template/features/profile/presentation/widgets/version_widget.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/page_args/screen_lock_args.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../core/widgets/appbar_leading_widget.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../../../screen_lock/presentation/blocs/screen_lock_bloc.dart';
import '../blocs/security/security_bloc.dart';
import '../widgets/security_switch.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return BlocConsumer<SecurityBloc, SecurityState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          sl<LocalSource>().clear();
          Navigator.pop(
            context,
            true,
          );
        }
      },
      builder: (context, state) => Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(
                localization.security,
                // 'Xavfsizlik',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              leading: SizedBox.shrink(),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      localization.change_password,
                      // 'Parolni o\'zgartirish',
                      style: context.textStyle.fontSize16FontWeight700.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // subtitle: Text(
                    //   // localization.pin_code_for_authorization,
                    //   'Avtorizatsiya uchun PIN kodni tering',
                    //   style: context.textStyle.fontSize12FontWeight400.copyWith(
                    //     color: context.color.blackWhiteColor.withOpacity(0.5),
                    //   ),
                    // ),
                    trailing: SizedBox(
                      height: 16,
                      width: 16,
                      child: SvgPicture.asset(
                        Assets.svgAngelRight,
                        color: context.color.blackWhiteColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.changePassword,
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      localization.change_pin_code,
                      // 'PIN kodni o’zgartirish',
                      style: context.textStyle.fontSize16FontWeight700.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // subtitle: Text(
                    //   // localization.pin_code_for_authorization,
                    //   'Avtorizatsiya uchun PIN kodni tering',
                    //   style: context.textStyle.fontSize12FontWeight400.copyWith(
                    //     color: context.color.blackWhiteColor.withOpacity(0.5),
                    //   ),
                    // ),
                    trailing: SizedBox(
                      height: 16,
                      width: 16,
                      child: SvgPicture.asset(
                        Assets.svgAngelRight,
                        color: context.color.blackWhiteColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.screenLockClone,
                        arguments: ScreenLockPageArgs(
                          status: ScreenLockStatus.update,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      localization.face_id_or_touch_id,
                      // 'Face ID yoki Touch ID',
                      style: context.textStyle.fontSize16FontWeight700.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      localization.for_automatic_enter,
                      // 'Avtomatik tarzda kirish uchun',
                      style: context.textStyle.fontSize12FontWeight400.copyWith(
                        color: context.color.blackWhiteColor.withOpacity(0.5),
                      ),
                    ),
                    trailing: const SecuritySwitch(),
                  ),
                  // const Expanded(
                  //   child: Align(
                  //     alignment: Alignment(0, 0.9),
                  //     child: VersionWidget(),
                  //   ),
                  // ),
                ].animate(
                  effects: slideAndFadeEffect,
                ),
              ),
            ),
          ),
          if (state.status.isLoading)
            const Positioned.fill(
              child: Center(
                child: CustomLoadingIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
