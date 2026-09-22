// // Model class for subscription plans
// class SubscriptionPlan {
//   final int id;
//   final int months;
//   final String getMonthsDisplay;
//   final int discountPercent;
//   final String pricePerMonth;
//   final double salePrice;
//   final bool isActive;
//
//   SubscriptionPlan({
//     required this.id,
//     required this.months,
//     required this.getMonthsDisplay,
//     required this.discountPercent,
//     required this.pricePerMonth,
//     required this.salePrice,
//     required this.isActive,
//   });
//
//   factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
//     return SubscriptionPlan(
//       id: json['id'],
//       months: json['months'],
//       getMonthsDisplay: json['get_months_display'],
//       discountPercent: json['discount_percent'],
//       pricePerMonth: json['price_per_month'],
//       salePrice: json['sale_price'].toDouble(),
//       isActive: json['is_active'],
//     );
//   }
//
//   // Format price with thousand separators
//   String getFormattedSalePrice() {
//     return salePrice.toInt().toString().replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]},',
//     );
//   }
//
//   String getFormattedPricePerMonth() {
//     final price = double.parse(pricePerMonth).toInt();
//     return price.toString().replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]},',
//     );
//   }
// }


// class SubscriptionPlan {
//   final int id;
//   final String name;
//   final PlanCategory? category;
//   final int months;
//   final String monthsDisplay;
//   final int discountPercent;
//   final String pricePerMonth;
//   final double salePrice;
//   final List<Benefit> benefits;
//   final bool isActive;
//   final String createdAt;
//   final String updatedAt;
//
//   SubscriptionPlan({
//     required this.id,
//     required this.name,
//     this.category,
//     required this.months,
//     required this.monthsDisplay,
//     required this.discountPercent,
//     required this.pricePerMonth,
//     required this.salePrice,
//     required this.benefits,
//     required this.isActive,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
//     return SubscriptionPlan(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       category: json['category'] != null
//           ? PlanCategory.fromJson(json['category'] as Map<String, dynamic>)
//           : null,
//       months: json['months'] as int,
//       monthsDisplay: json['months_display'] as String,
//       discountPercent: json['discount_percent'] as int,
//       pricePerMonth: json['price_per_month'] as String,
//       salePrice: (json['sale_price'] as num).toDouble(),
//       benefits: (json['benefits'] as List<dynamic>)
//           .map((e) => Benefit.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       isActive: json['is_active'] as bool,
//       createdAt: json['created_at'] as String,
//       updatedAt: json['updated_at'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'category': category?.toJson(),
//       'months': months,
//       'months_display': monthsDisplay,
//       'discount_percent': discountPercent,
//       'price_per_month': pricePerMonth,
//       'sale_price': salePrice,
//       'benefits': benefits.map((e) => e.toJson()).toList(),
//       'is_active': isActive,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
//
//   String get getMonthsDisplay => monthsDisplay;
//
//   String getFormattedSalePrice() {
//     return salePrice.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]} ',
//     );
//   }
//
//   // Original narx (chizilgan narx) - price_per_month
//   String getFormattedOriginalPrice() {
//     double price = double.parse(pricePerMonth);
//     return price.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]} ',
//     );
//   }
//
//   // // Format price with thousand separators
//   // String getFormattedSalePrice() {
//   //   return salePrice.toInt().toString().replaceAllMapped(
//   //     RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//   //         (Match m) => '${m[1]},',
//   //   );
//   // }
//
//   String getFormattedPricePerMonth() {
//     final price = double.parse(pricePerMonth).toInt();
//     return price.toString().replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]},',
//     );
//   }
// }
//
// class PlanCategory {
//   final int id;
//   final String titleUz;
//   final String titleRu;
//
//   PlanCategory({
//     required this.id,
//     required this.titleUz,
//     required this.titleRu,
//   });
//
//   factory PlanCategory.fromJson(Map<String, dynamic> json) {
//     return PlanCategory(
//       id: json['id'] as int,
//       titleUz: json['title_uz'] as String,
//       titleRu: json['title_ru'] as String,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title_uz': titleUz,
//       'title_ru': titleRu,
//     };
//   }
// }
//
// class Benefit {
//   final int id;
//   final String titleUz;
//   final String titleRu;
//   final String description;
//   final bool isSelected;
//
//   Benefit({
//     required this.id,
//     required this.titleUz,
//     required this.titleRu,
//     required this.description,
//     required this.isSelected,
//   });
//
//   factory Benefit.fromJson(Map<String, dynamic> json) {
//     return Benefit(
//       id: json['id'] as int,
//       titleUz: json['title_uz'] as String,
//       titleRu: json['title_ru'] as String,
//       description: json['description'] as String,
//       isSelected: json['is_selected'] as bool,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title_uz': titleUz,
//       'title_ru': titleRu,
//       'description': description,
//       'is_selected': isSelected,
//     };
//   }
// }