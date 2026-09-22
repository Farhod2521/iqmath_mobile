import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:my_flutter_template/generated/l10n.dart';

import '../../../../../../generated/assets.dart';
import 'notification_btm_sheet.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? dateTime;
  final String? imageUrl;
  final String? videoUrl;

  const NotificationItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    this.imageUrl,
    this.videoUrl,
  });

  String? _getYoutubeThumbnail(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasVideo = videoUrl != null && videoUrl!.isNotEmpty;
    final videoThumbnail = hasVideo ? _getYoutubeThumbnail(videoUrl!) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: context.color.bg1,
            shape: const RoundedRectangleBorder(
              borderRadius: AppUtils.kBorderRadius20,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            builder: (context) => NotificationBtmSheet(
              title: title,
              subtitle: subtitle,
              dateTime: dateTime,
              imageUrl: imageUrl,
              videoUrl: videoUrl,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          decoration: ShapeDecoration(
            color: context.color.scaffoldBackGroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video or Image section
              if (hasVideo) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video thumbnail
                      videoThumbnail != null
                          ? CachedNetworkImage(
                        imageUrl: videoThumbnail,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 160,
                          color: context.color.mainText5.withOpacity(0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.color.primaryColor1,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 160,
                          color: context.color.mainText5.withOpacity(0.05),
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: context.color.mainText5.withOpacity(0.3),
                          ),
                        ),
                      )
                          : Container(
                        height: 160,
                        width: double.infinity,
                        color: context.color.mainText5.withOpacity(0.1),
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 60,
                          color: context.color.mainText5.withOpacity(0.3),
                        ),
                      ),
                      // Play button overlay
                      Container(
                        width: 72,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
              ] else if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160,
                      color: context.color.mainText5.withOpacity(0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.color.primaryColor1,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160,
                      color: context.color.mainText5.withOpacity(0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: context.color.mainText5.withOpacity(0.3),
                          ),
                          const Gap(8),
                          Text(
                            localization.non_upload_image,
                            style: context.textStyle.fontSize12FontWeight400.copyWith(
                              color: context.color.mainText5.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(12),
              ],

              // Title
              Text(
                title,
                style: context.textStyle.fontSize14FontWeight700,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(12),

              // Subtitle
              Text(
                subtitle,
                maxLines: hasImage || hasVideo ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: context.textStyle.fontSize16FontWeight400.copyWith(
                  color: context.color.mainText5,
                ),
              ),
              const Gap(12),

              // Footer with date and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: SvgPicture.asset(
                      Assets.svgIosDown,
                      fit: BoxFit.scaleDown,
                      color: context.color.blackWhiteColor,
                    ),
                  ),
                  const Spacer(),
                  if (dateTime != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: context.color.mainText5,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd.MM.yyyy').format(dateTime!),
                          style: context.textStyle.fontSize14FontWeight400.copyWith(
                            color: context.color.mainText5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_outlined,
                          size: 14,
                          color: context.color.mainText5,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('HH:mm').format(dateTime!),
                          style: context.textStyle.fontSize14FontWeight400.copyWith(
                            color: context.color.mainText5,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}