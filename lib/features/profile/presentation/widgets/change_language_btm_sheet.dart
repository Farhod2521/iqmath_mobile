import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/app_bloc/app_bloc.dart';

class ChangeLanguageBtmSheet extends StatelessWidget {
  const ChangeLanguageBtmSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.color.bg1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization.change_language,
                style: context.textStyle.fontSize18FontWeight700,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: SvgPicture.asset(
                    Assets.svgCrossSmall,
                    color: context.color.blackWhiteColor,
                  ),
                ),
              )
            ],
          ),
          const Gap(20),
          const Divider(),
          const Gap(20),
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              return LanguageItem(
                title: "Русский язык",
                imageUrl: Assets.pngRussia,
                isSelected: state.appLocale == 'ru',
                onTap: () {
                  context.read<AppBloc>().add(const AppChangeLocale('ru'));
                },
              );
            },
          ),
          const Gap(20),
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              return LanguageItem(
                title: "O’zbek tili",
                imageUrl: Assets.pngUzbek,
                isSelected: state.appLocale == 'uz',
                onTap: () {
                  context.read<AppBloc>().add(const AppChangeLocale('uz'));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class LanguageItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageItem(
      {super.key,
      required this.title,
      required this.imageUrl,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? context.color.primaryColor1
                : context.color.blackWhiteColor.withOpacity(0.5),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: SizedBox(
            height: 24,
            width: 24,
            child: Image.asset(
              imageUrl,
            ),
          ),
          title: Text(
            title,
            style: context.textStyle.fontSize14FontWeight700.copyWith(
              color: isSelected
                  ? context.color.primaryColor1
                  : context.color.blackWhiteColor,
            ),
          ),
          trailing: isSelected
              ? Container(
                  height: 24,
                  width: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.color.primaryColor2,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 18,
                    color: context.color.white,
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
