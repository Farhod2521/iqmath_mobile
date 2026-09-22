import 'dart:math';

import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/core/widgets/custom_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../generated/assets.dart';

class ProfileHeaderItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String phoneNumber;
  final VoidCallback onTap;

  const ProfileHeaderItem(
      {Key? key,
      required this.imageUrl,
      required this.name,
      required this.phoneNumber,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppUtils.kBorderRadius12,
        onTap: onTap,
        child: Ink(
          height: 48,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppUtils.kBorderRadius10,
                child: Container(
                  color: context.color.homeButtonsColor,
                  height: 48,
                  width: 48,
                  child: Image.network(imageUrl, fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const Center(
                            child: CustomLoadingIndicator(),
                          );
                  }, errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: Image.asset(
                          Assets.pngUser,
                          color: context.color.primaryColor1,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: context.textStyle.fontSize16FontWeight700,
                          ),
                          Text(
                            phoneNumber,
                            style: context.textStyle.fontSize12FontWeight400
                                .copyWith(
                              color: context.color.blackWhiteColor.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox.square(
                      dimension: 16,
                      child: SvgPicture.asset(
                        Assets.svgAngelRight,
                        color: context.color.blackWhiteColor,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
