import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/main/presentation/bloc/main_bloc.dart';
import 'package:my_flutter_template/features/main/presentation/pages/destination_page.dart';
import 'package:my_flutter_template/features/main_parent/presentation/navigation_stuff/parent_destination_data.dart';
import 'package:my_flutter_template/features/main_parent/presentation/widgets/custom_parent_bottom_appbar.dart';
import 'package:my_flutter_template/features/main_teacher/presentation/navigation_stuff/teacher_destination_data.dart';
import 'package:my_flutter_template/features/main_teacher/presentation/widgets/custom_teacher_bottom_appbar.dart' show CustomTeacherBottomAppbar;
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';
import '../../../home/presentation/pages/settings/settings_page.dart';
import '../../../main/presentation/pages/main_page.dart';

class MainTeacherPage extends StatefulWidget {
  final List<OnGenerateRoute> onGenerateRoutes;

  const MainTeacherPage({super.key, required this.onGenerateRoutes});

  @override
  State<MainTeacherPage> createState() => _MainTeacherPageState();
}

class _MainTeacherPageState extends State<MainTeacherPage> with TickerProviderStateMixin {
  List<GlobalObjectKey<NavigatorState>>? _destinationKeys;
  late final AnimationController _hide;
  late final PageController _pageController;
  List<Destination>? destinations;
  bool _isInitialized = false;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final localization = AppLocalization.of(context);
      destinations = allTeacherDestinations(localization);

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

          // Faqat agar haqiqatan sahifa o'zgarsa
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
            drawer: SettingsDrawer(),
            drawerEnableOpenDragGesture: false,
            body: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const ClampingScrollPhysics(), // Bu qo'shildi
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

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizeTransition(
                    sizeFactor: _hide,
                    axisAlignment: -1.0,
                    child: CustomTeacherBottomAppbar(
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