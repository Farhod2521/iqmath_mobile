import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_template/features/products/data/models/products_response.dart';
import 'package:my_flutter_template/injector_container.dart';

import '../../../../../../core/local_source/local_source.dart';
import '../../../../../../generated/assets.dart';

class ProductsSectionWidget extends StatefulWidget {
  const ProductsSectionWidget({super.key});

  @override
  State<ProductsSectionWidget> createState() => _ProductsSectionWidgetState();
}

class _ProductsSectionWidgetState extends State<ProductsSectionWidget> {
  List<Product> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      var token = sl<LocalSource>().getAccessToken();

      final headers = {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/management/products/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        setState(() {
          _products = productsJson
              .map((json) => Product.fromJson(json))
              .take(4)
              .toList();
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: 16),
        _buildProductsList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Mahsulotlar",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Barcha mahsulotlarni ko'rish
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF4FC3F7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hammasini ko'rish",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4FC3F7),
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  CupertinoIcons.arrow_right,
                  size: 14,
                  color: Color(0xFF4FC3F7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    if (_isLoadingProducts) {
      return SizedBox(
        height: 260,
        child: Center(
          child: CupertinoActivityIndicator(radius: 20),
        ),
      );
    }

    if (_products.isEmpty) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.cube_box,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                "Mahsulotlar topilmadi",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 4),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return Container(
            width: 170,
            margin: EdgeInsets.only(
              right: index == _products.length - 1 ? 0 : 12,
            ),
            child: ProductCard(product: _products[index]),
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.count == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(isOutOfStock),
          _buildProductInfo(isOutOfStock),
        ],
      ),
    );
  }

  Widget _buildProductImage(bool isOutOfStock) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              product.imageUrl ?? '',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    CupertinoIcons.cube_box,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            if (isOutOfStock)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text(
                    'Sotuvda yo\'q',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(bool isOutOfStock) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mahsulot nomi
            Text(
              product.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isOutOfStock ? Colors.grey : Color(0xFF2D3748),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),

            // Tanga qatori
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        Assets.svgCoins,
                        width: 16,
                        height: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '1 dona',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${product.coin}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4),

            // Omborda qatori
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.cube_box,
                        size: 16,
                        color: Color(0xFF8E8E93),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Omborda',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isOutOfStock ? 'Tugagan' : '${product.count} ta',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          isOutOfStock ? Color(0xFFFF3B30) : Color(0xFF34C759),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
