// part of '../pages/main_page.dart';
//
// class CreateBottomSheet extends StatelessWidget {
//   const CreateBottomSheet({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalization.of(context);
//     return SafeArea(
//       minimum: AppUtils.kPaddingAll24,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(
//                 Routes.create,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               shape: const RoundedRectangleBorder(
//                 borderRadius: AppUtils.kBorderRadius100,
//               ),
//               maximumSize: const Size.fromHeight(40),
//               minimumSize: const Size.fromHeight(40),
//             ),
//             child: Text(localization.create_ad),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(
//                 Routes.requestPrice,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               shape: const RoundedRectangleBorder(
//                 borderRadius: AppUtils.kBorderRadius100,
//               ),
//               maximumSize: const Size.fromHeight(40),
//               minimumSize: const Size.fromHeight(40),
//               backgroundColor: context.color.white,
//               surfaceTintColor: context.color.white,
//               elevation: 0,
//               side: BorderSide(
//                 color: context.color.grey100,
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               localization.request_price,
//               style: context.textStyle.buttonStyle.copyWith(
//                 color: context.color.black,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               shape: const RoundedRectangleBorder(
//                 borderRadius: AppUtils.kBorderRadius100,
//               ),
//               maximumSize: const Size.fromHeight(40),
//               minimumSize: const Size.fromHeight(40),
//               backgroundColor: context.color.white,
//               surfaceTintColor: context.color.white,
//               elevation: 0,
//               side: BorderSide(
//                 color: context.color.grey100,
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               localization.create_vacancy,
//               style: context.textStyle.buttonStyle.copyWith(
//                 color: context.color.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
