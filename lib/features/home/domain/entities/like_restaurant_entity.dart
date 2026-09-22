import 'package:my_flutter_template/features/home/data/models/like_restaurant_request.dart';
import 'package:equatable/equatable.dart';

class LikeRestaurantEntity extends Equatable {
  const LikeRestaurantEntity({
    this.branchId,
    this.userId,
    required this.isLiked,
  });

  final String? branchId;
  final String? userId;
  final bool isLiked;

  @override
  List<Object?> get props => [branchId, userId, isLiked];
}

extension LikeRestaurantEntityX on LikeRestaurantEntity {
  LikeRestaurantRequest get toModel => LikeRestaurantRequest(
        branchId: branchId,
        userId: userId,
        isLiked: isLiked,
      );
}
