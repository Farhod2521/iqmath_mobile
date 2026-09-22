// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// class OTPVerificationPage extends StatefulWidget {
//   final String phoneNumber;
//
//   const OTPVerificationPage({
//     Key? key,
//     required this.phoneNumber,
//   }) : super(key: key);
//
//   @override
//   State<OTPVerificationPage> createState() => _OTPVerificationPageState();
// }
//
// class _OTPVerificationPageState extends State<OTPVerificationPage>
//     with TickerProviderStateMixin {
//   final List<TextEditingController> _controllers =
//   List.generate(6, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes =
//   List.generate(6, (index) => FocusNode());
//
//   late AnimationController _slideController;
//   late AnimationController _buttonController;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _buttonAnimation;
//
//   Timer? _timer;
//   int _resendTimer = 60;
//   bool _canResend = false;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _startResendTimer();
//     _setupFocusListeners();
//   }
//
//   void _setupAnimations() {
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _buttonController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOut,
//     ));
//
//     _buttonAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _buttonController,
//       curve: Curves.easeInOut,
//     ));
//
//     _slideController.forward();
//   }
//
//   void _setupFocusListeners() {
//     for (int i = 0; i < _focusNodes.length; i++) {
//       _focusNodes[i].addListener(() {
//         setState(() {}); // Rebuild to update border colors
//       });
//     }
//   }
//
//   void _startResendTimer() {
//     setState(() {
//       _canResend = false;
//       _resendTimer = 60;
//     });
//
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         if (_resendTimer > 0) {
//           setState(() {
//             _resendTimer--;
//           });
//         } else {
//           setState(() {
//             _canResend = true;
//           });
//           timer.cancel();
//         }
//       }
//     });
//   }
//
//   void _onDigitChanged(String value, int index) {
//     // Clear the field first to handle replacement
//     if (value.length > 1) {
//       _controllers[index].text = value.substring(value.length - 1);
//       _controllers[index].selection = TextSelection.fromPosition(
//         TextPosition(offset: 1),
//       );
//       return;
//     }
//
//     if (value.isNotEmpty) {
//       // Move to next field
//       if (index < 5) {
//         _focusNodes[index + 1].requestFocus();
//       } else {
//         _focusNodes[index].unfocus();
//         _checkOTP();
//       }
//     } else {
//       // Handle backspace - move to previous field
//       if (index > 0) {
//         _focusNodes[index - 1].requestFocus();
//       }
//     }
//   }
//
//   void _checkOTP() {
//     String otp = _controllers.map((controller) => controller.text).join();
//     if (otp.length == 6) {
//       _verifyOTP(otp);
//     }
//   }
//
//   Future<void> _verifyOTP(String otp) async {
//     if (_isLoading) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));
//
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//
//         if (otp == "123456") {
//           _showSuccessDialog();
//         } else {
//           _showErrorDialog();
//           _clearAllFields();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//         _showErrorDialog();
//       }
//     }
//   }
//
//   void _clearAllFields() {
//     for (var controller in _controllers) {
//       controller.clear();
//     }
//     _focusNodes[0].requestFocus();
//   }
//
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         contentPadding: const EdgeInsets.all(24),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check_circle,
//                 color: Colors.green,
//                 size: 40,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Success!',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'OTP verified successfully!',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   // Navigate to next screen
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Continue'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showErrorDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         contentPadding: const EdgeInsets.all(24),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 40,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Invalid OTP',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Please check your code and try again.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Try Again'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _resendCode() {
//     if (_canResend && !_isLoading) {
//       _startResendTimer();
//       _clearAllFields();
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.white),
//               SizedBox(width: 8),
//               Text('New OTP sent to your phone number'),
//             ],
//           ),
//           backgroundColor: Colors.green,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   String _formatTimer(int seconds) {
//     int minutes = seconds ~/ 60;
//     int remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _slideController.dispose();
//     _buttonController.dispose();
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Verify OTP code',
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SlideTransition(
//         position: _slideAnimation,
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 32),
//
//               // Title
//               const Text(
//                 'Enter OTP code',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Description
//               RichText(
//                 text: TextSpan(
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                     height: 1.4,
//                   ),
//                   children: [
//                     const TextSpan(text: "We've sent a one time OTP to your phone number\n"),
//                     TextSpan(
//                       text: widget.phoneNumber,
//                       style: const TextStyle(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 48),
//
//               // Enter OTP label
//               const Text(
//                 'Enter OTP',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // OTP Input Fields - Chiroyli dizayn
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: List.generate(6, (index) {
//                     bool hasFocus = _focusNodes[index].hasFocus;
//                     bool hasValue = _controllers[index].text.isNotEmpty;
//
//                     return Container(
//                       width: 48,
//                       height: 56,
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: hasFocus
//                               ? Colors.teal
//                               : hasValue
//                               ? Colors.teal.withOpacity(0.5)
//                               : Colors.grey[300]!,
//                           width: hasFocus ? 2.0 : 1.5,
//                         ),
//                         boxShadow: [
//                           if (hasFocus)
//                             BoxShadow(
//                               color: Colors.teal.withOpacity(0.3),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             )
//                           else
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                         ],
//                       ),
//                       child: TextFormField(
//                         controller: _controllers[index],
//                         focusNode: _focusNodes[index],
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w600,
//                           color: hasValue ? Colors.teal[700] : Colors.black87,
//                         ),
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           counterText: '',
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                         onChanged: (value) => _onDigitChanged(value, index),
//                         onTap: () {
//                           _controllers[index].selection = TextSelection.fromPosition(
//                             TextPosition(offset: _controllers[index].text.length),
//                           );
//                         },
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Resend Code
//               Center(
//                 child: Column(
//                   children: [
//                     if (!_canResend) ...[
//                       Text(
//                         'Resend Code in ${_formatTimer(_resendTimer)}',
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ] else ...[
//                       TextButton(
//                         onPressed: _resendCode,
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.teal,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                         ),
//                         child: const Text(
//                           'Resend Code',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//
//               const Spacer(),
//
//               // Continue Button
//               ScaleTransition(
//                 scale: _buttonAnimation,
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : () {
//                       if (!_isLoading) {
//                         _buttonController.forward().then((_) {
//                           _buttonController.reverse();
//                         });
//                         _checkOTP();
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.teal,
//                       foregroundColor: Colors.white,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       disabledBackgroundColor: Colors.grey[300],
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                         : const Text(
//                       'Continue',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Terms and Privacy
//               Center(
//                 child: RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       height: 1.4,
//                     ),
//                     children: const [
//                       TextSpan(text: 'By signing up you acknowledge and agree to LearnCraft\n'),
//                       TextSpan(
//                         text: 'General Terms of Use',
//                         style: TextStyle(
//                           color: Colors.teal,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                       TextSpan(text: ' and '),
//                       TextSpan(
//                         text: 'Privacy Policy',
//                         style: TextStyle(
//                           color: Colors.teal,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_args.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_page_localization.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../core/widgets/top_notification.dart';
import '../../../../router/name_routes.dart';
import '../bloc/auth_bloc.dart';

class OTPVerificationPage extends StatefulWidget {
  final OtpPageArgs args;

  const OTPVerificationPage({
    super.key,
    required this.args,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  late TextEditingController _otpController;
  String currentOTP = "";
  bool isOTPComplete = false;
  Timer? _timer;
  int _remainingTime = 66;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void _onOTPChanged(String value) {
    setState(() {
      currentOTP = value;
      isOTPComplete = value.length == 5;
    });
  }

  void _onContinuePressed() {
    if (isOTPComplete) {
      context.read<AuthBloc>().add(
        ConfirmEvent(
          phone: widget.args.phoneNumber,
          smsCode: currentOTP,
          reset: widget.args.reset,
        ),
      );
      debugPrint("OTP Entered: $currentOTP");
    }
  }

  void _onResendCode() {
    if (_remainingTime == 0) {
      setState(() {
        _remainingTime = 66;
      });
      _startTimer();
      debugPrint("Resending OTP to ${widget.args.phoneNumber}");
    }
  }

  void _onTermsPressed() {
    debugPrint("Terms of Use clicked");
  }

  void _onPrivacyPressed() {
    debugPrint("Privacy Policy clicked");
  }

  void _onEmailPressed() {
    debugPrint("Phone clicked: ${widget.args.phoneNumber}");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale??'uz';

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state.confirmStatus.isSuccess) {
              if (widget.args.reset) {
                Navigator.pushNamed(
                  context,
                  Routes.resetPassword,
                  arguments: widget.args.phoneNumber,
                );
              } else {
                TopNotification.showSuccess(
                  context,
                  message: OTPLocalization.get('successLogin', locale),
                );
                await showCredentialsDialog(
                  context,
                  locale: locale,
                  login: state.confirmResponseEntity?.login ?? '',
                  password: state.confirmResponseEntity?.password ?? '',
                );
                // await Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   Routes.main,
                //       (route) => false,
                // );
                if (state.role == 'student') {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.main,
                        (route) => false,
                  );
                } else if (state.role == 'parent') {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.mainParent,
                        (route) => false,
                  );
                } else if (state.role == 'tutor') {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.mainTeacher,
                        (route) => false,
                  );
                }else {
                  TopNotification.showSuccess(
                    context,
                    message:
                    '${OTPLocalization.get('roleError', locale)} ${state.role}',
                  );
                }

              }
            }
            if (state.confirmStatus.isError) {
              TopNotification.showError(
                context,
                message: state.errorMessage?.message ??
                    OTPLocalization.get('error', locale),
              );
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                OTPLocalization.get('verifyOTP', locale),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Title
                    Text(
                      OTPLocalization.get('enterOTP', locale),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle with phone
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text:
                            "${OTPLocalization.get('sentMessage', locale)}\n",
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _onEmailPressed,
                              child: Text(
                                '+998 ${widget.args.phoneNumber}',
                                style: const TextStyle(
                                  color: Color(0xFF2E8B57),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Enter OTP label
                    Text(
                      OTPLocalization.get('enterOTPLabel', locale),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // OTP Input Fields
                    PinCodeTextField(
                      appContext: context,
                      length: 5,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 56,
                        fieldWidth: 48,
                        borderWidth: 1.5,
                        activeColor: const Color(0xFF2E8B57),
                        inactiveColor: const Color(0xFFE5E5E5),
                        selectedColor: const Color(0xFF2E8B57),
                        activeFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                      ),
                      enableActiveFill: true,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      onChanged: _onOTPChanged,
                      beforeTextPaste: (text) {
                        return text?.length == 5 &&
                            RegExp(r'^[0-9]+$').hasMatch(text!);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Resend Code Timer
                    GestureDetector(
                      onTap: _onResendCode,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: OTPLocalization.get('resendCode', locale),
                            ),
                            TextSpan(
                              text: _formatTime(_remainingTime),
                              style: TextStyle(
                                color: _remainingTime == 0
                                    ? const Color(0xFF2E8B57)
                                    : const Color(0xFF2E8B57),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isOTPComplete ? _onContinuePressed : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOTPComplete
                              ? const Color(0xFF2E8B57)
                              : const Color(0xFFB8E6CC),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: const Color(0xFFB8E6CC),
                        ),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state.confirmStatus.isLoading) {
                              return const CustomLoadingIndicator(
                                color: Colors.white,
                                size: 20,
                              );
                            }
                            return Text(
                              OTPLocalization.get('continue', locale),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms and Privacy Policy
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: OTPLocalization.get('termsText', locale),
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _onTermsPressed,
                              child: Text(
                                OTPLocalization.get('termsOfUse', locale),
                                style: const TextStyle(
                                  color: Color(0xFF2E8B57),
                                  fontSize: 12,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: OTPLocalization.get('and', locale),
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _onPrivacyPressed,
                              child: Text(
                                OTPLocalization.get('privacyPolicy', locale),
                                style: const TextStyle(
                                  color: Color(0xFF2E8B57),
                                  fontSize: 12,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: OTPLocalization.get('termsAgree', locale),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showCredentialsDialog(
      BuildContext context, {
        required String locale,
        required String login,
        required String password,
      }) {
    void showCopiedFeedback(BuildContext ctx) {
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(OTPLocalization.get('copied', locale)),
            duration: const Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        showCupertinoDialog(
          context: ctx,
          builder: (c) {
            Future.delayed(const Duration(milliseconds: 700), () {
              if (Navigator.of(c, rootNavigator: true).canPop()) {
                Navigator.of(c, rootNavigator: true).pop();
              }
            });
            return CupertinoAlertDialog(
              content: Text(OTPLocalization.get('copied', locale)),
            );
          },
        );
      }
    }

    Future<void> copyToClipboard(BuildContext ctx, String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      showCopiedFeedback(ctx);
    }

    return showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(OTPLocalization.get('credentials', locale)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Login row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          OTPLocalization.get('login', locale),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          login,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.doc_on_doc, size: 20),
                    onPressed: () => copyToClipboard(ctx, login),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Password row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          OTPLocalization.get('password', locale),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          password,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.doc_on_doc, size: 20),
                    onPressed: () => copyToClipboard(ctx, password),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                copyToClipboard(
                  ctx,
                  '${OTPLocalization.get('login', locale)}: $login\n${OTPLocalization.get('password', locale)}: $password',
                );
              },
              child: Text(OTPLocalization.get('copyAll', locale)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
              child: Text(OTPLocalization.get('close', locale)),
            ),
          ],
        );
      },
    );
  }
}
