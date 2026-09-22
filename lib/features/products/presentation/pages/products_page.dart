// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_null_comparison
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'dart:convert';

import '../../../../core/local_source/local_source.dart';
import '../../../../generated/assets.dart';
import '../../../../injector_container.dart';
import '../../data/models/products_response.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  List<Product> _allProducts = [];
  List<Product> _purchasedProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  late ProductsLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _updateLocalizations(String locale) {
    _localizations = ProductsLocalizations(locale);
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var token = sl<LocalSource>().getAccessToken();

      final headers = {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      };

      final allProductsResponse = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/management/products/'),
        headers: headers,
      );

      final purchasedProductsResponse = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/my-products/exchange/list/'),
        headers: headers,
      );

      alice.onHttpResponse(allProductsResponse);
      alice.onHttpResponse(purchasedProductsResponse);

      if (allProductsResponse.statusCode == 200) {
        final List<dynamic> allProductsJson =
            json.decode(allProductsResponse.body);
        final tempAllProducts =
            allProductsJson.map((json) => Product.fromJson(json)).toList();

        if (purchasedProductsResponse.statusCode == 200) {
          final Map<String, dynamic> purchasedData =
              json.decode(purchasedProductsResponse.body);
          final List<dynamic> exchangesJson = purchasedData['exchanges'] ?? [];
          final tempPurchasedProducts =
              exchangesJson.map((json) => Product.fromJson(json)).toList();

          setState(() {
            _allProducts = tempAllProducts;
            _purchasedProducts = tempPurchasedProducts;
            _isLoading = false;
          });
        } else {
          setState(() {
            _allProducts = tempAllProducts;
            _purchasedProducts = [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception(
            _localizations.fetchError(allProductsResponse.statusCode));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _localizations.errorMessage(e.toString());
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showPurchaseDialog(Product product) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildWarningIcon(),
                      SizedBox(height: 20),
                      _buildDialogTitle(),
                      SizedBox(height: 24),
                      _buildProductInfoCard(product),
                      SizedBox(height: 24),
                      _buildDialogActions(product),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFFFFF9E6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        CupertinoIcons.exclamationmark_triangle_fill,
        size: 42,
        color: Color(0xFFFFB800),
      ),
    );
  }

  Widget _buildDialogTitle() {
    return Text(
      _localizations.purchaseConfirmTitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1C1C1E),
        height: 1.4,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildProductInfoCard(Product product) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildProductImage(product),
          SizedBox(width: 16),
          _buildPriceBadge(product),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        product.imageUrl ?? '',
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.device_laptop,
              size: 32,
              color: CupertinoColors.systemGrey2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceBadge(Product product) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            Assets.svgCoins,
            height: 20,
            width: 20,
          ),
          SizedBox(width: 6),
          Text(
            '${product.coin} ${_localizations.coins}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF007AFF),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions(Product product) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.symmetric(vertical: 14),
            color: Color(0xFFE5E5EA),
            borderRadius: BorderRadius.circular(14),
            onPressed: () => Navigator.of(mainRootNavigatorKey.currentContext!).pop(),
            child: Text(
              _localizations.cancelButton,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.symmetric(vertical: 14),
            color: Color(0xFF34C759),
            borderRadius: BorderRadius.circular(14),
            onPressed: () {
              Navigator.of(context).pop();
              _purchaseProduct(product);
            },
            child: Text(
              _localizations.confirmButton,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _purchaseProduct(Product product) async {
    try {
      var token = sl<LocalSource>().getAccessToken();
      final headers = {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/my-products/exchange/${product.id}/'),
        headers: headers,
      );

      alice.onHttpResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
        _fetchProducts();
      } else {
        final data = json.decode(response.body);
        _showErrorDialog(data['error_uz'] ?? data['error']);
      }
    } catch (e) {
      _showErrorDialog(_localizations.errorMessage(e.toString()));
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(_localizations.successTitle),
        content: Text(_localizations.successMessage),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizations.okButton),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(_localizations.errorTitle),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizations.okButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        _updateLocalizations(state.appLocale ?? 'uz');

        return CupertinoPageScaffold(
          backgroundColor: Color(0xFFF8F9FA),
          navigationBar: _buildNavigationBar(),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _buildCustomTabBar(),
                ),
                Gap(16),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(radius: 20))
                      : _errorMessage != null
                          ? _buildErrorView()
                          : IndexedStack(
                              index: _currentIndex,
                              children: [
                                _buildProductList(_allProducts, 0),
                                _buildProductList(_purchasedProducts, 1),
                              ],
                            ),
                ),
                Gap(32),
              ],
            ),
          ),
        );
      },
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      backgroundColor: CupertinoColors.white,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap(4),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF007AFF),
                  Color(0xFF5856D6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF007AFF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              CupertinoIcons.shopping_cart,
              color: CupertinoColors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Text(
            _localizations.pageTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.black,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size(double.infinity, 8),
        child: SizedBox.shrink(),
      ),
      border: Border(
        bottom: BorderSide(
          color: CupertinoColors.systemGrey5,
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? _localizations.errorOccurred,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: _fetchProducts,
              child: Text(_localizations.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildTabIndicator(),
          _buildTabButtons(),
        ],
      ),
    );
  }

  Widget _buildTabIndicator() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: _currentIndex == 0 ? 4 : MediaQuery.of(context).size.width / 2 - 20,
      right:
          _currentIndex == 1 ? 4 : MediaQuery.of(context).size.width / 2 - 20,
      top: 4,
      bottom: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007AFF),
              Color(0xFF5856D6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF007AFF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        _buildTabButton(0, _localizations.allProductsTab),
        _buildTabButton(1, _localizations.purchasedTab),
      ],
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.translucent,
        child: Container(
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? CupertinoColors.white
                  : CupertinoColors.systemGrey,
              decoration: TextDecoration.none,
              letterSpacing: 0.2,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> products, int tabIndex) {
    if (products.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return CustomScrollView(
      key: PageStorageKey<int>(tabIndex),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _fetchProducts,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == products.length - 1 ? 20 : 12,
                ),
                child: ProductCard(
                  product: products[index],
                  localizations: _localizations,
                  onPurchase: () => _showPurchaseDialog(products[index]),
                ),
              ),
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    return CustomScrollView(
      key: PageStorageKey<int>(tabIndex),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _fetchProducts,
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.cube_box,
                    size: 48,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tabIndex == 0
                      ? _localizations.noProductsFound
                      : _localizations.noPurchasedProducts,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductsLocalizations localizations;
  final VoidCallback onPurchase;

  const ProductCard({
    super.key,
    required this.product,
    required this.localizations,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.count == 0;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProductImage(isOutOfStock),
          Expanded(
            child: _buildProductDetails(isOutOfStock),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(bool isOutOfStock) {
    return Container(
      width: 150,
      height: 180,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
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
                  color: Color(0xFFF5F5F7),
                  child: const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Color(0xFFF5F5F7),
                  child: const Icon(
                    CupertinoIcons.device_laptop,
                    size: 48,
                    color: Color(0xFFD1D1D6),
                  ),
                );
              },
            ),
            if (isOutOfStock) _buildOutOfStockOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutOfStockOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.75),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.xmark_circle_fill,
              color: CupertinoColors.white,
              size: 28,
            ),
            SizedBox(height: 6),
            Text(
              localizations.notAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(bool isOutOfStock) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildProductName(isOutOfStock),
          const SizedBox(height: 8),
          _buildPriceRow(),
          const SizedBox(height: 6),
          _buildStockRow(isOutOfStock),
          const SizedBox(height: 8),
          _buildPurchaseButton(isOutOfStock),
        ],
      ),
    );
  }

  Widget _buildProductName(bool isOutOfStock) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Text(
          BaseFunctions.getLanguageText(
            languageCode: state.appLocale,
            uz: product.name,
            ru: product.nameRu,
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isOutOfStock ? CupertinoColors.systemGrey : Color(0xFF1C1C1E),
            decoration: TextDecoration.none,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _buildPriceRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                Assets.svgCoins,
                height: 20,
                width: 20,
              ),
              const SizedBox(width: 6),
              Text(
                localizations.oneItem,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E8E93),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Text(
            '${product.coin} ${localizations.coins}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1E),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow(bool isOutOfStock) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.cube_box,
                size: 20,
                color: Color(0xFF8E8E93),
              ),
              const SizedBox(width: 6),
              Text(
                localizations.inStock,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E8E93),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Gap(2),
          Text(
            isOutOfStock
                ? localizations.outOfStock
                : '${product.count} ${localizations.pieces}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isOutOfStock ? Color(0xFFFF3B30) : Color(0xFF34C759),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(bool isOutOfStock) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        onPressed: isOutOfStock ? null : onPurchase,
        child: Container(
          width: double.infinity,
          height: 38,
          decoration: BoxDecoration(
            gradient: isOutOfStock
                ? null
                : LinearGradient(
                    colors: [
                      Color(0xFF5E8AFF),
                      Color(0xFF4F75FE),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            color: isOutOfStock ? Color(0xFFF2F2F7) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              localizations.buyButton,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isOutOfStock ? Color(0xFFAEAEB2) : CupertinoColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductsApiService {
  static const String _baseUrl = 'https://api.iqmath.uz/api/v1';

  final String Function() _getToken;
  final void Function(http.Response) _logResponse;

  ProductsApiService({
    required String Function() getToken,
    required void Function(http.Response) logResponse,
  })  : _getToken = getToken,
        _logResponse = logResponse;

  Map<String, String> get _headers => {
        'Authorization': _getToken(),
        'Content-Type': 'application/json',
      };

  Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/management/products/'),
        headers: _headers,
      );
      alice.onHttpResponse(response);
      _logResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ProductsApiException(
          'Failed to fetch products',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ProductsApiException) rethrow;
      throw ProductsApiException('Network error: $e', null);
    }
  }

  Future<List<Product>> fetchPurchasedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/func_student/my-products/exchange/list/'),
        headers: _headers,
      );

      _logResponse(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> exchanges = data['exchanges'] ?? [];
        return exchanges.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ProductsApiException(
          'Failed to fetch purchased products',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ProductsApiException) rethrow;
      throw ProductsApiException('Network error: $e', null);
    }
  }

  Future<PurchaseResult> purchaseProduct(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/func_student/my-products/exchange/$productId/'),
        headers: _headers,
      );

      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PurchaseResult(success: true);
      } else {
        final data = json.decode(response.body);
        final errorMessage =
            data['error_uz'] ?? data['error'] ?? 'Unknown error';
        return PurchaseResult(
          success: false,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      return PurchaseResult(
        success: false,
        errorMessage: 'Network error: $e',
      );
    }
  }
}

