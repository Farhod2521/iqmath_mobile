part of '../pages/main_page.dart';

class Destination extends Equatable {
  const Destination({
    required this.index,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.initialRoute,
  });

  final int index;
  final String title;
  final String icon;
  final String selectedIcon;
  final String initialRoute;

  @override
  List<Object?> get props => [index, title, icon, selectedIcon, initialRoute];
}

List<Destination> allDestinations(AppLocalization localization) =>
    <Destination>[
      Destination(
        index: 0,
        // title: localization.home,
        title: 'Bosh sahifa',
        icon: Assets.svgHomeBottom,
        selectedIcon: Assets.pngHomeRounded,
        initialRoute: Routes.home,
      ),
      Destination(
        index: 1,
        title: 'Kurslar',
        icon: Assets.svgBookBottom,
        selectedIcon: Assets.pngSearchRounded,
        initialRoute: Routes.subject,
      ),
      Destination(
        index: 2,
        title: 'Diagnostika',
        icon: Assets.svgChartDiagram,
        selectedIcon: Assets.pngWalletRounded,
        initialRoute: Routes.diagnostics,
      ),
      Destination(
        index: 3,
        title: 'Battle',
        icon: Assets.svgSuggestion,
        selectedIcon: Assets.pngUser,
        initialRoute: Routes.suggestions,
      ),
      Destination(
        index: 4,
        title: 'Ko\'proq',
        icon: Assets.svgMenuBottom,
        selectedIcon: Assets.pngUser,
        initialRoute: Routes.profile,
      ),
    ];

// List<Destination> allDestinations(AppLocalization localization) =>
//     <Destination>[
//       Destination(
//         index: 0,
//         title: 'Fanlar',
//         icon: Icons.menu_book_outlined,
//         selectedIcon: Assets.pngHomeRounded,
//         initialRoute: Routes.home,
//       ),
//       Destination(
//         index: 1,
//         title: 'Diagnostika',
//         icon: Icons.check_circle_outline,
//         selectedIcon: Assets.pngSearchRounded,
//         initialRoute: Routes.search,
//       ),
//       Destination(
//         index: 2,
//         title: 'Tavsiya etiladi',
//         icon: Icons.view_list_outlined,
//         selectedIcon: Assets.pngWalletRounded,
//         initialRoute: Routes.wallet,
//       ),
//       Destination(
//         index: 3,
//         title: 'Taklif qilish',
//         icon: Icons.person_outline,
//         selectedIcon: Assets.pngUser,
//         initialRoute: Routes.profile,
//       ),
//       Destination(
//         index: 4,
//         title: 'Chat',
//         icon: Icons.chat_bubble_outline,
//         selectedIcon: Assets.pngHomeRounded,
//         initialRoute: Routes.home,
//       ),
//       Destination(
//         index: 5,
//         title: 'Mahsulotlar',
//         icon: Icons.folder_outlined,
//         selectedIcon: Assets.pngSearchRounded,
//         initialRoute: Routes.search,
//       ),
//       Destination(
//         index: 6,
//         title: localization.profile,
//         icon: Icons.person_outline,
//         selectedIcon: Assets.pngWalletRounded,
//         initialRoute: Routes.wallet,
//       ),
//       Destination(
//         index: 7,
//         title: 'Ballar va Tangalar',
//         icon: Icons.storage_outlined,
//         selectedIcon: Assets.pngUser,
//         initialRoute: Routes.profile,
//       ),
//     ];

// _buildDrawerItem(
// icon: Icons.menu_book_outlined,
// title: 'Fanlar',
// isSelected: false,
// onTap: () {},
// ),
