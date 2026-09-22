import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/custom_cached_network_image.dart';

class SearchItem extends StatelessWidget with BaseBlocMixin {
  final List<String> imageUrl;
  final String? title;
  final String? address;
  final String? workingHours;
  final double rating;
  final EdgeInsets? margin;
  final VoidCallback onTap;
  final (double lat, double long) currentLocation;
  final (double lat, double long) restaurantLocation;

  const SearchItem(
      {Key? key,
      required this.imageUrl,
      required this.title,
      required this.address,
      required this.workingHours,
      required this.rating,
      this.margin,
      required this.currentLocation,
      required this.restaurantLocation,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: margin ?? const EdgeInsets.only(right: 20),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppUtils.kBorderRadius16,
          child: Ink(
            height: 90,
            decoration: BoxDecoration(
              color: context.color.bg1,
              borderRadius: AppUtils.kBorderRadius16,
              boxShadow: [
                BoxShadow(
                  color: context.color.blackWhiteColor.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CustomCachedNetworkImage(
                  imageUrl: imageUrl.isNotEmpty ? imageUrl.first : 'empty',
                  width: 73,
                  height: 90,
                  fit: BoxFit.cover,
                  withDecoration: false,
                  borderRadius: AppUtils.kBorderRadius8,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      bottom: 13,
                      top: 13,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title ?? 'empty',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    context.textStyle.fontSize16FontWeight700,
                              ),
                            ),
                            Container(
                              height: 22,
                              width: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.color.scaffoldBackGroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                rating.toStringAsFixed(1),
                                style: context.textStyle.fontSize8FontWeight700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          address ?? 'empty',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyle.fontSize12FontWeight400
                              .copyWith(
                            color:
                                context.color.blackWhiteColor.withOpacity(0.5),
                          ),
                        ),
                        if (workingHours != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${localization.work_until} ${workingHours!.substring(0, 5)}",
                                style: context.textStyle.fontSize12FontWeight400
                                    .copyWith(
                                  color: context.color.blackWhiteColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              Text(
                                "${haversineDistance(currentLocation.$1, currentLocation.$2, restaurantLocation.$1, restaurantLocation.$2).toStringAsFixed(1)} ${localization.km}",
                                style: context.textStyle.fontSize12FontWeight400
                                    .copyWith(
                                  color: context.color.blackWhiteColor
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
