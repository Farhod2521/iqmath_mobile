import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_flutter_template/core/extension/extensions.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/main/presentation/bloc/main_bloc.dart';
import 'package:my_flutter_template/features/main/presentation/pages/main_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';

class CustomBottomAppBar extends StatefulWidget {
  final List<Destination> destinations;
  final List<GlobalKey<NavigatorState>> destinationKeys;

  const CustomBottomAppBar({
    required this.destinations,
    required this.destinationKeys,
    super.key,
  });

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  DateTime? now;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    double bottomAppBarHeight = 68.0.width;

    // MediaQuery orqali viewInsets va padding ni olamiz
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // iOS uchun padding yo'q, Android uchun faqat navigatsiya tugmalari bo'lsa padding bor
    final bool isIOS = Platform.isIOS;
    final additionalPadding = isIOS ? 0.0 : bottomPadding;

    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return Container(
          height: bottomAppBarHeight + additionalPadding,
          color: Colors.white,
          padding: EdgeInsets.only(bottom: additionalPadding),
          child: Container(
            height: bottomAppBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BottomAppItem(
                    svgAsset: widget.destinations.first.icon,
                    title: widget.destinations.first.title,
                    isSelected: state.currentPage.isHome,
                    itemIndex: 0,
                    onLongPress: () {
                      if (kDebugMode) {
                        alice.showInspector();
                      }
                    },
                    onTap: () {
                      if (state.currentPage.isHome) {
                        widget.destinationKeys.first.currentState
                            ?.popUntil((route) => route.isFirst);
                      }
                      context.read<MainBloc>().add(
                        const MainPageChangeEvent(
                          MainPages.home,
                        ),
                      );
                    },
                  ),
                  BottomAppItem(
                    svgAsset: widget.destinations[1].icon,
                    title: widget.destinations[1].title,
                    isSelected: state.currentPage.isSubject,
                    itemIndex: 1,
                    onTap: () {
                      if (state.currentPage.isSubject) {
                        widget.destinationKeys[1].currentState
                            ?.popUntil((route) => route.isFirst);
                      }
                      context.read<MainBloc>().add(
                        const MainPageChangeEvent(
                          MainPages.subjects,
                        ),
                      );
                    },
                  ),
                  BottomAppItem(
                    svgAsset: widget.destinations[2].icon,
                    title: widget.destinations[2].title,
                    isSelected: state.currentPage.isDiagnostics,
                    itemIndex: 2,
                    onTap: () {
                      if (state.currentPage.isDiagnostics) {
                        widget.destinationKeys[2].currentState
                            ?.popUntil((route) => route.isFirst);
                      }
                      context.read<MainBloc>().add(
                        const MainPageChangeEvent(
                          MainPages.diagnostics,
                        ),
                      );
                    },
                  ),
                  BottomAppItem(
                    svgAsset: widget.destinations[3].icon,
                    title: widget.destinations[3].title,
                    isSelected: state.currentPage.isProducts,
                    itemIndex: 3,
                    onTap: () {
                      if (state.currentPage.isProducts) {
                        widget.destinationKeys[3].currentState
                            ?.popUntil((route) => route.isFirst);
                      }
                      widget.destinationKeys[3].currentState
                          ?.popUntil((route) => route.isFirst);
                      context.read<MainBloc>().add(
                        const MainPageChangeEvent(
                          MainPages.products,
                        ),
                      );
                    },
                  ),
                  // Profil endi bottom-navbar tabi emas — logotibga bosilganda
                  // chap tomondan slayd bo'lib ochiladigan drawer sifatida
                  // ochiladi (qarang: HomePage._openProfile).
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class BottomAppItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? svgAsset;
  final IconData? iconData;
  final double iconSize;
  final int itemIndex;

  const BottomAppItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.itemIndex,
    this.onLongPress,
    this.svgAsset,
    this.iconData,
    this.iconSize = 32,
  }) : assert(svgAsset != null || iconData != null, 'Icon is required');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color selectedColor = context.color.primaryColor1;
    final Color unselectedColor =
        theme.iconTheme.color?.withOpacity(0.5) ?? Colors.grey;

    return Expanded(
      child: Semantics(
        selected: isSelected,
        label: title,
        button: true,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          onLongPress: () {
            HapticFeedback.vibrate();
            onLongPress?.call();
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: isSelected
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: svgAsset != null
                    ? SvgPicture.asset(
                  svgAsset!,
                  height: iconSize,
                  width: iconSize,
                  colorFilter: ColorFilter.mode(
                    selectedColor,
                    BlendMode.srcIn,
                  ),
                )
                    : Icon(
                  iconData,
                  size: iconSize,
                  color: selectedColor,
                ),
                secondChild: svgAsset != null
                    ? SvgPicture.asset(
                  svgAsset!,
                  height: iconSize,
                  width: iconSize,
                  colorFilter: ColorFilter.mode(
                    unselectedColor,
                    BlendMode.srcIn,
                  ),
                )
                    : Icon(
                  iconData,
                  size: iconSize,
                  color: unselectedColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class GlassBottomBarBackground extends StatelessWidget {
//   final Widget child;
//
//   const GlassBottomBarBackground({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color.fromRGBO(255, 255, 255, 0.2),
//                 Color.fromRGBO(255, 255, 255, 0.0),
//               ],
//             ),
//             border: const Border(
//               top: BorderSide(
//                 width: 1,
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 height: 1,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color.fromRGBO(255, 255, 255, 0.5),
//                         Color.fromRGBO(255, 255, 255, 0.0),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               child,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }