import 'package:equatable/equatable.dart';

import '../../data/models/want_restaurant_request.dart';

class WantRestaurantRequestEntity extends Equatable {
  const WantRestaurantRequestEntity({
    this.branchId,
    this.userId,
  });

  final String? branchId;
  final String? userId;

  @override
  List<Object?> get props => [
        branchId,
        userId,
      ];
}

extension WantRestaurantRequestEntityX on WantRestaurantRequestEntity {
  WantRestaurantRequest get toModel => WantRestaurantRequest(
        branchId: branchId,
        userId: userId,
      );
}
