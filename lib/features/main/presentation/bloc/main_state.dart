part of 'main_bloc.dart';

class MainState extends Equatable {
  final MainPages currentPage;
  final UserResponseEntity? userInfo;
  final (double lat, double long)? currentLocation;
  final MainStatus status;
  final String searchRoutes;
  final ({String? title, String? message})? errorMessage;

  const MainState({
    this.currentPage = MainPages.home,
    this.status = MainStatus.idle,
    this.userInfo,
    this.currentLocation,
    this.errorMessage,
    this.searchRoutes = Routes.search,
  });

  MainState copyWith({
    MainPages? currentPage,
    UserResponseEntity? userInfo,
    (double lat, double long)? currentLocation,
    MainStatus? status,
    String? searchRoutes,
    ({String? title, String? message})? errorMessage,
  }) {
    return MainState(
      currentPage: currentPage ?? this.currentPage,
      status: status ?? MainStatus.idle,
      userInfo: userInfo ?? this.userInfo,
      currentLocation: currentLocation ?? this.currentLocation,
      searchRoutes: searchRoutes ?? this.searchRoutes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        userInfo,
        currentLocation,
        status,
        errorMessage,
        searchRoutes,
      ];
}

enum MainStatus { idle, loading, success, error }

enum MainPages { home, subjects, diagnostics, products, profile }

// enum MainPages { subject,diagnostics,recommend,invite, chat, products, profile,ballsCoins }

extension MainStatusX on MainStatus {
  bool get isInitial => this == MainStatus.idle;

  bool get isLoading => this == MainStatus.loading;

  bool get isSuccess => this == MainStatus.success;

  bool get isError => this == MainStatus.error;
}

extension MainPagesExtension on MainPages {
  bool get isHome => this == MainPages.home;

  bool get isSubject => this == MainPages.subjects;

  bool get isDiagnostics => this == MainPages.diagnostics;

  bool get isProducts => this == MainPages.products;

  bool get isProfile => this == MainPages.profile;

  int get getIndex {
    switch (this) {
      case MainPages.home:
        return 0;
      case MainPages.subjects:
        return 1;
      case MainPages.diagnostics:
        return 2;
      case MainPages.products:
        return 3;
      case MainPages.profile:
        return 4;
    }
  }
}

extension MainPagesIndexExtension on int {
  MainPages get page {
    switch (this) {
      case 0:
        return MainPages.home;
      case 1:
        return MainPages.subjects;
      case 2:
        return MainPages.diagnostics;
      case 3:
        return MainPages.products;
      case 4:
        return MainPages.profile;
      default:
        return MainPages.home;
    }
  }
}

// extension MainPagesExtension on MainPages {
//   bool get isSubject => this == MainPages.subject;
//
//   bool get isDiagnostics => this == MainPages.diagnostics;
//
//   bool get isRecommend => this == MainPages.recommend;
//
//   bool get isInvite => this == MainPages.invite;
//
//   bool get isChat => this == MainPages.chat;
//
//   bool get isProducts => this == MainPages.products;
//
//   bool get isProfile => this == MainPages.profile;
//
//   bool get isBallsCoins => this == MainPages.ballsCoins;
//
//   int get getIndex {
//     switch (this) {
//       case MainPages.subject:
//         return 0;
//       case MainPages.diagnostics:
//         return 1;
//       case MainPages.recommend:
//         return 2;
//       case MainPages.invite:
//         return 3;
//       case MainPages.chat:
//         return 4;
//       case MainPages.products:
//         return 5;
//       case MainPages.profile:
//         return 6;
//       case MainPages.ballsCoins:
//         return 7;
//     }
//   }
// }
//
// extension MainPagesIndexExtension on int {
//   MainPages get page {
//     switch (this) {
//       case 0:
//         return MainPages.subject;
//       case 1:
//         return MainPages.diagnostics;
//       case 2:
//         return MainPages.recommend;
//       case 3:
//         return MainPages.invite;
//       case 4:
//         return MainPages.chat;
//       case 5:
//         return MainPages.products;
//       case 6:
//         return MainPages.profile;
//       case 7:
//         return MainPages.ballsCoins;
//       default:
//         return MainPages.subject;
//     }
//   }
// }
