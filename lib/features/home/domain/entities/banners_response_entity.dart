import 'package:my_flutter_template/features/home/data/models/banners_response.dart';
import 'package:equatable/equatable.dart';

class BannersResponseEntity extends Equatable {
  final List<BannersSubEntity>? banners;

  const BannersResponseEntity({this.banners});

  @override
  List<Object?> get props => [banners];
}

class BannersSubEntity extends Equatable {
  final String? branchId;
  final String? id;
  final String? imageUrl;
  final bool? isActive;
  final String? productId;
  final String? title;

  const BannersSubEntity(
      {this.branchId,
      this.id,
      this.imageUrl,
      this.isActive,
      this.productId,
      this.title});

  @override
  List<Object?> get props => [
        branchId,
        id,
        imageUrl,
        isActive,
        productId,
        title,
      ];
}

extension BannersResponseX on BannersResponse {
  BannersResponseEntity get toEntity => BannersResponseEntity(
        banners: banners
            ?.map(
              (e) => BannersSubEntity(
                branchId: e.branchId,
                id: e.id,
                imageUrl: e.imageUrl,
                isActive: e.isActive,
                productId: e.productId,
                title: e.title,
              ),
            )
            .toList(),
      );
}
