import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/l10n.dart';

class NotificationBtmSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final DateTime? dateTime;
  final String? imageUrl;
  final String? videoUrl;

  const NotificationBtmSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.dateTime,
    this.imageUrl,
    this.videoUrl,
  });

  @override
  State<NotificationBtmSheet> createState() => _NotificationBtmSheetState();
}

class _NotificationBtmSheetState extends State<NotificationBtmSheet> {
  YoutubePlayerController? _youtubeController;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    // Portrait rejimini majburiy qilish
    _setPortraitOrientation();

    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initializeYoutubePlayer();
    }
  }

  void _setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _initializeYoutubePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl!);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          hideThumbnail: false,
          showLiveFullscreenButton: false, // Fullscreen ni o'chiramiz
          forceHD: false,
          loop: false,
          isLive: false,
        ),
      )..addListener(_youtubeListener);
    }
  }

  void _youtubeListener() {
    if (_youtubeController != null && mounted) {
      if (_youtubeController!.value.isReady && !_isPlayerReady) {
        setState(() {
          _isPlayerReady = true;
        });
      }

      // Fullscreen holatini kuzatish
      if (_youtubeController!.value.isFullScreen) {
        // Agar fullscreen bo'lsa, landscape rejimiga ruxsat berish
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        // Fullscreen dan chiqqanda portrait rejimiga qaytarish
        _setPortraitOrientation();
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      }
    }
  }

  @override
  void dispose() {
    // Orientation ni tiklash
    _resetOrientation();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // Controller ni to'xtatish va dispose qilish
    _youtubeController?.removeListener(_youtubeListener);
    _youtubeController?.pause();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final hasVideo = widget.videoUrl != null && widget.videoUrl!.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        // Orqaga qaytishda orientation ni tiklash
        _resetOrientation();
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.color.bg1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.color.mainText5.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video section (YouTube Player)
                    if (hasVideo && _youtubeController != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: context.color.primaryColor1,
                          progressColors: ProgressBarColors(
                            playedColor: context.color.primaryColor1,
                            handleColor: context.color.primaryColor1,
                            bufferedColor: context.color.primaryColor1.withOpacity(0.3),
                            backgroundColor: context.color.mainText5.withOpacity(0.2),
                          ),
                          topActions: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _youtubeController!.metadata.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                          bottomActions: [
                            CurrentPosition(),
                            const SizedBox(width: 10),
                            ProgressBar(
                              isExpanded: true,
                              colors: ProgressBarColors(
                                playedColor: context.color.primaryColor1,
                                handleColor: context.color.primaryColor1,
                                bufferedColor: context.color.primaryColor1.withOpacity(0.3),
                                backgroundColor: context.color.mainText5.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            RemainingDuration(),
                            const SizedBox(width: 8),
                            FullScreenButton(),
                          ],
                          onReady: () {
                            print('YouTube player is ready');
                          },
                          onEnded: (data) {
                            print('Video ended');
                            // Video tugaganda portrait rejimiga qaytarish
                            _setPortraitOrientation();
                          },
                        ),
                      ),
                      const Gap(16),
                    ],

                    // Image section (only if no video)
                    if (hasImage && !hasVideo) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
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
                            height: 200,
                            color: context.color.mainText5.withOpacity(0.05),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: context.color.mainText5.withOpacity(0.3),
                                ),
                                const Gap(12),
                                Text(
                                  localization.non_upload_image,
                                  style: context.textStyle.fontSize14FontWeight400.copyWith(
                                    color: context.color.mainText5.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                    ],

                    // Title
                    Text(
                      widget.title,
                      style: context.textStyle.fontSize18FontWeight700,
                    ),
                    const Gap(16),

                    // Date and time
                    if (widget.dateTime != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: context.color.mainText5,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd.MM.yyyy').format(widget.dateTime!),
                            style: context.textStyle.fontSize14FontWeight400.copyWith(
                              color: context.color.mainText5,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: context.color.mainText5,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(widget.dateTime!),
                            style: context.textStyle.fontSize14FontWeight400.copyWith(
                              color: context.color.mainText5,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                    ],

                    // Content/Subtitle
                    Text(
                      widget.subtitle,
                      style: context.textStyle.fontSize16FontWeight400.copyWith(
                        color: context.color.mainText5,
                        height: 1.5,
                      ),
                    ),
                    const Gap(24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}