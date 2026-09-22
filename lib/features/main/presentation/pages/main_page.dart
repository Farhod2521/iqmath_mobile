import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/main/presentation/pages/destination_page.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/profile_page.dart';
import 'package:my_flutter_template/features/main/presentation/widgets/quich_math_feature.dart';
import 'package:my_flutter_template/features/main/presentation/widgets/version_checker.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/services/refresh_token_service.dart';

import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';
import '../bloc/main_bloc.dart';
import '../widgets/custom_bottom_appbar.dart';

part '../navigation_stuff/destination_data.dart';

class MainPage extends StatefulWidget {
  final List<OnGenerateRoute> onGenerateRoutes;

  const MainPage({super.key, required this.onGenerateRoutes});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  List<GlobalObjectKey<NavigatorState>>? _destinationKeys;
  late final AnimationController _hide;
  late final PageController _pageController;
  List<Destination>? destinations;
  bool _isInitialized = false;
  final RefreshTokenService _refreshTokenService = RefreshTokenService(); // QOSHISH

  @override
  void initState() {
    super.initState();
    context.read<MainBloc>().add(const MainInitialEvent());

    _hide = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1.0,
    );

    _pageController = PageController();

    // Versiya tekshirish
    _checkAppVersion();

    // Token'ni yangilash (QOSHISH)
    // _refreshToken();
  }

  Future<void> _checkAppVersion() async {
    if (!kVersionCheckEnabled) {
      print('⏸️ Version check disabled (kVersionCheckEnabled = false)');
      return;
    }

    print('🚀 Starting app version check...');
    try {
      final versionService = VersionCheckService();
      final result = await versionService.checkVersion();

      if (result.needsUpdate && mounted) {
        print('⚠️ Update required! Showing update dialog...');
        _showUpdateDialog(result);
      } else {
        print('✅ App is up to date! Current version: ${result.currentVersion}');
      }
    } on Exception catch (e) {
      print('❌ Version check failed with exception: $e');
    } catch (e) {
      print('❌ Unexpected error during version check: $e');
    }
  }

  // YANGI METOD - Token'ni yangilash
  // Future<void> _refreshToken() async {
  //   print('🔄 Starting token refresh...');
  //   try {
  //     // Refresh token mavjudligini tekshirish
  //     if (_refreshTokenService.hasRefreshToken()) {
  //       await _refreshTokenService.refreshAccessToken();
  //       print('✅ Token successfully refreshed in MainPage');
  //     } else {
  //       print('⚠️ No refresh token found');
  //     }
  //   } catch (e) {
  //     print('❌ Token refresh failed in MainPage: $e');
  //     // Xatolik bo'lsa, foydalanuvchini login sahifasiga yo'naltirish mumkin
  //     // Navigator.pushReplacementNamed(context, '/login');
  //   }
  // }

  void _showUpdateDialog(VersionCheckResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        currentVersion: result.currentVersion,
        latestVersion: result.latestVersion,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final localization = AppLocalization.of(context);
      destinations = allDestinations(localization);

      _destinationKeys = destinations!
          .map((e) => GlobalObjectKey<NavigatorState>(e.index))
          .toList();

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _hide.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        if (notification.metrics.axis == Axis.vertical) {
          final UserScrollNotification userScroll = notification;
          switch (userScroll.direction) {
            case ScrollDirection.forward:
              if (_hide.value != 1.0) {
                _hide.forward();
              }
              break;
            case ScrollDirection.reverse:
              if (_hide.value != 0.0) {
                _hide.reverse();
              }
              break;
            case ScrollDirection.idle:
              break;
          }
        }
      }
    }
    return false;
  }

  void _onPageChanged(int index) {
    final currentBloc = context.read<MainBloc>();
    if (currentBloc.state.currentPage.getIndex != index) {
      debugPrint('Page o\'zgardi: $index');
      context.read<MainBloc>().add(
        MainPageChangeEvent(
          getPageFromIndex(index),
        ),
      );
    }
    _hide.forward();
  }

  MainPages getPageFromIndex(int index) {
    switch (index) {
      case 0:
        return MainPages.home;
      case 1:
        return MainPages.subjects;
      case 2:
        return MainPages.diagnostics;
      case 3:
        return MainPages.products;
      case 4:
        return MainPages.profile;
      default:
        return MainPages.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || destinations == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocConsumer<MainBloc, MainState>(
      listenWhen: (previous, current) =>
      previous.currentPage != current.currentPage,
      listener: (context, state) {
        if (_pageController.hasClients) {
          final currentPage = _pageController.page?.round() ?? 0;
          final targetPage = state.currentPage.getIndex;

          if (currentPage != targetPage) {
            _pageController.animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      buildWhen: (previous, current) =>
      previous.searchRoutes != current.searchRoutes ||
          previous.currentPage != current.currentPage,
      builder: (context, state) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (state.searchRoutes == Routes.subject &&
                state.currentPage.isSubject) {
              return false;
            }
            return _handleScrollNotification(notification);
          },
          child: Scaffold(
            backgroundColor: context.color.scaffoldBackGroundColor,
            resizeToAvoidBottomInset: false,
            key: mainScaffoldKey,
            drawer: const Drawer(
              width: double.infinity,
              child: ProfilePage(),
            ),
            drawerEnableOpenDragGesture: false,
            body: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const ClampingScrollPhysics(),
                  children: destinations!.map((destination) {
                    return DestinationPage(
                      currentKey: _destinationKeys![destination.index],
                      initialRoute: destination.initialRoute,
                      onGenerateRoute:
                      widget.onGenerateRoutes[destination.index],
                      onNavigation: (route) {
                        if (state.currentPage.isSubject) {
                          context.read<MainBloc>().add(
                            MainSearchRoutesObserverEvent(route),
                          );
                        }
                        _hide.forward();
                      },
                    );
                  }).toList(),
                ),
                QuickMathFloatingButton(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizeTransition(
                    sizeFactor: _hide,
                    axisAlignment: -1.0,
                    child: CustomBottomAppBar(
                      destinations: destinations!,
                      destinationKeys: _destinationKeys!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
//
// import 'package:my_flutter_template/core/extension/extensions.dart';
// import 'package:my_flutter_template/core/theme/app_text_style.dart';
// import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// import 'package:my_flutter_template/core/utils/app_utils.dart';
// import 'package:my_flutter_template/core/widgets/custom_animated_btn.dart';
// import 'package:my_flutter_template/features/main/presentation/pages/destination_page.dart';
// import 'package:my_flutter_template/features/qr_code_scan/presentation/page_args/checkout_page_args.dart';
// import 'package:my_flutter_template/features/qr_code_scan/presentation/page_args/qr_code_page_args.dart';
// import 'package:my_flutter_template/features/wallet/presentation/blocs/wallet/wallet_bloc.dart';
// import 'package:my_flutter_template/generated/assets.dart';
// import 'package:my_flutter_template/generated/l10n.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../../core/app_bloc/app_bloc.dart';
// import '../../../../router/app_routes.dart';
// import '../../../../router/name_routes.dart';
// import '../bloc/main_bloc.dart';
//
// part '../navigation_stuff/destination_data.dart';
//
// class MainPage extends StatefulWidget {
//   final List<OnGenerateRoute> onGenerateRoutes;
//
//   const MainPage({super.key, required this.onGenerateRoutes});
//
//   @override
//   State<MainPage> createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> {
//   late final List<GlobalObjectKey<NavigatorState>> _destinationKeys;
//
//   // late belgisini olib tashlang va bo'sh ro'yxat bilan initsializatsiya qiling
//   List<Destination> destinations = [];
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<MainBloc>().add(const MainInitialEvent());
//
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       final localization = AppLocalization.of(context);
//       destinations = allDestinations(localization);
//       _destinationKeys = destinations
//           .map((e) => GlobalObjectKey<NavigatorState>(e.index))
//           .toList();
//       setState(() {});
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // destinations bo'sh bo'lsa, loading holati ko'rsating
//     if (destinations.isEmpty) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     return BlocBuilder<MainBloc, MainState>(
//       buildWhen: (previous, current) =>
//           previous.currentPage != current.currentPage,
//       builder: (context, state) {
//         final currentDestination = destinations.firstWhere(
//           (dest) => dest.index == state.currentPage.getIndex,
//           orElse: () => destinations.first,
//         );
//
//         return Scaffold(
//           backgroundColor: context.color.scaffoldBackGroundColor,
//           appBar: AppBar(
//             backgroundColor: context.color.scaffoldBackGroundColor,
//             elevation: 0,
//             title: Text(
//               currentDestination.title,
//               style: context.textStyle.fontSize14FontWeight700.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: context.color.primaryColor1,
//               ),
//             ),
//             iconTheme: IconThemeData(
//               color: context.color.primaryColor1,
//             ),
//           ),
//           drawer: _buildDrawer(context, state),
//           body: Stack(
//             children: destinations.map((Destination destination) {
//               final bool isSelected =
//                   destination.index == state.currentPage.getIndex;
//
//               return Offstage(
//                 offstage: !isSelected,
//                 child: DestinationPage(
//                   currentKey: _destinationKeys[destination.index],
//                   initialRoute: destination.initialRoute,
//                   onGenerateRoute: widget.onGenerateRoutes[destination.index],
//                   onNavigation: (route) {
//                     // if (state.currentPage.isSubject) {
//                     //   context.read<MainBloc>().add(
//                     //     MainSearchRoutesObserverEvent(route),
//                     //   );
//                     // }
//                   },
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDrawer(BuildContext context, MainState state) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       width: 280,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with app name and logo
//           Container(
//             height: 120,
//             width: double.infinity,
//             padding:
//                 const EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 20),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 bottom: BorderSide(
//                   color: Color(0xFFE5E7EB),
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Image.asset(Assets.pngLogo, height: 48, width: 48),
//                 Text(
//                   'MATH',
//                   style: context.textStyle.fontSize24FontWeight700.copyWith(
//                     color: context.color.black,
//                     fontSize: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Category title
//           Padding(
//             padding: const EdgeInsets.only(left: 20, top: 20, bottom: 8),
//             child: Text(
//               'Asosiy',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//
//           // Menu items
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 // Main navigation items (your original destinations)
//                 const SizedBox(height: 20),
//                 Container(
//                   height: 1,
//                   color: const Color(0xFFE5E7EB),
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                 ),
//                 const SizedBox(height: 12),
//
//                 ...destinations.map((destination) {
//                   final bool isSelected =
//                       destination.index == state.currentPage.getIndex;
//
//                   return _buildDrawerItem(
//                     // iconAsset: isSelected ? destination.selectedIcon : destination.icon,
//                     icon: destination.icon,
//                     title: destination.title,
//                     isSelected: isSelected,
//                     onTap: () {
//                       Navigator.of(context).pop();
//                       MainPages targetPage =
//                           MainPages.values[destination.index];
//                       context.read<MainBloc>().add(
//                             MainPageChangeEvent(targetPage),
//                           );
//                     },
//                   );
//                 }),
//               ],
//             ),
//           ),
//
//           // Logout button
//           Container(
//             padding: const EdgeInsets.all(20),
//             child: _buildDrawerItem(
//               icon: Icons.logout_outlined,
//               title: 'Chiqish',
//               isSelected: false,
//               textColor: Colors.red[600],
//               iconColor: Colors.red[600],
//               onTap: () {
//                 Navigator.of(context).pop();
//                 // context.read<AppBloc>().add(const AppLogoutEvent());
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem({
//     IconData? icon,
//     String? iconAsset,
//     required String title,
//     required bool isSelected,
//     bool hasDropdown = false,
//     Color? textColor,
//     Color? iconColor,
//     required VoidCallback onTap,
//   }) {
//     final defaultTextColor =
//         isSelected ? const Color(0xFF6366F1) : const Color(0xFF6B7280);
//     final defaultIconColor =
//         isSelected ? const Color(0xFF6366F1) : const Color(0xFF9CA3AF);
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//       child: Material(
//         color: isSelected
//             ? const Color(0xFF6366F1).withOpacity(0.08)
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             child: Row(
//               children: [
//                 // Icon
//                 SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: iconAsset != null
//                       ? SvgPicture.asset(
//                           iconAsset,
//                           colorFilter: ColorFilter.mode(
//                             iconColor ?? defaultIconColor,
//                             BlendMode.srcIn,
//                           ),
//                         )
//                       : Icon(
//                           icon,
//                           size: 24,
//                           color: iconColor ?? defaultIconColor,
//                         ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Title
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       color: textColor ?? defaultTextColor,
//                       fontSize: 15,
//                       fontWeight:
//                           isSelected ? FontWeight.w600 : FontWeight.w400,
//                     ),
//                   ),
//                 ),
//                 // Dropdown arrow if needed
//                 if (hasDropdown)
//                   Icon(
//                     Icons.keyboard_arrow_down,
//                     size: 20,
//                     color: defaultIconColor,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
