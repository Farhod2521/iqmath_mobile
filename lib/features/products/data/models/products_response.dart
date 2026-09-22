class Product {
  final int id;
  final String name;
  final int coin;
  final int count;
  final double priceMoney;
  final double priceScore;
  final String? imageUrl;
  final String? nameRu;

  Product({
    required this.id,
    required this.name,
    required this.coin,
    required this.count,
    required this.priceMoney,
    required this.priceScore,
    this.imageUrl,
    required this.nameRu,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name_uz'] ?? json['name_ru'] ?? 'No name',
      coin: json['coin'] ?? 0,
      count: json['count'] ?? 0,
      priceMoney: (json['price_money'] ?? 0.0).toDouble(),
      priceScore: (json['price_score'] ?? 0.0).toDouble(),
      imageUrl: json['image'],
      nameRu: json['name_ru'],
    );
  }
}