import 'package:my_flutter_template/features/home/data/models/get_single_branch_response.dart';
import 'package:equatable/equatable.dart';

class GetSingleBranchEntity extends Equatable {
  GetSingleBranchEntity({
    this.id,
    this.name,
    this.organizationId,
    this.phoneNumber,
    this.description,
    this.long,
    this.lat,
    this.photos,
    this.instagramLink,
    this.facebookLink,
    this.telegramLink,
    this.shiftFrom,
    this.shiftTo,
    this.menuId,
    this.tags,
    this.userBonusAmount,
    this.userBonusAmountTotal,
    this.isFavorite = false,
    this.isLinked = false,
    this.rate,
    this.rateCount,
    this.avgPrice,
  });

  final String? id;
  final String? name;
  final String? organizationId;
  final List<String>? phoneNumber;
  final String? description;
  final num? long;
  final num? lat;
  final List<String>? photos;
  final String? instagramLink;
  final String? facebookLink;
  final String? telegramLink;
  final String? shiftFrom;
  final String? shiftTo;
  final String? menuId;
  final dynamic tags;
  final num? userBonusAmount;
  final num? userBonusAmountTotal;
  bool isFavorite;
  final bool isLinked;
  final num? rate;
  final num? rateCount;
  final num? avgPrice;

  @override
  List<Object?> get props => [
        id,
        name,
        organizationId,
        phoneNumber,
        description,
        long,
        lat,
        photos,
        instagramLink,
        facebookLink,
        telegramLink,
        shiftFrom,
        shiftTo,
        menuId,
        tags,
        userBonusAmount,
        userBonusAmountTotal,
        isFavorite,
        isLinked,
        rate,
        rateCount,
        avgPrice,
      ];
}

extension GetSingleBranchEntityX on GetSingleBranchResponse {
  GetSingleBranchEntity get toEntity => GetSingleBranchEntity(
        organizationId: organizationId,
        phoneNumber: phoneNumber,
        description: description,
        long: long,
        lat: lat,
        photos: photos,
        instagramLink: instagramLink,
        facebookLink: facebookLink,
        telegramLink: telegramLink,
        shiftFrom: shiftFrom,
        shiftTo: shiftTo,
        menuId: menuId,
        tags: tags,
        userBonusAmount: userBonusAmount,
        userBonusAmountTotal: userBonusAmountTotal,
        id: id,
        name: name,
        isFavorite: isFavorite ?? false,
        isLinked: isLinked ?? false,
        rate: rate,
        rateCount: rateCount,
        avgPrice: avgPrice,
      );
}
