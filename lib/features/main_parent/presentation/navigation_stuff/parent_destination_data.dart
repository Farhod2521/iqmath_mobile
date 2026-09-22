import 'package:my_flutter_template/features/main/presentation/pages/main_page.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:my_flutter_template/router/name_routes.dart';

List<Destination> allParentDestinations(AppLocalization localization) =>
    <Destination>[
      Destination(
        index: 0,
        // title: localization.home,
        title: 'Asosiy',
        icon: Assets.svgHomeBottom,
        selectedIcon: Assets.pngHomeRounded,
        initialRoute: Routes.home,
      ),
      Destination(
        index: 1,
        title: 'Ko\'proq',
        icon: Assets.svgMenuBottom,
        selectedIcon: Assets.pngUser,
        initialRoute: Routes.parentSubject,
      ),
    ];
