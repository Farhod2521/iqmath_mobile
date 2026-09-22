import 'package:my_flutter_template/features/home/data/models/get_all_branches_response.dart';
import 'package:equatable/equatable.dart';

class GetAllBranchesEntity extends Equatable {
  final List<BranchSubEntity>? branches;
  final int? count;

  const GetAllBranchesEntity({
    this.branches,
    this.count,
  });

  @override
  List<Object?> get props => [branches, count];
}

class BranchSubEntity extends Equatable {
  final String? id;
  final String? name;
  final List<String>? phoneNumber;
  final String? description;
  final String? telegramLink;
  final String? facebookLink;
  final String? instagramLink;
  final double? lat;
  final double? long;
  final String? shiftFrom;
  final String? shiftTo;
  final List<String>? photos;
  final String? menuId;
  final String? organizationId;
  final num? rate;
  final num? rateCount;
  final String? address;
  bool isLiked;
  bool isLinked;
  final num? avgPrice;

  BranchSubEntity({
    this.id,
    this.name,
    this.phoneNumber,
    this.description,
    this.telegramLink,
    this.facebookLink,
    this.instagramLink,
    this.lat,
    this.long,
    this.photos,
    this.shiftFrom,
    this.shiftTo,
    this.isLiked = false,
    this.menuId,
    this.organizationId,
    this.rate,
    this.rateCount,
    this.address,
    this.isLinked = false,
    this.avgPrice,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        description,
        telegramLink,
        facebookLink,
        instagramLink,
        lat,
        long,
        photos,
        shiftFrom,
        shiftTo,
        isLiked,
        menuId,
        organizationId,
        rate,
        rateCount,
        address,
        isLinked,
        avgPrice,
      ];
}

extension GetAllBranchesResponseX on GetAllBranchesResponse {
  GetAllBranchesEntity toEntity() {
    return GetAllBranchesEntity(
      branches: branches
          ?.map(
            (branch) => BranchSubEntity(
              description: branch.description,
              facebookLink: branch.facebookLink,
              id: branch.id,
              instagramLink: branch.instagramLink,
              lat: branch.lat?.toDouble(),
              long: branch.long?.toDouble(),
              name: branch.name,
              phoneNumber: branch.phoneNumber,
              photos: branch.photos,
              shiftFrom: branch.shiftFrom,
              shiftTo: branch.shiftTo,
              telegramLink: branch.telegramLink,
              menuId: branch.menuId,
              organizationId: branch.organizationId,
              rate: branch.rate,
              rateCount: branch.rateCount,
              address: branch.address,
              isLiked: branch.isFavourite ?? false,
              isLinked: branch.isLinked ?? false,
              avgPrice: branch.avgPrice,
            ),
          )
          .toList(),
      count: count?.toInt(),
    );
  }
}
