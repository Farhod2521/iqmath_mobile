import 'package:my_flutter_template/features/search/data/models/search_restaurants_response.dart';

class SearchRestaurantsEntity {
  List<BranchSubEntity>? branches;
  int? count;

  SearchRestaurantsEntity({
    this.branches,
    this.count,
  });
}

class BranchSubEntity {
  String? id;
  String? name;
  List<String>? phoneNumber;
  String? description;
  String? telegramLink;
  String? facebookLink;
  String? instagramLink;
  String? organizationId;
  double? lat;
  double? long;
  String? shiftFrom;
  String? shiftTo;
  List<String>? photos;
  String? menuId;
  num? rate;
  num? rateCount;
  bool isLiked;
  String? address;
  bool? isLinked;
  num? avgPrice;

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
    this.isLinked,
    this.avgPrice,
  });
}

extension SearchRestaurantsResponseX on SearchRestaurantsResponse {
  SearchRestaurantsEntity toEntity() {
    return SearchRestaurantsEntity(
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
              isLiked: branch.isFavorite ?? false,
              isLinked: branch.isLinked,
              avgPrice: branch.avgPrice,
            ),
          )
          .toList(),
      count: count?.toInt(),
    );
  }
}
