import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/features/profile/presentation/localization/ball_coins_localization.dart';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';

class BallCoinsPage extends StatefulWidget {
  const BallCoinsPage({super.key});

  @override
  State<BallCoinsPage> createState() => _BallCoinsPageState();
}

class _BallCoinsPageState extends State<BallCoinsPage> {
  String firstChoice = 'Ball';
  String secondChoice = "So'm";
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  double result = 0.0;
  bool isTextFieldFocused = false;
  bool isLoading = false;

  final double ballToSom = 100.0 / 15.0;
  final double ballToTanga = 1.0 / 15.0;
  final double tangaToSom = 100.0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isTextFieldFocused = _focusNode.hasFocus;
      });
    });
  }

  List<String> getFirstOptions(BallCoinsLocalization l10n) {
    return [l10n.ball, l10n.tanga];
  }

  List<String> getSecondOptions(BallCoinsLocalization l10n) {
    if (firstChoice == l10n.ball) {
      return [l10n.som, l10n.tanga];
    } else {
      return [l10n.som];
    }
  }

  void _showBottomSheet(BuildContext context, bool isFirst, BallCoinsLocalization l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<String> options = isFirst ? getFirstOptions(l10n) : getSecondOptions(l10n);
        String currentSelection = isFirst ? firstChoice : secondChoice;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...options.map((option) {
                    bool isSelected = currentSelection == option;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          currentSelection = option;
                        });
                        setState(() {
                          if (isFirst) {
                            firstChoice = option;
                            if (option == l10n.tanga) {
                              secondChoice = l10n.som;
                            }
                          } else {
                            secondChoice = option;
                          }
                          _calculateConversion();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurple.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                color: Colors.white,
                              ),
                              child: isSelected
                                  ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _calculateConversion() {
    double input = double.tryParse(_inputController.text) ?? 0;

    // Get current locale to check choice names
    final appState = context.read<AppBloc>().state;
    final l10n = BallCoinsLocalization(appState.appLocale??'uz');

    if (firstChoice == l10n.ball && secondChoice == l10n.som) {
      result = input * ballToSom;
    } else if (firstChoice == l10n.ball && secondChoice == l10n.tanga) {
      result = input * ballToTanga;
    } else if (firstChoice == l10n.tanga && secondChoice == l10n.som) {
      result = input * tangaToSom;
    }

    setState(() {});
  }

  double getSomEquivalent(BallCoinsLocalization l10n) {
    double input = double.tryParse(_inputController.text) ?? 0;

    if (firstChoice == l10n.ball && secondChoice == l10n.tanga) {
      return input * ballToSom;
    } else {
      return result;
    }
  }

  void _swapChoices(BallCoinsLocalization l10n) {
    if (firstChoice == l10n.ball && secondChoice == l10n.tanga) {
      setState(() {
        firstChoice = l10n.tanga;
        secondChoice = l10n.som;
        _inputController.clear();
        result = 0;
      });
    }
  }

  String _getConversionType(BallCoinsLocalization l10n) {
    if (firstChoice == l10n.ball && secondChoice == l10n.tanga) {
      return 'SCORE_TO_COIN';
    } else if (firstChoice == l10n.ball && secondChoice == l10n.som) {
      return 'SCORE_TO_SOM';
    } else if (firstChoice == l10n.tanga && secondChoice == l10n.som) {
      return '';
    }
    return '';
  }

  Future<void> _performConversion(BallCoinsLocalization l10n) async {
    var token = sl<LocalSource>().getAccessToken();
    double amount = double.tryParse(_inputController.text) ?? 0;

    if (amount <= 0) {
      _showErrorDialog(l10n.errorEnterAmount);
      return;
    }

    String conversionType = _getConversionType(l10n);

    if (conversionType.isEmpty) {
      if (firstChoice == l10n.tanga && secondChoice == l10n.som) {
        _showErrorDialog(l10n.errorTangaToSom);
      } else {
        _showErrorDialog(l10n.errorInvalidType);
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.iqmath.uz/api/v1/func_student/my-convert/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode({
          'type': conversionType,
          'amount': amount.toInt(),
        }),
      );

      setState(() {
        isLoading = false;
      });
      alice.onHttpResponse(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _showSuccessDialog(responseData, l10n);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage =
            errorData['error'] ?? errorData['message'] ?? l10n.errorDefault;
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('${l10n.errorNetwork} ${e.toString()}');
    }
  }

  void _showSuccessDialog(dynamic responseData, BallCoinsLocalization l10n) {
    _inputController.clear();
    setState(() {
      result = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.successTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.successMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = BallCoinsLocalization(state.appLocale??'uz');

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Text(l10n.title),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      l10n.conversionRates,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.stars,
                                        color: Colors.orange, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      '15 ${l10n.ball}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '=',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: Colors.blue, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      '1 ${l10n.tanga}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: Colors.blue, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      '1 ${l10n.tanga}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '=',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.attach_money,
                                        color: Colors.green, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${tangaToSom.toInt()} ${l10n.som}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      l10n.firstChoice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _showBottomSheet(context, true, l10n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              firstChoice,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.secondChoice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: firstChoice == l10n.tanga
                          ? null
                          : () => _showBottomSheet(context, false, l10n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: firstChoice == l10n.tanga
                              ? Colors.grey.shade50
                              : Colors.white,
                          border: Border.all(
                            color: firstChoice == l10n.tanga
                                ? Colors.grey.shade200
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              secondChoice,
                              style: TextStyle(
                                fontSize: 16,
                                color: firstChoice == l10n.tanga
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: firstChoice == l10n.tanga
                                  ? Colors.grey
                                  : Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '$firstChoice ${l10n.amount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isTextFieldFocused
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                          width: isTextFieldFocused ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                hintText: '0',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              style: const TextStyle(fontSize: 18),
                              onChanged: (value) => _calculateConversion(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    firstChoice == l10n.ball
                                        ? Icons.stars
                                        : Icons.monetization_on,
                                    size: 16,
                                    color: firstChoice == l10n.ball
                                        ? Colors.orange
                                        : Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    firstChoice,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: InkWell(
                        onTap: () => _swapChoices(l10n),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.deepPurple,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      secondChoice == l10n.tanga ? l10n.toTanga : l10n.toSom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 18),
                              child: Text(
                                result.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                secondChoice,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.somEquivalent,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${getSomEquivalent(l10n).toStringAsFixed(2)} ${l10n.som}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _performConversion(l10n),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : Text(
                          l10n.convertButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        l10n.footerNote,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}