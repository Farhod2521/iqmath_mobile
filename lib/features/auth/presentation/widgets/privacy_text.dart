import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_bloc/app_bloc.dart';

class PrivacyText extends StatelessWidget {
  const PrivacyText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) => switch (state.appLocale) {
        'ru' => Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                    text: 'Регистрируясь в Kesh, вы соглашаетесь с '),
                TextSpan(
                  text: 'Условиями использования сервиса ',
                  style: context.textStyle.fontSize14FontWeight500.copyWith(
                    color: context.color.primaryColor1,
                  ),
                ),
                const TextSpan(text: 'и принимаете нашу '),
                TextSpan(
                  text: 'Политику конфиденциальности ',
                  style: context.textStyle.fontSize14FontWeight500.copyWith(
                    color: context.color.primaryColor1,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
              style: context.textStyle.fontSize14FontWeight400,
            ),
            textAlign: TextAlign.center,
          ),
        'uz' => Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: "Keshda ro'yxatdan o'tish orqali siz "),
                TextSpan(
                  text: "Xizmat shartlariga ",
                  style: context.textStyle.fontSize14FontWeight500.copyWith(
                    color: context.color.primaryColor1,
                  ),
                ),
                const TextSpan(text: 'rozilik bildirasiz va '),
                TextSpan(
                  text: 'Maxfiylik siyosatimizni ',
                  style: context.textStyle.fontSize14FontWeight500.copyWith(
                    color: context.color.primaryColor1,
                  ),
                ),
                const TextSpan(text: 'qabul qilasiz.'),
              ],
              style: context.textStyle.fontSize14FontWeight400,
            ),
            textAlign: TextAlign.center,
          ),
        _ => Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                    text: 'Регистрируясь в Kesh, вы соглашаетесь с '),
                TextSpan(
                  text: 'Условиями использования сервиса ',
                  style: context.textStyle.fontSize14FontWeight500.copyWith(
                    color: context.color.primaryColor1,
                  ),
                ),
                const TextSpan(text: 'и принимаете нашу '),
                TextSpan(
                  text: 'Политику конфиденциальности ',
                  style: context.textStyle.fontSize14FontWeight500.copyWith(
                    color: context.color.primaryColor1,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
              style: context.textStyle.fontSize14FontWeight400,
            ),
            textAlign: TextAlign.center,
          ),
      },
    );
  }
}
