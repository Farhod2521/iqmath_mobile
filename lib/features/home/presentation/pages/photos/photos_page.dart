// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// import 'package:my_flutter_template/core/widgets/custom_animation_effects.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//
// import '../../../../../core/widgets/appbar_leading_widget.dart';
// import '../../../../../core/widgets/custom_loading_indicator.dart';
// import '../../../../../generated/l10n.dart';
// import '../../../../../router/app_routes.dart';
// import '../../../../../router/name_routes.dart';
// import '../../../../photo_view/presentation/args/photo_view_page_args.dart';
// import '../../page_arguments/photos_page_args.dart';
//
// class PhotosPage extends StatefulWidget {
//   final PhotosPageArgs args;
//
//   const PhotosPage({Key? key, required this.args}) : super(key: key);
//
//   @override
//   State<PhotosPage> createState() => _PhotosPageState();
// }
//
// class _PhotosPageState extends State<PhotosPage> {
//   late Brightness brightness;
//
//   @override
//   void initState() {
//     brightness =
//         MediaQuery.of(mainRootNavigatorKey.currentContext!).platformBrightness;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalization.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarBrightness: brightness,
//         ),
//         title: Text(localization.photos),
//         leading: const AppbarLeadingWidget(
//           withBackground: false,
//         ),
//       ),
//       body: MasonryGridView.builder(
//         gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//         ),
//         crossAxisSpacing: 11,
//         mainAxisSpacing: 11,
//         itemCount: widget.args.photos.length,
//         padding: const EdgeInsets.all(20),
//         itemBuilder: (context, index) => InkWell(
//           onTap: () {
//             setState(() {
//               brightness = Brightness.dark;
//             });
//             Navigator.pushNamed(
//               mainRootNavigatorKey.currentContext!,
//               Routes.photoView,
//               arguments: PhotoViewPageArgs(
//                 images: widget.args.photos,
//                 initialIndex: index,
//               ),
//             ).whenComplete(() {
//               setState(() {
//                 brightness = MediaQuery.of(context).platformBrightness;
//               });
//             });
//           },
//           borderRadius: BorderRadius.circular(10),
//           child: Ink(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: context.color.scaffoldBackGroundColor,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Hero(
//               tag: widget.args.photos[index],
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: CachedNetworkImage(
//                   imageUrl: widget.args.photos[index],
//                   placeholder: (context, url) => Center(
//                     child: CustomLoadingIndicator(
//                       color: context.color.accentColor,
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => const Icon(Icons.error),
//                 ),
//               ),
//             ),
//           ),
//         ).animate(effects: slideAndFadeEffect),
//       ),
//     );
//   }
// }
