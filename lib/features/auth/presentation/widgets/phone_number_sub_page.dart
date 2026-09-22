// import 'package:my_flutter_template/core/extension/extensions.dart';
// import 'package:my_flutter_template/core/theme/app_text_style.dart';
// import 'package:my_flutter_template/features/auth/presentation/widgets/privacy_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
//
// import '../../../../core/widgets/appbar_leading_widget.dart';
// import '../../../../generated/l10n.dart';
// import '../bloc/auth_bloc.dart';
//
// class PhoneNumberSubPage extends StatefulWidget {
//   final TextEditingController controller;
//   final BuildContext loginPageContext;
//
//   const PhoneNumberSubPage({
//     super.key,
//     required this.loginPageContext,
//     required this.controller,
//   });
//
//   @override
//   State<PhoneNumberSubPage> createState() => _PhoneNumberSubPageState();
// }
//
// class _PhoneNumberSubPageState extends State<PhoneNumberSubPage> {
//   final textInputFormatter = MaskTextInputFormatter(
//     mask: "(##) ###-##-##",
//     filter: {"#": RegExp(r'[0-9]')},
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalization.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         leading: Navigator.canPop(context)
//             ? const Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   AppbarLeadingWidget(
//                     withBackground: true,
//                   ),
//                 ],
//               )
//             : null,
//         leadingWidth: 56,
//         title: Text(localization.phone_number),
//       ),
//       body: Padding(
//         padding: EdgeInsets.only(
//           top: 120.height,
//           left: 20,
//           right: 20,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TextField(
//               controller: widget.controller,
//               cursorHeight: 22,
//               keyboardType: TextInputType.phone,
//               autofocus: true,
//               style: context.textStyle.fontSize16FontWeight700,
//               decoration: InputDecoration(
//                 hintText: "(00) 000-00-00",
//                 prefixText: "+998 ",
//                 prefixStyle: context.textStyle.fontSize16FontWeight700,
//               ),
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 textInputFormatter,
//               ],
//               onChanged: (phone) {
//                 if(phone.length == 14){
//                   FocusScope.of(context).unfocus();
//                 }
//                 context.read<AuthBloc>().add(
//                       AuthSetPhoneNumberEvent(phoneNumber: phone),
//                     );
//               },
//             ),
//             const PrivacyText(),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// import 'package:my_flutter_template/features/auth/presentation/widgets/phone_number_sub_page.dart';
// import 'package:my_flutter_template/generated/l10n.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:gap/gap.dart';
// import '../../../../core/widgets/custom_loading_indicator.dart';
// import '../bloc/auth_bloc.dart';
// import '../mixins/auth_page_mixin.dart';
// import '../page_args/auth_args.dart';
//
// class AuthPage extends StatefulWidget {
//   final AuthPageArgs args;
//
//   const AuthPage({super.key, required this.args});
//
//   @override
//   State<AuthPage> createState() => _AuthPageState();
// }
//
// class _AuthPageState extends State<AuthPage> with AuthPageMixin {
//   late final TextEditingController phoneController;
//   late final TextEditingController smsController;
//   late final TextEditingController firstNameController;
//   late final TextEditingController surnameController;
//   late final TextEditingController passwordController;
//   late final TextEditingController confirmPasswordController;
//
//   String selectedAuthType = 'login';
//
//   @override
//   void initState() {
//     phoneController = TextEditingController();
//     smsController = TextEditingController();
//     firstNameController = TextEditingController();
//     surnameController = TextEditingController();
//     passwordController = TextEditingController();
//     confirmPasswordController = TextEditingController();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     phoneController.dispose();
//     smsController.dispose();
//     firstNameController.dispose();
//     surnameController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   void _handleSubmit() {
//     // Your authentication logic here
//     // context.read<AuthBloc>().add(
//     //   AuthSubmitEvent(
//     //     phoneNumber: phoneController.text,
//     //     password: passwordController.text,
//     //     authType: selectedAuthType,
//     //   ),
//     // );
//   }
//
//   bool _canProceed() {
//     if (selectedAuthType == 'login') {
//       return phoneController.text.length >= 14 &&
//           passwordController.text.length >= 6;
//     } else {
//       // Register validation
//       return firstNameController.text.isNotEmpty &&
//           phoneController.text.length >= 14 &&
//           passwordController.text.length >= 6 &&
//           confirmPasswordController.text == passwordController.text;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalization.of(context);
//     final mediaQuery = MediaQuery.of(context);
//
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         authListener(
//           context: context,
//           state: state,
//         );
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: Text(
//             selectedAuthType == 'login' ? 'Sign in' : 'Sign up',
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Text(
//                 selectedAuthType == 'login'
//                     ? "Sign in to LearnCraft"
//                     : "Sign up to LearnCraft",
//                 style: const TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1A1A1A),
//                 ),
//               ),
//               const Gap(8),
//               Text(
//                 selectedAuthType == 'login'
//                     ? "It's free, secure, and simple. Let us help you track your work sessions and boost your focus."
//                     : "It's free, secure, and simple. Let us help you track your work sessions and boost your focus.",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey.shade600,
//                   height: 1.4,
//                 ),
//               ),
//
//               const Gap(32),
//
//               // Auth type toggle
//               Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8F9FA),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => selectedAuthType = 'login'),
//                         child: Container(
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: selectedAuthType == 'login'
//                                 ? Colors.white
//                                 : Colors.transparent,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: selectedAuthType == 'login'
//                                 ? [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ]
//                                 : null,
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Sign in",
//                               style: TextStyle(
//                                 color: selectedAuthType == 'login'
//                                     ? Colors.black
//                                     : Colors.grey.shade600,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => selectedAuthType = 'register'),
//                         child: Container(
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: selectedAuthType == 'register'
//                                 ? Colors.white
//                                 : Colors.transparent,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: selectedAuthType == 'register'
//                                 ? [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ]
//                                 : null,
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Sign up",
//                               style: TextStyle(
//                                 color: selectedAuthType == 'register'
//                                     ? Colors.black
//                                     : Colors.grey.shade600,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const Gap(32),
//
//               // Form fields based on auth type
//               if (selectedAuthType == 'register') ...[
//                 // Full name field for register
//                 Text(
//                   "Full name",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const Gap(8),
//                 TextField(
//                   controller: firstNameController,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: "Enter your full name",
//                     filled: true,
//                     fillColor: const Color(0xFFF8F9FA),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Color(0xFF007AFF),
//                         width: 2,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 16,
//                     ),
//                   ),
//                 ),
//                 const Gap(24),
//               ],
//
//               // Email/Phone field
//               Text(
//                 selectedAuthType == 'login' ? "Phone number" : "Email",
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const Gap(8),
//               TextField(
//                 controller: phoneController,
//                 keyboardType: selectedAuthType == 'login'
//                     ? TextInputType.phone
//                     : TextInputType.emailAddress,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: selectedAuthType == 'login'
//                       ? "(00) 000-00-00"
//                       : "Enter your email",
//                   prefixText: selectedAuthType == 'login' ? "+998 " : null,
//                   prefixStyle: selectedAuthType == 'login' ? const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF1A1A1A),
//                   ) : null,
//                   filled: true,
//                   fillColor: const Color(0xFFF8F9FA),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Color(0xFF007AFF),
//                       width: 2,
//                     ),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 16,
//                   ),
//                 ),
//               ),
//
//               const Gap(24),
//
//               // Password field
//               Text(
//                 "Password",
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const Gap(8),
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: "Enter your password",
//                   filled: true,
//                   fillColor: const Color(0xFFF8F9FA),
//                   suffixIcon: Icon(
//                     Icons.visibility_outlined,
//                     color: Colors.grey.shade600,
//                     size: 20,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Color(0xFF007AFF),
//                       width: 2,
//                     ),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 16,
//                   ),
//                 ),
//               ),
//
//               // Confirm password for register
//               if (selectedAuthType == 'register') ...[
//                 const Gap(24),
//                 Text(
//                   "Confirm password",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const Gap(8),
//                 TextField(
//                   controller: confirmPasswordController,
//                   obscureText: true,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: "Enter your password",
//                     filled: true,
//                     fillColor: const Color(0xFFF8F9FA),
//                     suffixIcon: Icon(
//                       Icons.visibility_outlined,
//                       color: Colors.grey.shade600,
//                       size: 20,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Color(0xFF007AFF),
//                         width: 2,
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 16,
//                     ),
//                   ),
//                 ),
//               ],
//
//               // Password requirements for register
//               if (selectedAuthType == 'register') ...[
//                 const Gap(16),
//                 _buildPasswordRequirement("Must be at least 8 characters", true),
//                 const Gap(4),
//                 _buildPasswordRequirement("Can't include your name or email address", true),
//                 const Gap(4),
//                 _buildPasswordRequirement("Must have at least a symbol or number", true),
//               ],
//
//               const Gap(40),
//
//               // Continue button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _canProceed() ? _handleSubmit : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _canProceed()
//                         ? const Color(0xFF16A085)
//                         : const Color(0xFFB5D6CC),
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     disabledBackgroundColor: const Color(0xFFB5D6CC),
//                   ),
//                   child: const Text(
//                     "Continue",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const Gap(24),
//
//               // Sign in/up toggle text
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       selectedAuthType == 'login'
//                           ? "Already have an account? "
//                           : "Already have an account? ",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedAuthType = selectedAuthType == 'login' ? 'register' : 'login';
//                         });
//                       },
//                       child: Text(
//                         selectedAuthType == 'login' ? "Sign up" : "Sign in",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF007AFF),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const Gap(40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPasswordRequirement(String text, bool isValid) {
//     return Row(
//       children: [
//         Icon(
//           isValid ? Icons.check_circle : Icons.radio_button_unchecked,
//           size: 16,
//           color: isValid ? const Color(0xFF16A085) : Colors.grey.shade400,
//         ),
//         const Gap(8),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 12,
//             color: isValid ? const Color(0xFF16A085) : Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }
// }