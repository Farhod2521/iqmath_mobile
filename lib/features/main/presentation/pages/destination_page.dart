import 'package:my_flutter_template/features/soon/presentation/soon_page.dart';
import 'package:flutter/material.dart';

import '../../../../router/app_routes.dart';
import '../navigation_stuff/view_navigator_observer.dart';

class DestinationPage extends StatefulWidget {
  final OnGenerateRoute onGenerateRoute;
  final Function(String) onNavigation;
  final String initialRoute;
  final Key currentKey;

  const DestinationPage({
    super.key,
    required this.currentKey,
    required this.onNavigation,
    required this.onGenerateRoute,
    required this.initialRoute,
  });

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // MUHIM: AutomaticKeepAliveClientMixin uchun

    return Navigator(
      key: widget.currentKey,
      observers: <NavigatorObserver>[
        ViewNavigatorObserver(widget.onNavigation),
      ],
      initialRoute: widget.initialRoute,
      onUnknownRoute: (settings) => PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: const SoonPage(),
            ),
      ),
      onGenerateRoute: widget.onGenerateRoute,
    );
  }
}