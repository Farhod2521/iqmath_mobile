import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';

class AddChildLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'addChild': {
      'uz': 'Farzand qo\'shish',
      'ru': 'Добавить ребенка',
    },
    'enterPhoneNumber': {
      'uz': 'Farzandingizning telefon raqamini kiriting',
      'ru': 'Введите номер телефона вашего ребенка',
    },
    'cancel': {
      'uz': 'Bekor qilish',
      'ru': 'Отмена',
    },
    'sendCode': {
      'uz': 'Kod yuborish',
      'ru': 'Отправить код',
    },
    'enterPhone': {
      'uz': 'Telefon raqamini kiriting',
      'ru': 'Введите номер телефона',
    },
    'incorrectPhone': {
      'uz': 'Telefon raqam noto\'g\'ri',
      'ru': 'Неверный номер телефона',
    },
    'error': {
      'uz': 'Xatolik',
      'ru': 'Ошибка',
    },
    'errorOccurred': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
    },
    'verifyCode': {
      'uz': 'Kodni tasdiqlash',
      'ru': 'Подтвердить код',
    },
    'enterCodeSent': {
      'uz': 'raqamiga yuborilgan kodni kiriting',
      'ru': 'Введите код, отправленный на номер',
    },
    'enterCode': {
      'uz': 'Kodni kiriting',
      'ru': 'Введите код',
    },
    'codeMustBe5Digits': {
      'uz': 'Kod 5 ta raqamdan iborat bo\'lishi kerak',
      'ru': 'Код должен состоять из 5 цифр',
    },
    'childAddedSuccess': {
      'uz': 'Farzand muvaffaqiyatli qo\'shildi',
      'ru': 'Ребенок успешно добавлен',
    },
    'back': {
      'uz': 'Orqaga',
      'ru': 'Назад',
    },
    'confirm': {
      'uz': 'Tasdiqlash',
      'ru': 'Подтвердить',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ??
        _localizedValues[key]?['uz'] ??
        key;
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Faqat raqamlarni qabul qilish
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Maksimal 9 ta raqam
    if (text.length > 9) {
      text = text.substring(0, 9);
    }

    // Format: XX XXX XX XX
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        formatted += ' ';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Modern dialog
class AddChildDialog extends StatefulWidget {
  const AddChildDialog({super.key});

  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendCode(String locale) async {
    String phone = _phoneController.text.replaceAll(' ', '');

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AddChildLocalization.get('enterPhone', locale)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (phone.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AddChildLocalization.get('incorrectPhone', locale)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.iqmath.uz/api/v1/auth/parent/add-child/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
        },
        body: json.encode({
          'phone': '998$phone',
        }),
      );

      setState(() {
        _isLoading = false;
      });
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        if (mounted) {
          // Kod tasdiqlash dialogini ochish
          final result = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => VerifyCodeDialog(phone: '998$phone'),
          );

          if (result != null && mounted) {
            Navigator.pop(context, result);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AddChildLocalization.get('error', locale)}: ${response.statusCode}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AddChildLocalization.get('errorOccurred', locale)}: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AddChildLocalization.get('addChild', locale),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202124),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF5F6368),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  AddChildLocalization.get('enterPhoneNumber', locale),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5F6368),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Phone input container
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8EAED),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Country code
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: const Text(
                          '+998',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202124),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1.5,
                        height: 32,
                        color: const Color(0xFFE8EAED),
                      ),

                      // Phone number input
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            PhoneNumberFormatter(),
                          ],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF202124),
                            letterSpacing: 0.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: '90 123 45 67',
                            hintStyle: TextStyle(
                              color: Color(0xFFBDC1C6),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    // Bekor qilish button
                    Expanded(
                      child: Material(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap:
                              _isLoading ? null : () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: Text(
                              AddChildLocalization.get('cancel', locale),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5F6368),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Kod yuborish button
                    Expanded(
                      child: Material(
                        color: _isLoading
                            ? const Color(0xFF4285F4).withOpacity(0.6)
                            : const Color(0xFF4285F4),
                        borderRadius: BorderRadius.circular(12),
                        elevation: _isLoading ? 0 : 2,
                        shadowColor: const Color(0xFF4285F4).withOpacity(0.3),
                        child: InkWell(
                          onTap: _isLoading ? null : () => _sendCode(locale),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AddChildLocalization.get(
                                        'sendCode', locale),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Kodni tasdiqlash dialog
class VerifyCodeDialog extends StatefulWidget {
  final String phone;

  const VerifyCodeDialog({super.key, required this.phone});

  @override
  State<VerifyCodeDialog> createState() => _VerifyCodeDialogState();
}

class _VerifyCodeDialogState extends State<VerifyCodeDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _verifyCode(String locale) async {
    String code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AddChildLocalization.get('enterCode', locale)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (code.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AddChildLocalization.get('codeMustBe5Digits', locale)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.iqmath.uz/api/v1/auth/parent/confirm-child/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
        },
        body: json.encode({
          'phone': widget.phone,
          'code': code,
        }),
      );

      setState(() {
        _isLoading = false;
      });
      alice.onHttpResponse(response);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Muvaffaqiyatli tasdiqlandi
        if (mounted) {
          String message = responseData['detail'] ??
              responseData['message'] ??
              AddChildLocalization.get('childAddedSuccess', locale);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          Navigator.pop(context, true);
        }
      } else {
        // Xatolik
        if (mounted) {
          String errorMessage = responseData['detail'] ??
              responseData['message'] ??
              AddChildLocalization.get('errorOccurred', locale);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AddChildLocalization.get('errorOccurred', locale)}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AddChildLocalization.get('verifyCode', locale),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202124),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF5F6368),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  locale == 'uz'
                      ? '+${widget.phone} ${AddChildLocalization.get('enterCodeSent', locale)}'
                      : '${AddChildLocalization.get('enterCodeSent', locale)} +${widget.phone} ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5F6368),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Code input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8EAED),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202124),
                      letterSpacing: 8,
                    ),
                    decoration: const InputDecoration(
                      hintText: '54321',
                      hintStyle: TextStyle(
                        color: Color(0xFFBDC1C6),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 8,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    // Orqaga button
                    Expanded(
                      child: Material(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap:
                              _isLoading ? null : () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: Text(
                              AddChildLocalization.get('back', locale),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5F6368),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Tasdiqlash button
                    Expanded(
                      child: Material(
                        color: _isLoading
                            ? const Color(0xFF4285F4).withOpacity(0.6)
                            : const Color(0xFF4285F4),
                        borderRadius: BorderRadius.circular(12),
                        elevation: _isLoading ? 0 : 2,
                        shadowColor: const Color(0xFF4285F4).withOpacity(0.3),
                        child: InkWell(
                          onTap: _isLoading ? null : () => _verifyCode(locale),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AddChildLocalization.get('confirm', locale),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
