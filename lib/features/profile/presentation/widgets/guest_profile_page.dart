// import 'package:my_flutter_template/core/extension/extensions.dart';
// import 'package:my_flutter_template/core/theme/app_text_style.dart';
// import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// import 'package:my_flutter_template/core/widgets/custom_animation_effects.dart';
// import 'package:my_flutter_template/features/auth/presentation/page_args/auth_args.dart';
// import 'package:my_flutter_template/generated/l10n.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:gap/gap.dart';
//
// import '../../../../generated/assets.dart';
// import '../../../../router/app_routes.dart';
// import '../../../../router/name_routes.dart';
// import 'change_language_btm_sheet.dart';
// import 'profile_item.dart';
//
// class GuestProfilePage extends StatelessWidget {
//   const GuestProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalization.of(context);
//     return Scaffold(
//       backgroundColor: context.color.scaffoldBackGroundColor,
//       body: CustomScrollView(
//         slivers: [
//           SliverFillRemaining(
//             child: SafeArea(
//               minimum: EdgeInsets.only(
//                 left: 20,
//                 right: 20,
//                 top: 94.height,
//                 bottom: 143.height,
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           localization.profile,
//                           style: context.textStyle.fontSize18FontWeight800,
//                         ),
//                         Gap(56.height),
//                         ProfileItem(
//                           iconUrl: Assets.svgIcLanguage,
//                           title: localization.change_language,
//                           onTap: () {
//                             showModalBottomSheet(
//                               context: mainRootNavigatorKey.currentContext!,
//                               isScrollControlled: true,
//                               backgroundColor: Colors.transparent,
//                               builder: (context) =>
//                                   const ChangeLanguageBtmSheet(),
//                             );
//                           },
//                         ),
//                         const Gap(40),
//                         ProfileItem(
//                           iconUrl: Assets.svgComments,
//                           title: localization.chat_with_support,
//                           onTap: () {},
//                         ),
//                         const Gap(20),
//                         ProfileItem(
//                           iconUrl: Assets.svgIcQuestionCheck,
//                           title: localization.questions_and_answers,
//                           onTap: () {
//                             Navigator.of(
//                               mainRootNavigatorKey.currentContext!,
//                             ).pushNamed(Routes.faq);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(
//                         mainRootNavigatorKey.currentContext!,
//                         Routes.auth,
//                         arguments: const AuthPageArgs(),
//                       ).whenComplete(
//                         () {
//                           // context.read<MainBloc>().add(
//                           //       const MainInitialEvent(),
//                           //     );
//                           // context.read<WalletBloc>().add(
//                           //       const WalletInitializeEvent(),
//                           //     );
//                         },
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: context.color.primaryColor2,
//                     ),
//                     child: Text(localization.login_or_register),
//                   ),
//                 ].animate(
//                   effects: slideAndFadeEffect,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
