// import 'package:my_flutter_template/core/extension/extensions.dart';
// import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// import 'package:my_flutter_template/core/utils/app_utils.dart';
// import 'package:my_flutter_template/core/utils/debouncer.dart';
// import 'package:my_flutter_template/features/search/presentation/blocs/search_bloc.dart';
// import 'package:my_flutter_template/features/search/presentation/widgets/search_item.dart';
// import 'package:dots_indicator/dots_indicator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
// import 'package:gap/gap.dart';
// import 'package:yandex_mapkit/yandex_mapkit.dart' hide SearchItem;
//
// import '../../../../core/widgets/custom_animation_effects.dart';
// import '../../../../core/widgets/custom_bottom_sheet.dart';
// import '../../../../core/widgets/filter_btm_sheet.dart';
// import '../../../../generated/assets.dart';
// import '../../../../router/app_routes.dart';
// import '../../../main/presentation/bloc/main_bloc.dart';
// import '../../mock_data/search_mock_data.dart';
// import '../painters/location_marker_painter.dart';
// import '../widgets/map_button_widget.dart';
// import '../widgets/map_search_widget.dart';
// import '../widgets/search_filter_item.dart';
//
// class SearchPage extends StatefulWidget {
//   const SearchPage({Key? key}) : super(key: key);
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   late final DraggableScrollableController _controller;
//   late final FlutterCarouselController _carouselController;
//   late final TextEditingController _searchController;
//   YandexMapController? _mapController;
//   List<PlacemarkMapObject> _mapObjects = [];
//   final Debouncer debouncer = Debouncer(milliseconds: 500);
//
//   @override
//   void initState() {
//     _controller = DraggableScrollableController();
//     _searchController = TextEditingController();
//     _carouselController = FlutterCarouselController();
//     // context.read<SearchBloc>().add(const SearchInitializeEvent());
//     context.read<SearchBloc>().add(const SearchGetCurrentPositionEvent());
//     _controller.addListener(() {
//       _vibrationHandler();
//       context.read<SearchBloc>().add(
//             SearchSetSheetStatusEvent(_controller.size),
//           );
//     });
//     super.initState();
//   }
//
//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final bottom = MediaQuery.of(context).viewPadding.bottom;
//     final top = MediaQuery.of(context).viewPadding.top;
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: context.color.scaffoldBackGroundColor,
//       body: Padding(
//         padding: const EdgeInsets.only(bottom: 78),
//         child: Stack(
//           children: [
//             BlocConsumer<SearchBloc, SearchState>(
//               listener: (context, state) async {
//                 if (state.status.isError) {
//                   AppUtils.showSnackBar(
//                     context: context,
//                     message: state.errorMessage!.message,
//                     title: state.errorMessage!.title,
//                   );
//                 } else if (state.status.isSuccess) {
//                   _mapObjects.add(
//                     PlacemarkMapObject(
//                       mapId: const MapObjectId("CurrentLocation"),
//                       point: Point(
//                         latitude: state.currentPoint?.latitude ?? 41.29,
//                         longitude: state.currentPoint?.longitude ?? 69.22,
//                       ),
//                       opacity: 1,
//                       icon: PlacemarkIcon.single(
//                         PlacemarkIconStyle(
//                           image: BitmapDescriptor.fromAssetImage(
//                             Assets.pngIcRedMarker,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                   if (state.searchRestaurants != null) {
//                     for (var restaurant in state.searchRestaurants!) {
//                       _mapObjects.add(
//                         PlacemarkMapObject(
//                           mapId: MapObjectId("${restaurant.id}"),
//                           point: Point(
//                             latitude: restaurant.lat ?? 41.29,
//                             longitude: restaurant.long ?? 69.22,
//                           ),
//                           opacity: 1,
//                           icon: PlacemarkIcon.single(
//                             PlacemarkIconStyle(
//                               image: BitmapDescriptor.fromBytes(
//                                 await LocationMarkerPainter.defaultMarker(
//                                   context,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                   } else {
//                     for (var restaurant
//                         in state.initialSearchRestaurants ?? []) {
//                       _mapObjects.add(
//                         PlacemarkMapObject(
//                           mapId: MapObjectId("${restaurant.id}"),
//                           point: Point(
//                             latitude: restaurant.lat ?? 41.29,
//                             longitude: restaurant.long ?? 69.22,
//                           ),
//                           opacity: 1,
//                           icon: PlacemarkIcon.single(
//                             PlacemarkIconStyle(
//                               image: BitmapDescriptor.fromBytes(
//                                 await LocationMarkerPainter.defaultMarker(
//                                   context,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                   }
//                 }
//               },
//               builder: (context, state) {
//                 return Positioned.fill(
//                   child: BlocListener<SearchBloc, SearchState>(
//                     listenWhen: (previous, current) =>
//                         previous.currentPoint != current.currentPoint,
//                     listener: (context, state) {
//                       _mapController?.moveCamera(
//                         CameraUpdate.newCameraPosition(
//                           CameraPosition(
//                             target: Point(
//                               latitude: state.currentPoint?.latitude ?? 41.29,
//                               longitude: state.currentPoint?.longitude ?? 69.22,
//                             ),
//                             zoom: 12,
//                           ),
//                         ),
//                       );
//                     },
//                     child: YandexMap(
//                       onMapCreated: (controller) {
//                         _mapController = controller;
//                         _mapController?.moveCamera(
//                           CameraUpdate.newCameraPosition(
//                             CameraPosition(
//                               target: Point(
//                                 latitude: state.currentPoint?.latitude ?? 41.29,
//                                 longitude:
//                                     state.currentPoint?.longitude ?? 69.22,
//                               ),
//                               zoom: 12,
//                             ),
//                           ),
//                         );
//                       },
//                       onCameraPositionChanged:
//                           (cameraPosition, cameraUpdateSource, finished) {},
//                       mapObjects: _mapObjects,
//                       nightModeEnabled:
//                           MediaQuery.of(context).platformBrightness ==
//                               Brightness.dark,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             BlocBuilder<SearchBloc, SearchState>(
//               builder: (context, state) {
//                 return AnimatedPositioned(
//                   duration: kThemeAnimationDuration,
//                   right: 20,
//                   bottom:
//                       601 * size.height / 812 * state.sheetStatus.height + 31,
//                   child: MapButtonWidget(
//                     iconUrl: Assets.svgLocationCroshairs,
//                     onTap: () {
//                       _mapController?.moveCamera(
//                         CameraUpdate.newCameraPosition(
//                           CameraPosition(
//                             target: Point(
//                               latitude: state.currentPoint?.latitude ?? 41.29,
//                               longitude: state.currentPoint?.longitude ?? 69.22,
//                             ),
//                           ),
//                         ),
//                         animation: const MapAnimation(
//                           type: MapAnimationType.smooth,
//                           duration: 0.5,
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//             BlocBuilder<SearchBloc, SearchState>(
//               builder: (context, state) {
//                 return AnimatedPositioned(
//                   duration: kThemeAnimationDuration,
//                   right: 20,
//                   bottom:
//                       601 * size.height / 812 * state.sheetStatus.height + 109,
//                   child: MapButtonWidget(
//                     iconUrl: Assets.svgMinusSmall,
//                     onTap: () {
//                       _mapController?.moveCamera(
//                         CameraUpdate.zoomOut(),
//                         animation: const MapAnimation(
//                           type: MapAnimationType.smooth,
//                           duration: 0.5,
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//             BlocBuilder<SearchBloc, SearchState>(
//               builder: (context, state) {
//                 return AnimatedPositioned(
//                   duration: kThemeAnimationDuration,
//                   right: 20,
//                   bottom:
//                       601 * size.height / 812 * state.sheetStatus.height + 171,
//                   child: MapButtonWidget(
//                     iconUrl: Assets.svgPlusSmall,
//                     onTap: () {
//                       _mapController?.moveCamera(
//                         CameraUpdate.zoomIn(),
//                         animation: const MapAnimation(
//                           type: MapAnimationType.smooth,
//                           duration: 0.5,
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//             BlocBuilder<SearchBloc, SearchState>(
//               builder: (context, state) {
//                 if (state.sheetStatus.isMax) {
//                   return Positioned.fill(
//                     child: ColoredBox(
//                       color: context.color.scaffoldBackGroundColor,
//                     ),
//                   );
//                 } else {
//                   return const Positioned(
//                     height: 0,
//                     width: 0,
//                     child: SizedBox.shrink(),
//                   );
//                 }
//               },
//             ),
//             Positioned.fill(
//               child: Stack(
//                 children: [
//                   BlocBuilder<SearchBloc, SearchState>(
//                     builder: (context, state) {
//                       return Positioned(
//                         top: 0,
//                         right: 0,
//                         left: 0,
//                         height: 110.height,
//                         child: MapSearchWidget(
//                           controller: _controller,
//                           searchController: _searchController,
//                           sheetStatus: state.sheetStatus,
//                           onChanged: (query) {
//                             debouncer.run(
//                               () {
//                                 context.read<SearchBloc>().add(
//                                       SearchQueryEvent(
//                                         query,
//                                       ),
//                                     );
//                               },
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                   Positioned(
//                     left: 0,
//                     height: size.height > 700 ? 628.height : 600.height,
//                     right: 0,
//                     bottom: 0,
//                     child: DraggableScrollableSheet(
//                       controller: _controller,
//                       snap: true,
//                       initialChildSize: SearchSheetStatus.initial.height,
//                       minChildSize: SearchSheetStatus.min.height,
//                       maxChildSize: SearchSheetStatus.max.height,
//                       snapSizes: [
//                         SearchSheetStatus.min.height,
//                         SearchSheetStatus.initial.height,
//                         SearchSheetStatus.max.height,
//                       ],
//                       expand: false,
//                       builder: (context, scrollController) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(20),
//                               topRight: Radius.circular(20),
//                             ),
//                             color: context.color.scaffoldBackGroundColor,
//                           ),
//                           child: CustomScrollView(
//                             controller: scrollController,
//                             physics: const ClampingScrollPhysics(),
//                             primary: false,
//                             slivers: [
//                               SliverGap(10.height),
//                               SliverToBoxAdapter(
//                                 child: Container(
//                                   height: 4.height,
//                                   width: 35,
//                                   alignment: Alignment.center,
//                                   child: Container(
//                                     height: 4,
//                                     width: 35,
//                                     decoration: BoxDecoration(
//                                       borderRadius: AppUtils.kBorderRadius4,
//                                       color: context.color.bottomAppBarColor,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SliverGap(16.height),
//                               SliverToBoxAdapter(
//                                 child: SizedBox(
//                                   height: 32,
//                                   child: ListView.separated(
//                                     scrollDirection: Axis.horizontal,
//                                     primary: false,
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 20,
//                                     ),
//                                     itemBuilder: (context, index) =>
//                                         SearchFilterItem(
//                                       onTap: () {},
//                                       firstOnTap: () {
//                                         openBottomSheet(
//                                           mainRootNavigatorKey.currentContext!,
//                                           child: const FilterBtmSheet(),
//                                           constraints: BoxConstraints(
//                                             maxHeight: MediaQuery.of(context)
//                                                     .size
//                                                     .height *
//                                                 0.9,
//                                           ),
//                                         );
//                                       },
//                                       title: index == 0
//                                           ? ''
//                                           : searchFilters[index - 1],
//                                       isFirst: index == 0,
//                                     ),
//                                     separatorBuilder: (_, __) => const Gap(8),
//                                     itemCount: searchFilters.length + 1,
//                                   ),
//                                 ),
//                               ),
//                               SliverGap(24.height),
//                               BlocBuilder<SearchBloc, SearchState>(
//                                 builder: (context, state) {
//                                   var searchRestaurants =
//                                       state.searchRestaurants ??
//                                           state.initialSearchRestaurants;
//                                   if (state.sheetStatus.isInitial) {
//                                     return SliverToBoxAdapter(
//                                       child: state.status.isLoading
//                                           ? const SizedBox.shrink()
//                                           : DotsIndicator(
//                                               dotsCount:
//                                                   searchRestaurants?.length ??
//                                                       1,
//                                               position: state.dotsIndex.toDouble(),
//                                               onTap: (index) {
//                                                 _carouselController
//                                                     .animateToPage(
//                                                   index,
//                                                   duration: const Duration(
//                                                       milliseconds: 300),
//                                                   curve: Curves.easeInOut,
//                                                 );
//                                               },
//                                               axis: Axis.horizontal,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               decorator: DotsDecorator(
//                                                 shape:
//                                                     const RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                     Radius.circular(5),
//                                                   ),
//                                                 ),
//                                                 activeShape:
//                                                     const RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.all(
//                                                     Radius.circular(5),
//                                                   ),
//                                                 ),
//                                                 spacing: const EdgeInsets.only(
//                                                   left: 3,
//                                                 ),
//                                                 size: const Size(5, 4),
//                                                 activeSize: const Size(24, 4),
//                                                 color: context.color.mainText5,
//                                                 activeColor:
//                                                     context.color.mainText5,
//                                               ),
//                                             ),
//                                     );
//                                   } else {
//                                     return const SliverGap(0);
//                                   }
//                                 },
//                               ),
//                               BlocBuilder<SearchBloc, SearchState>(
//                                 builder: (context, state) {
//                                   var searchRestaurants =
//                                       state.searchRestaurants ??
//                                           state.initialSearchRestaurants;
//                                   if (state.sheetStatus.isInitial) {
//                                     return SliverToBoxAdapter(
//                                       child: state.status.isLoading
//                                           ? const SizedBox.shrink()
//                                           : BlocBuilder<MainBloc, MainState>(
//                                               buildWhen: (previous, current) =>
//                                                   previous.currentLocation !=
//                                                   current.currentLocation,
//                                               builder: (context, state) {
//                                                 return Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment
//                                                           .stretch,
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     Gap(24.height),
//                                                     SizedBox(
//                                                       height: 90,
//                                                       child: FlutterCarousel
//                                                           .builder(
//                                                         itemCount:
//                                                             searchRestaurants
//                                                                     ?.length ??
//                                                                 0,
//                                                         // carouselController:
//                                                         //     _carouselController,
//                                                         options:
//                                                         FlutterCarouselOptions(
//                                                           viewportFraction: 0.9,
//                                                           controller: _carouselController,
//                                                           // animateToClosest:
//                                                           //     true,
//                                                           disableCenter: true,
//                                                           onPageChanged:
//                                                               (index, reason) {
//                                                             context
//                                                                 .read<
//                                                                     SearchBloc>()
//                                                                 .add(
//                                                                   SearchDotsIndexEvent(
//                                                                       index),
//                                                                 );
//                                                           },
//                                                         ),
//                                                         itemBuilder: (context,
//                                                                 index,
//                                                                 realIndex) =>
//                                                             SearchItem(
//                                                           currentLocation: state
//                                                                   .currentLocation ??
//                                                               (0, 0),
//                                                           restaurantLocation: (
//                                                             searchRestaurants?[
//                                                                         index]
//                                                                     .lat ??
//                                                                 0,
//                                                             searchRestaurants?[
//                                                                         index]
//                                                                     .long ??
//                                                                 0,
//                                                           ),
//                                                           imageUrl:
//                                                               searchRestaurants?[
//                                                                           index]
//                                                                       .photos ??
//                                                                   [],
//                                                           title:
//                                                               searchRestaurants?[
//                                                                       index]
//                                                                   .name,
//                                                           address:
//                                                               searchRestaurants?[
//                                                                       index]
//                                                                   .address,
//                                                           workingHours:
//                                                               searchRestaurants?[
//                                                                       index]
//                                                                   .shiftTo,
//                                                           rating: (searchRestaurants?[
//                                                                           index]
//                                                                       .rate ??
//                                                                   0.0)
//                                                               .toDouble(),
//                                                           onTap: () {
//                                                             // Navigator.of(
//                                                             //         context)
//                                                             //     .pushNamed(
//                                                             //       Routes
//                                                             //           .restaurantInfo,
//                                                             //       arguments:
//                                                             //           RestaurantInfoPageArgs(
//                                                             //         menuId: searchRestaurants?[index]
//                                                             //                 .menuId ??
//                                                             //             'empty',
//                                                             //         avgPrice:
//                                                             //             searchRestaurants?[index].avgPrice ??
//                                                             //                 0,
//                                                             //         rating:
//                                                             //             searchRestaurants?[index].rate ??
//                                                             //                 0,
//                                                             //         ratingCount:
//                                                             //             searchRestaurants?[index].rateCount ??
//                                                             //                 0,
//                                                             //         organizationId:
//                                                             //             searchRestaurants?[index].organizationId ??
//                                                             //                 'empty',
//                                                             //         branchId: searchRestaurants?[index]
//                                                             //                 .id ??
//                                                             //             'empty',
//                                                             //         phoneNumber:
//                                                             //             searchRestaurants?[index].phoneNumber ??
//                                                             //                 [],
//                                                             //         name: searchRestaurants?[index]
//                                                             //                 .name ??
//                                                             //             'empty',
//                                                             //         description:
//                                                             //             searchRestaurants?[index].description ??
//                                                             //                 'empty',
//                                                             //         photos:
//                                                             //             searchRestaurants?[index].photos ??
//                                                             //                 [],
//                                                             //         shiftFrom: searchRestaurants?[
//                                                             //                 index]
//                                                             //             .shiftFrom,
//                                                             //         shiftTo: searchRestaurants?[
//                                                             //                 index]
//                                                             //             .shiftTo,
//                                                             //         telegramLink:
//                                                             //             searchRestaurants?[index]
//                                                             //                 .telegramLink,
//                                                             //         instagramLink:
//                                                             //             searchRestaurants?[index]
//                                                             //                 .instagramLink,
//                                                             //         facebookLink:
//                                                             //             searchRestaurants?[index]
//                                                             //                 .facebookLink,
//                                                             //       ),
//                                                             //     )
//                                                             //     .then(
//                                                             //       (value) => context
//                                                             //           .read<
//                                                             //               HomeBloc>()
//                                                             //           .add(
//                                                             //             const HomeGetAllRestaurantsEvent(),
//                                                             //           ),
//                                                             //     );
//                                                           },
//                                                         ),
//                                                       ).animate(
//                                                         effects: fadeEffect,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 );
//                                               },
//                                             ),
//                                     );
//                                   } else if (state.sheetStatus.isMax) {
//                                     return state.status.isLoading
//                                         ? const SliverToBoxAdapter(
//                                             child: SizedBox.shrink(),
//                                           )
//                                         : BlocBuilder<MainBloc, MainState>(
//                                             buildWhen: (previous, current) =>
//                                                 previous.currentLocation !=
//                                                 current.currentLocation,
//                                             builder: (context, state) {
//                                               return SliverList.separated(
//                                                 itemCount:
//                                                     searchRestaurants?.length ??
//                                                         0,
//                                                 separatorBuilder: (_, __) =>
//                                                     const Gap(14),
//                                                 itemBuilder: (context, index) =>
//                                                     SearchItem(
//                                                   currentLocation:
//                                                       state.currentLocation ??
//                                                           (0, 0),
//                                                   restaurantLocation: (
//                                                     searchRestaurants?[index]
//                                                             .lat ??
//                                                         0,
//                                                     searchRestaurants?[index]
//                                                             .long ??
//                                                         0,
//                                                   ),
//                                                   margin: const EdgeInsets
//                                                       .symmetric(
//                                                     horizontal: 20,
//                                                   ),
//                                                   imageUrl:
//                                                       searchRestaurants?[index]
//                                                               .photos ??
//                                                           [],
//                                                   title:
//                                                       searchRestaurants?[index]
//                                                           .name,
//                                                   address:
//                                                       searchRestaurants?[index]
//                                                           .address,
//                                                   workingHours:
//                                                       searchRestaurants?[index]
//                                                           .shiftTo,
//                                                   rating:
//                                                       (searchRestaurants?[index]
//                                                                   .rate ??
//                                                               0.0)
//                                                           .toDouble(),
//                                                   onTap: () {
//                                                     // Navigator.of(context)
//                                                     //     .pushNamed(
//                                                     //   Routes.restaurantInfo,
//                                                     //   arguments:
//                                                     //       RestaurantInfoPageArgs(
//                                                     //     menuId:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .menuId ??
//                                                     //             'empty',
//                                                     //     avgPrice:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .avgPrice ??
//                                                     //             0,
//                                                     //     rating:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .rate ??
//                                                     //             0,
//                                                     //     ratingCount:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .rateCount ??
//                                                     //             0,
//                                                     //     organizationId:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .organizationId ??
//                                                     //             'empty',
//                                                     //     branchId:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .id ??
//                                                     //             'empty',
//                                                     //     name:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .name ??
//                                                     //             'empty',
//                                                     //     phoneNumber:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .phoneNumber ??
//                                                     //             [],
//                                                     //     description:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .description ??
//                                                     //             'empty',
//                                                     //     photos:
//                                                     //         searchRestaurants?[
//                                                     //                     index]
//                                                     //                 .photos ??
//                                                     //             [],
//                                                     //     shiftFrom:
//                                                     //         searchRestaurants?[
//                                                     //                 index]
//                                                     //             .shiftFrom,
//                                                     //     shiftTo:
//                                                     //         searchRestaurants?[
//                                                     //                 index]
//                                                     //             .shiftTo,
//                                                     //     telegramLink:
//                                                     //         searchRestaurants?[
//                                                     //                 index]
//                                                     //             .telegramLink,
//                                                     //     instagramLink:
//                                                     //         searchRestaurants?[
//                                                     //                 index]
//                                                     //             .instagramLink,
//                                                     //     facebookLink:
//                                                     //         searchRestaurants?[
//                                                     //                 index]
//                                                     //             .facebookLink,
//                                                     //   ),
//                                                     // );
//                                                   },
//                                                 ),
//                                               );
//                                             },
//                                           );
//                                   } else {
//                                     return const SliverGap(0);
//                                   }
//                                 },
//                               ),
//                               SliverGap(bottom),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _vibrationHandler() {
//     if (_controller.size.toStringAsFixed(2) ==
//             SearchSheetStatus.max.height.toStringAsFixed(2) ||
//         _controller.size.toStringAsFixed(2) ==
//             SearchSheetStatus.initial.height.toStringAsFixed(2) ||
//         _controller.size.toStringAsFixed(2) ==
//             SearchSheetStatus.min.height.toStringAsFixed(2)) {
//       HapticFeedback.lightImpact();
//     }
//   }
// }
