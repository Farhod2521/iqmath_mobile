import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:my_flutter_template/constants/constants.dart';
import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/features/home/data/data_source/local/home_local_data_source.dart';
import 'package:my_flutter_template/features/home/data/models/product_response.dart';

const errorMessage = "No such data in Database";
const misMatchingId = "Ids do not match";

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final Box<dynamic> box;

  const HomeLocalDataSourceImpl(this.box);

  @override
  Future<ProductResponse> getProductList(num id) async {
    final productJson = await box.get(
      DatabaseKeys.PRODUCT_LIST + id.toString(),
      defaultValue: null,
    );
    if (productJson != null) {
      final product = ProductResponse.fromJson(jsonDecode(productJson));
      if (product.skip == id) {
        return product;
      } else {
        throw CacheException(
            message: misMatchingId, title: "Product ID Mismatch");
      }
    } else {
      throw CacheException(message: errorMessage, title: "Product Not Found");
    }
  }

  @override
  Future<void> setProductList(ProductResponse productResponse, num id) async {
    final productJson = jsonEncode(productResponse.toJson());
    await box.put(DatabaseKeys.PRODUCT_LIST + id.toString(), productJson);
  }
}
