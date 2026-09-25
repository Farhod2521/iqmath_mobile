import 'package:flutter/services.dart';
import 'package:my_flutter_template/core/extension/extensions.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/main/presentation/bloc/main_bloc.dart';
import 'package:my_flutter_template/features/main/presentation/pages/main_page.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';

const String _navImgHome = 'assets/images/navbar1.png';
const String _navImgCourses = 'assets/images/navbar2.png';
const String _navImgDiagnostics = 'assets/images/navbar3.png';
const String _navImgBattle = 'assets/images/navbar4.png';

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
    double bottomAppBarHeight = 82.0.width;

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
                    imageAsset: _navImgHome,
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
                    imageAsset: _navImgCourses,
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
                    imageAsset: _navImgDiagnostics,
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
                    imageAsset: _navImgBattle,
                    title: widget.destinations[3].title,
                    isSelected: false,
                    itemIndex: 3,
                    onTap: () {
                      Navigator.pushNamed(
                        mainRootNavigatorKey.currentContext!,
                        Routes.battle,
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
  final String imageAsset;
  final double iconSize;
  final int itemIndex;

  const BottomAppItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.itemIndex,
    required this.imageAsset,
    this.onLongPress,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = context.color.primaryColor1;
    const Color unselectedTextColor = Color(0xFF8A8A8E);

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
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    imageAsset,
                    height: iconSize,
                    width: iconSize,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? selectedColor : unselectedTextColor,
                    ),
                  ),
                ],
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