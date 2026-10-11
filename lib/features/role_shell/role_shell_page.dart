import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_bloc/app_bloc.dart';
import '../../core/local_source/local_source.dart';
import '../../core/widgets/dash_ui.dart';
import '../../injector_container.dart';
import '../../router/app_routes.dart';
import '../../router/name_routes.dart';
import '../home/presentation/pages/settings/settings_page.dart';
import '../main/presentation/bloc/main_bloc.dart';
import '../soon/presentation/soon_page.dart';

/// Pastki menyudagi bitta bo'lim
class RoleTab {
  const RoleTab({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.initialRoute,
    required this.onGenerateRoute,
  });

  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String initialRoute;
  final OnGenerateRoute onGenerateRoute;
}

/// Ichki sahifalardan bo'limni almashtirish uchun: `RoleShell.of(context)?.goTo(1)`
class RoleShell extends InheritedWidget {
  const RoleShell({super.key, required this.goTo, required this.current, required super.child});

  final void Function(int index) goTo;
  final int current;

  static RoleShell? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<RoleShell>();

  @override
  bool updateShouldNotify(RoleShell oldWidget) => oldWidget.current != current;
}

/// Ota-ona va o'qituvchi panellari uchun umumiy qobiq: har bir bo'lim o'z
/// navigatoriga ega (holati saqlanadi), pastda zamonaviy menyu.
class RoleShellPage extends StatefulWidget {
  const RoleShellPage({super.key, required this.tabs});

  final List<RoleTab> tabs;

  @override
  State<RoleShellPage> createState() => _RoleShellPageState();
}

class _RoleShellPageState extends State<RoleShellPage> {
  late final List<GlobalKey<NavigatorState>> _keys =
      List.generate(widget.tabs.length, (i) => GlobalKey<NavigatorState>(debugLabel: 'role-tab-$i'));
  final Set<int> _opened = {0};
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<MainBloc>().add(const MainInitialEvent());
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.tabs.length) return;
    if (index == _index) {
      // Shu bo'lim qayta bosilsa — boshiga qaytadi
      _keys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _index = index;
      _opened.add(index);
    });
  }

  Future<void> _onBack() async {
    final navigator = _keys[_index].currentState;
    if (navigator != null && await navigator.maybePop()) return;
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: RoleShell(
        goTo: _goTo,
        current: _index,
        child: Scaffold(
          key: mainScaffoldKey,
          backgroundColor: DashColors.bg,
          drawer: SettingsDrawer(),
          drawerEnableOpenDragGesture: false,
          body: IndexedStack(
            index: _index,
            children: [
              for (var i = 0; i < widget.tabs.length; i++)
                _opened.contains(i)
                    ? Navigator(
                        key: _keys[i],
                        initialRoute: widget.tabs[i].initialRoute,
                        onGenerateRoute: widget.tabs[i].onGenerateRoute,
                        onUnknownRoute: (settings) => MaterialPageRoute(
                          settings: settings,
                          builder: (_) => const SoonPage(),
                        ),
                      )
                    : const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: _BottomBar(tabs: widget.tabs, index: _index, onTap: _goTo),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.tabs, required this.index, required this.onTap});

  final List<RoleTab> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: DashColors.ink.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: i == index ? DashColors.primarySoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            i == index ? tabs[i].activeIcon : tabs[i].icon,
                            size: 24,
                            color: i == index ? DashColors.primary : DashColors.subtle,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tabs[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: i == index ? FontWeight.w800 : FontWeight.w600,
                              color: i == index ? DashColors.primary : DashColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bo'lim sahifalari tepasidagi qator: avatar (yon menyuni ochadi), salom va bildirishnomalar
class DashTopBar extends StatelessWidget {
  const DashTopBar({super.key, required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final local = sl<LocalSource>();
    final name = [local.getFirstName(), local.getLastName()]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ');
    final first = name.split(' ').first;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            mainScaffoldKey.currentState?.openDrawer();
          },
          child: InitialsAvatar(name: name.isEmpty ? '?' : name, size: 46),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: const TextStyle(fontSize: 12.5, color: DashColors.muted)),
              Text(
                first.isEmpty ? 'iQ Math' : '$first 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DashColors.navy),
              ),
            ],
          ),
        ),
        _RoundIcon(
          icon: Icons.notifications_none_rounded,
          onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(Routes.notification),
        ),
        const SizedBox(width: 8),
        _RoundIcon(icon: Icons.menu_rounded, onTap: () => mainScaffoldKey.currentState?.openDrawer()),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: DashColors.line),
          ),
          child: Icon(icon, size: 22, color: DashColors.ink),
        ),
      ),
    );
  }
}

/// Joriy til (uz/ru)
String currentLocale(BuildContext context) => context.watch<AppBloc>().state.appLocale ?? 'uz';
