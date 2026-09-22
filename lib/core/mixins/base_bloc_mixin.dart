import 'dart:math' hide log;

import '../error/failure.dart';

mixin BaseBlocMixin {
  ({String title, String message}) getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return (
        title: failure.title,
        message: failure.message,
      );
    } else if (failure is CacheFailure) {
      return (
        title: failure.title,
        message: failure.message,
      );
    } else {
      return (
        title: 'Error',
        message: 'Unknown Error',
      );
    }
  }

  // Map<String, dynamic> getInfoOrganization(
  //     List<OrganizationRanksSubEntity> organizationRanks,
  //     double userBonusAmount) {
  //   WalletInfoStatusWidget statusWidget = WalletInfoStatusWidget.base;
  //   double cashbackPercent =
  //       organizationRanks.firstOrNull?.cashbackPercent?.toDouble() ?? 0;
  //   double currentWithdrawScores =
  //       organizationRanks.firstOrNull?.writeOffPercent?.toDouble() ?? 0;
  //   int percent = 0;
  //   organizationRanks.sort(
  //     (a, b) => a.index.compareTo(b.index),
  //   );
  //   for (OrganizationRanksSubEntity rank in organizationRanks) {
  //     if ((rank.stepAmount ?? 0) > userBonusAmount) {
  //       break;
  //     }
  //     cashbackPercent = rank.cashbackPercent?.toDouble() ?? 0;
  //     currentWithdrawScores = rank.writeOffPercent?.toDouble() ?? 0;
  //     statusWidget = rank.type.status;
  //   }
  //   var silverAmount = organizationRanks.elementAtOrNull(1)?.stepAmount ?? 1;
  //   var goldAmount = organizationRanks.lastOrNull?.stepAmount ?? 1;
  //   if (goldAmount == 0) goldAmount = 1;
  //   if (silverAmount == 0) silverAmount = 1;
  //   percent = (userBonusAmount / silverAmount * 50).toInt() +
  //       (userBonusAmount / goldAmount * 50).toInt();
  //   return {
  //     'statusWidget': statusWidget,
  //     'cashbackPercent': cashbackPercent,
  //     'currentWithdrawScores': currentWithdrawScores,
  //     'percent': percent,
  //   };
  // }

  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    // Convert degrees to radians
    lat1 = degreesToRadians(lat1);
    lon1 = degreesToRadians(lon1);
    lat2 = degreesToRadians(lat2);
    lon2 = degreesToRadians(lon2);

    // Radius of the Earth in kilometers
    double radius = 6371;

    // Haversine formula
    double dLon = lon2 - lon1;
    double dLat = lat2 - lat1;
    double a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c;

    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
