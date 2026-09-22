// part of 'search_bloc.dart';
//
// class SearchState extends Equatable {
//   final SearchSheetStatus sheetStatus;
//   final Point? currentPoint;
//   final int dotsIndex;
//   final SearchStatus status;
//   final List<BranchSubEntity>? searchRestaurants;
//   final List<BranchSubEntity>? initialSearchRestaurants;
//   final ({String title, String message})? errorMessage;
//
//   const SearchState({
//     this.sheetStatus = SearchSheetStatus.initial,
//     this.dotsIndex = 0,
//     this.status = SearchStatus.idle,
//     this.currentPoint,
//     this.initialSearchRestaurants,
//     this.searchRestaurants,
//     this.errorMessage,
//   });
//
//   SearchState copyWith({
//     SearchSheetStatus? sheetStatus,
//     Point? currentPoint,
//     SearchStatus? status,
//     int? dotsIndex,
//     List<BranchSubEntity>? searchRestaurants,
//     List<BranchSubEntity>? initialSearchRestaurants,
//     ({String title, String message})? errorMessage,
//   }) {
//     return SearchState(
//       sheetStatus: sheetStatus ?? this.sheetStatus,
//       currentPoint: currentPoint ?? this.currentPoint,
//       status: status ?? SearchStatus.idle,
//       dotsIndex: dotsIndex ?? this.dotsIndex,
//       searchRestaurants: searchRestaurants ?? this.searchRestaurants,
//       initialSearchRestaurants:
//           initialSearchRestaurants ?? this.initialSearchRestaurants,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         sheetStatus,
//         dotsIndex,
//         currentPoint,
//         status,
//         errorMessage,
//         searchRestaurants,
//         initialSearchRestaurants,
//       ];
// }
//
// enum SearchStatus { idle, loading, success, error }
//
// enum SearchSheetStatus { initial, min, max }
//
// extension SearchStatusX on SearchStatus {
//   bool get isIdle => this == SearchStatus.idle;
//
//   bool get isLoading => this == SearchStatus.loading;
//
//   bool get isSuccess => this == SearchStatus.success;
//
//   bool get isError => this == SearchStatus.error;
// }
//
// extension SearchSheetStatusX on SearchSheetStatus {
//   bool get isInitial => this == SearchSheetStatus.initial;
//
//   bool get isMin => this == SearchSheetStatus.min;
//
//   bool get isMax => this == SearchSheetStatus.max;
//
//   double get height {
//     final size = MediaQuery.of(mainRootNavigatorKey.currentContext!).size;
//     switch (this) {
//       case SearchSheetStatus.initial:
//         return size.height > 700 ? 0.40 : 0.46;
//       case SearchSheetStatus.min:
//         return 0.17;
//       case SearchSheetStatus.max:
//         return 1;
//     }
//   }
// }
