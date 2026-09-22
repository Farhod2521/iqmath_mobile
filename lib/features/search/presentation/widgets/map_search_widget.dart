// import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// import 'package:my_flutter_template/features/search/presentation/blocs/search_bloc.dart';
// import 'package:flutter/material.dart';
//
// import '../../../../core/widgets/custom_search_field.dart';
// import '../../../../generated/assets.dart';
// import '../../../../generated/l10n.dart';
//
// class MapSearchWidget extends StatelessWidget {
//   const MapSearchWidget({
//     super.key,
//     required DraggableScrollableController controller,
//     required TextEditingController searchController,
//     required this.onChanged,
//     required this.sheetStatus,
//   })  : _controller = controller,
//         _searchController = searchController;
//   final SearchSheetStatus sheetStatus;
//   final DraggableScrollableController _controller;
//   final TextEditingController _searchController;
//   final Function(String) onChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     final AppLocalization localization = AppLocalization.of(context);
//     return Material(
//       color: sheetStatus.isMax
//           ? context.color.scaffoldBackGroundColor
//           : Colors.transparent,
//       child: SafeArea(
//         minimum: const EdgeInsets.symmetric(horizontal: 16),
//         bottom: false,
//         child: CustomSearchBar(
//           buttonIcon: sheetStatus.isMax ? Assets.svgMarker : Assets.svgList1,
//           buttonOnTap: () {
//             if (sheetStatus.isMax) {
//               _controller.animateTo(
//                 SearchSheetStatus.initial.height,
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             } else {
//               _controller.animateTo(
//                 SearchSheetStatus.max.height,
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//               );
//             }
//           },
//           onChanged: onChanged,
//           controller: _searchController,
//           hintText: localization.search_restaurants_and_dishes,
//         ),
//       ),
//     );
//   }
// }
