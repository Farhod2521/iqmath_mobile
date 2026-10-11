import 'package:flutter/material.dart';

import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';
import '../../../role_shell/role_shell_page.dart';

/// Ota-ona paneli: Asosiy · Farzandlarim · Profil (saytdagi menyu bilan bir xil)
class MainParentPage extends StatelessWidget {
  /// [onGenerateRoutes] — har bir bo'lim uchun: bosh sahifa, farzandlar, profil
  final List<OnGenerateRoute> onGenerateRoutes;

  const MainParentPage({super.key, required this.onGenerateRoutes});

  @override
  Widget build(BuildContext context) {
    final ru = currentLocale(context) == 'ru';
    return RoleShellPage(
      tabs: [
        RoleTab(
          title: ru ? 'Главная' : 'Asosiy',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          initialRoute: Routes.home,
          onGenerateRoute: onGenerateRoutes[0],
        ),
        RoleTab(
          title: ru ? 'Мои дети' : 'Farzandlarim',
          icon: Icons.people_outline_rounded,
          activeIcon: Icons.people_rounded,
          initialRoute: Routes.parentChildren,
          onGenerateRoute: onGenerateRoutes[1],
        ),
        RoleTab(
          title: ru ? 'Профиль' : 'Profil',
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          initialRoute: Routes.roleProfile,
          onGenerateRoute: onGenerateRoutes[2],
        ),
      ],
    );
  }
}
