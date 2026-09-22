// import 'dart:async';
//
// import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
// import 'package:my_flutter_template/features/search/domain/usecases/get_search_restaurants.dart';
// import 'package:my_flutter_template/router/app_routes.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:yandex_mapkit/yandex_mapkit.dart';
//
// import '../../../../injector_container.dart';
// import '../../../../services/geolocator_service.dart';
// import '../../../search/domain/entities/search_restaurants_entity.dart';
//
// part 'search_event.dart';
//
// part 'search_state.dart';
//
// class SearchBloc extends Bloc<SearchEvent, SearchState> with BaseBlocMixin {
//   final GetSearchRestaurants getSearchRestaurants;
//
//   SearchBloc({required this.getSearchRestaurants})
//       : super(const SearchState()) {
//     on<SearchSetSheetStatusEvent>(_setSheetStatusHandler);
//     on<SearchDotsIndexEvent>(_dotsIndexHandler);
//     on<SearchGetCurrentPositionEvent>(_getCurrentPositionHandler);
//     on<SearchInitializeEvent>(_initializeHandler);
//     on<SearchQueryEvent>(_searchHandler);
//   }
//
//   FutureOr<void> _initializeHandler(
//       SearchInitializeEvent event, Emitter<SearchState> emit) async {
//     emit(state.copyWith(status: SearchStatus.loading));
//     final response = await getSearchRestaurants(
//       SearchRestaurantsParams(
//         limit: 10,
//         offset: 0,
//         query: "",
//       ),
//     );
//     response.fold(
//       (failure) => emit(
//         state.copyWith(
//           errorMessage: getErrorMessage(failure),
//           status: SearchStatus.error,
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           status: SearchStatus.success,
//           initialSearchRestaurants: success.branches,
//         ),
//       ),
//     );
//   }
//
//   FutureOr<void> _searchHandler(
//     SearchQueryEvent event,
//     Emitter<SearchState> emit,
//   ) async {
//     if (event.query.length > 2) {
//       emit(state.copyWith(status: SearchStatus.loading));
//       final response = await getSearchRestaurants(
//         SearchRestaurantsParams(
//           limit: 10,
//           offset: 0,
//           query: event.query,
//         ),
//       );
//       response.fold(
//         (failure) => emit(
//           state.copyWith(
//             errorMessage: getErrorMessage(failure),
//             status: SearchStatus.error,
//           ),
//         ),
//         (success) => emit(
//           state.copyWith(
//             status: SearchStatus.success,
//             searchRestaurants: success.branches ?? [],
//           ),
//         ),
//       );
//     } else {
//       emit(
//         SearchState(
//           searchRestaurants: null,
//           initialSearchRestaurants: state.initialSearchRestaurants,
//           status: state.status,
//           errorMessage: state.errorMessage,
//         ),
//       );
//     }
//   }
//
//   FutureOr<void> _setSheetStatusHandler(
//     SearchSetSheetStatusEvent event,
//     Emitter<SearchState> emit,
//   ) {
//     print("Event size: ${event.size}");
//     if (event.size.toStringAsFixed(2) ==
//         SearchSheetStatus.initial.height.toStringAsFixed(2)) {
//       emit(
//         state.copyWith(
//           sheetStatus: SearchSheetStatus.initial,
//         ),
//       );
//     } else if (event.size.toStringAsFixed(2) ==
//         SearchSheetStatus.max.height.toStringAsFixed(2)) {
//       emit(
//         state.copyWith(
//           sheetStatus: SearchSheetStatus.max,
//         ),
//       );
//     } else if (event.size.toStringAsFixed(2) ==
//         SearchSheetStatus.min.height.toStringAsFixed(2)) {
//       emit(
//         state.copyWith(
//           sheetStatus: SearchSheetStatus.min,
//         ),
//       );
//     }
//   }
//
//   FutureOr<void> _dotsIndexHandler(
//     SearchDotsIndexEvent event,
//     Emitter<SearchState> emit,
//   ) {
//     emit(state.copyWith(dotsIndex: event.index));
//   }
//
//   FutureOr<void> _getCurrentPositionHandler(
//       SearchGetCurrentPositionEvent event, Emitter<SearchState> emit) async {
//     final currentPosition = await sl<GeoLocatorService>().getCurrentPosition();
//     currentPosition.fold(
//       (failure) => emit(
//         state.copyWith(
//           status: SearchStatus.error,
//           errorMessage: (title: 'Attention', message: failure),
//         ),
//       ),
//       (success) => emit(
//         state.copyWith(
//           currentPoint: Point(
//             latitude: success.latitude,
//             longitude: success.longitude,
//           ),
//         ),
//       ),
//     );
//   }
// }
