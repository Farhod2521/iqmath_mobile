part of 'home_bloc.dart';

class HomeState extends Equatable {
  final HomeStatus status;
  final List<BranchSubEntity>? branches;
  final List<BannersSubEntity>? banners;
  final ({String title, String message})? errorMessage;
  final bool forceUpdate;
  final ProductResponse? products;
  final bool isPaginating;

  const HomeState({
    this.branches,
    this.status = HomeStatus.idle,
    this.errorMessage,
    this.banners,
    this.forceUpdate = false,
    this.products,
    this.isPaginating = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<BranchSubEntity>? branches,
    List<BannersSubEntity>? banners,
    ({String title, String message})? errorMessage,
    bool? forceUpdate,
    ProductResponse? products,
    bool? isPaginating,
  }) {
    return HomeState(
      status: status ?? HomeStatus.idle,
      branches: branches ?? this.branches,
      banners: banners ?? this.banners,
      errorMessage: errorMessage ?? this.errorMessage,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      products: products ?? this.products,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }

  @override
  List<Object?> get props => [
        status,
        branches,
        errorMessage,
        forceUpdate,
        banners,
        products,
        isPaginating,
      ];
}

enum HomeStatus { idle, loading, success, error }

extension HomeStatusX on HomeStatus {
  bool get isIdle => this == HomeStatus.idle;

  bool get isLoading => this == HomeStatus.loading;

  bool get isSuccess => this == HomeStatus.success;

  bool get isError => this == HomeStatus.error;
}
