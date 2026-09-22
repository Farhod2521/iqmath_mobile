import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/subject/presentation/localization/subject_localization.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoDialog extends StatefulWidget {
  final String youtubeUrl;

  const YoutubeVideoDialog({super.key, required this.youtubeUrl});

  @override
  State<YoutubeVideoDialog> createState() => _YoutubeVideoDialogState();
}

class _YoutubeVideoDialogState extends State<YoutubeVideoDialog> {
  late YoutubePlayerController _controller;
  bool _isReady = false;
  bool _isFullScreen = false;
  late List<DeviceOrientation> _previousOrientations;

  @override
  void initState() {
    super.initState();

    // Hozirgi orientatsiyani saqlash
    _previousOrientations = [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ];

    // Barcha orientatsiyalarga ruxsat berish
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: false,
        hideControls: false,
        controlsVisibleAtStart: true,
      ),
    )..addListener(() {
      if (_controller.value.isReady && !_isReady) {
        setState(() => _isReady = true);
      }
      if (_controller.value.isFullScreen != _isFullScreen) {
        setState(() => _isFullScreen = _controller.value.isFullScreen);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations(_previousOrientations);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            color: Colors.black.withOpacity(0.85),
            child: WillPopScope(
              onWillPop: () async {
                // Agar fullscreen bo'lsa, avval fullscreen dan chiqish
                if (_isFullScreen) {
                  _controller.toggleFullScreenMode();
                  return false;
                }
                return true;
              },
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;
                  final screenSize = MediaQuery.of(context).size;
                  final padding = MediaQuery.of(context).padding;

                  // Dialog o'lchamlari - yonlariga tegib tursin
                  final horizontalMargin = 12.0;
                  final verticalMargin = isLandscape ? 12.0 : 40.0;

                  final width = screenSize.width - (horizontalMargin * 2);
                  final height = screenSize.height -
                      (verticalMargin * 2) -
                      padding.top -
                      padding.bottom;

                  return SafeArea(
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: horizontalMargin,
                          vertical: verticalMargin,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        width: width,
                        height: height,
                        child: YoutubePlayerBuilder(
                          player: YoutubePlayer(
                            controller: _controller,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: Colors.red,
                            progressColors: const ProgressBarColors(
                              playedColor: Colors.red,
                              handleColor: Colors.redAccent,
                            ),
                            onReady: () => setState(() => _isReady = true),
                            onEnded: (data) {
                              _controller.seekTo(const Duration(seconds: 0));
                              _controller.pause();
                            },
                            topActions: [
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _controller.metadata.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          onEnterFullScreen: () {
                            SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.immersiveSticky);
                          },
                          onExitFullScreen: () {
                            SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge);
                          },
                          builder: (context, player) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  // Video player
                                  Container(
                                    color: Colors.black,
                                    child: Center(child: player),
                                  ),
                                  if (!_isFullScreen)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            SystemChrome
                                                .setPreferredOrientations([
                                              DeviceOrientation.portraitUp,
                                              DeviceOrientation.portraitDown
                                            ]);
                                            Navigator.of(context).pop();
                                          },
                                          borderRadius:
                                          BorderRadius.circular(30),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.75),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.xmark,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Orientation hint
                                  if (!_isFullScreen && !_isReady)
                                    Positioned(
                                      bottom: 20,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          border: Border.all(
                                            color:
                                            Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CupertinoIcons.rotate_right,
                                              color: Colors.white
                                                  .withOpacity(0.9),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              YoutubeVideoTranslations.t(
                                                  'rotatePhone', locale),
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // Loading indicator
                                  if (!_isReady)
                                    Container(
                                      color: Colors.black,
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CupertinoActivityIndicator(
                                              color: Colors.white,
                                              radius: 22,
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              YoutubeVideoTranslations.t(
                                                  'videoLoading', locale),
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}