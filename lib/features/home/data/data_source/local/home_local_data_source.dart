import 'package:my_flutter_template/features/home/data/models/product_response.dart';

abstract class HomeLocalDataSource {
  Future<ProductResponse> getProductList(num id);
  Future<void> setProductList(ProductResponse productResponse, num id);
}
