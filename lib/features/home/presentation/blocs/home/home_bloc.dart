import 'dart:async';

import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/features/home/data/models/product_response.dart';
import 'package:my_flutter_template/features/home/domain/entities/banners_response_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/features/home/domain/usecases/get_products_usecase.dart';

import '../../../domain/entities/get_all_branches_entity.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> with BaseBlocMixin {
  final GetProductsUseCase getProductsUseCase;

  HomeBloc({
    required this.getProductsUseCase,
  }) : super(const HomeState()) {
    on<HomeGetProductsEvent>(_getProductsHandler);
  }

  FutureOr<void> _getProductsHandler(
      HomeGetProductsEvent event,
      Emitter<HomeState> emit,
      ) async {
    final isInitialLoad = event.skip == 0;

    if (isInitialLoad) {
      emit(state.copyWith(status: HomeStatus.loading));

      // 1. Cached productsni ko‘rsatish (agar mavjud bo‘lsa)
      await getCachedProducts(emit, event.skip ?? 0);
    } else {
      emit(state.copyWith(isPaginating: true));
    }

    // 2. Har doim networkdan keyin yangilaymiz
    await getProductsNetwork(emit, event.skip ?? 0, event.limit ?? 10);
  }


  Future<void> getProductsNetwork(
      Emitter<HomeState> emit,
      int skip,
      int limit,
      ) async {
    final response = await getProductsUseCase(Params(limit, skip));

    response.fold(
          (error) {
        emit(
          state.copyWith(
            status: HomeStatus.error,
            errorMessage: getErrorMessage(error),
            isPaginating: false,
          ),
        );
      },
          (data) {
        final isFirstPage = skip == 0;
        final existingProducts = state.products?.products ?? [];

        final updatedProducts = isFirstPage
            ? data.products
            : [...existingProducts, ...?data.products];

        emit(
          state.copyWith(
            status: HomeStatus.success,
            products: data.copyWith(products: updatedProducts),
            isPaginating: false,
          ),
        );
      },
    );
  }


  Future<ProductResponse?> getCachedProducts(
      Emitter<HomeState> emit,
      int skip,
      ) async {
    final response = await getProductsUseCase(
      Params(0, skip, isCache: true),
    );
    return response.fold(
          (error) => null, // Error bo‘lsa hech narsa qilmaymiz
          (data) {
        // Keshdan kelgan datani darhol emit qilamiz
        emit(
          state.copyWith(
            status: HomeStatus.success,
            products: data,
          ),
        );
        return data;
      },
    );
  }


}