class ProductsApiException implements Exception {
  final String message;
  final int? statusCode;

  ProductsApiException(this.message, this.statusCode);

  @override
  String toString() => 'ProductsApiException: $message (Status: $statusCode)';
}

class PurchaseResult {
  final bool success;
  final String? errorMessage;

  PurchaseResult({
    required this.success,
    this.errorMessage,
  });
}

// lib/features/products/presentation/localizations/products_localizations.dart

class ProductsLocalizations {
  final String locale;

  ProductsLocalizations(this.locale);

  // Navigation Bar
  String get pageTitle => locale == 'uz' ? 'MAHSULOTLAR' : 'ПРОДУКТЫ';

  // Tab Bar
  String get allProductsTab =>
      locale == 'uz' ? 'Barcha mahsulotlar' : 'Все продукты';

  String get purchasedTab => locale == 'uz' ? 'Harid qilingan' : 'Купленные';

  // Product Card
  String get oneItem => locale == 'uz' ? '1 dona' : '1 шт';

  String get coins => locale == 'uz' ? 'Tanga' : 'Монета';

  String get inStock => locale == 'uz' ? 'Omborda' : 'На складе';

  String get outOfStock => locale == 'uz' ? '0 dona' : '0 шт';

  String get notAvailable =>
      locale == 'uz' ? 'Sotuvda\nyo\'q' : 'Нет в\nналичии';

  String get pieces => locale == 'uz' ? 'ta' : 'шт';

  String get buyButton => locale == 'uz' ? 'Sotib olish' : 'Купить';

  // Purchase Dialog
  String get purchaseConfirmTitle => locale == 'uz'
      ? 'Ushbu mahsulotni sotib olishni\nxohlaysizmi?'
      : 'Вы хотите купить\nэтот товар?';

  String get cancelButton => locale == 'uz' ? 'Bekor qilish' : 'Отмена';

  String get confirmButton => locale == 'uz' ? 'Ha, sotib olaman' : 'Да, куплю';

  // Success/Error Dialogs
  String get successTitle => locale == 'uz' ? 'Muvaffaqiyatli!' : 'Успешно!';

  String get successMessage => locale == 'uz'
      ? 'Mahsulot muvaffaqiyatli sotib olindi'
      : 'Товар успешно куплен';

  String get errorTitle => locale == 'uz' ? 'Xatolik' : 'Ошибка';

  String get okButton => locale == 'uz' ? 'OK' : 'ОК';

  // Empty States
  String get noProductsFound =>
      locale == 'uz' ? 'Mahsulotlar topilmadi' : 'Товары не найдены';

  String get noPurchasedProducts => locale == 'uz'
      ? 'Hali sotib olingan mahsulot yo\'q'
      : 'Пока нет купленных товаров';

  // Error Messages
  String get errorOccurred =>
      locale == 'uz' ? 'Xatolik yuz berdi' : 'Произошла ошибка';

  String get retryButton => locale == 'uz' ? 'Qayta urinish' : 'Повторить';

  String errorMessage(String error) =>
      locale == 'uz' ? 'Xatolik yuz berdi: $error' : 'Произошла ошибка: $error';

  String fetchError(int statusCode) => locale == 'uz'
      ? 'Mahsulotlarni yuklashda xatolik: $statusCode'
      : 'Ошибка загрузки товаров: $statusCode';
}
