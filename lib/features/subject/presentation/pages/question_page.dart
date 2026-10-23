// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:math_keyboard/math_keyboard.dart';
// import 'package:http/http.dart' as http;
// import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
// import 'package:my_flutter_template/core/widgets/top_notification.dart';
// import 'package:my_flutter_template/features/subject/presentation/mixin/question_mixin.dart';
// import 'package:my_flutter_template/features/subject/presentation/widget/topic_card.dart';
// import 'package:flutter_math_fork/flutter_math.dart';
//
// import '../../../../core/local_source/local_source.dart';
// import '../../../../injector_container.dart';
//
// class QuestionPage extends StatefulWidget {
//   final QuestionPageArguments arguments;
//
//   const QuestionPage({
//     super.key,
//     required this.arguments,
//   });
//
//   @override
//   State<QuestionPage> createState() => _QuestionPageState();
// }
//
// class _QuestionPageState extends State<QuestionPage> with QuestionMixin {
//   List<dynamic> _questions = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//
//   int _currentQuestionIndex = 0;
//   final Map<int, dynamic> _answers = {};
//   final Map<int, MathFieldEditingController> _controllers = {};
//   final Map<int, FocusNode> _focusNodes = {};
//   final Map<String, Uint8List> _imageCache = {};
//   int? _activeFieldId;
//   final Set<int> _visitedQuestions = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _visitedQuestions.add(0);
//     _loadQuestions();
//   }
//
//   Future<void> _loadQuestions() async {
//     var token = sl<LocalSource>().getAccessToken();
//     try {
//       final response = widget.arguments.isDiagnostic
//           ? await http.post(
//               Uri.parse(
//                   'https://api.iqmath.uz/api/v1/func_student/my-generate-test/'),
//               headers: {
//                 'Authorization': '$token',
//                 'Content-Type': 'application/json',
//               },
//               body: jsonEncode({
//                 'level': 1,
//                 'subject_id': widget.arguments.subjectId,
//               }),
//             )
//           : await http.get(
//               Uri.parse(
//                   'https://api.iqmath.uz/api/v1/func_student/my-question/${widget.arguments.topic?.id}/?level=${1}'),
//               headers: {
//                 'Authorization': '$token',
//               },
//             );
//
//       alice.onHttpResponse(response);
//       if (response.statusCode == 200) {
//         debugPrint(response.body);
//         final data = jsonDecode(response.body);
//         setState(() {
//           _questions = data['questions'] ?? [];
//           _isLoading = false;
//           _initializeControllers();
//         });
//       } else {
//         setState(() {
//           _errorMessage =
//               'Savollarni yuklashda xatolik: ${response.statusCode}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Xatolik yuz berdi: $e';
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _initializeControllers() {
//     for (var question in _questions) {
//       final questionType = question['question_type'] as String?;
//
//       switch (questionType) {
//         case 'text':
//           _createController(question['id'] as int);
//           break;
//
//         case 'composite':
//           final subQuestions = question['sub_questions'] as List<dynamic>?;
//           if (subQuestions != null) {
//             for (var subQuestion in subQuestions) {
//               final subId = subQuestion['id'] as int;
//               _createController(subId);
//             }
//           }
//           break;
//
//         case 'choice':
//           break;
//
//         default:
//           debugPrint('Noma\'lum question type: $questionType');
//       }
//     }
//   }
//
//   void _createController(int id) {
//     _controllers[id] = MathFieldEditingController();
//     _focusNodes[id] = FocusNode();
//
//     _focusNodes[id]!.addListener(() {
//       if (_focusNodes[id]!.hasFocus) {
//         setState(() {
//           _activeFieldId = id;
//         });
//       } else {
//         if (_activeFieldId == id) {
//           setState(() {
//             _activeFieldId = null;
//           });
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes.values) {
//       focusNode.dispose();
//     }
//     _imageCache.clear();
//     super.dispose();
//   }
//
//   void _hideKeyboard() {
//     for (var focusNode in _focusNodes.values) {
//       if (focusNode.hasFocus) {
//         focusNode.unfocus();
//       }
//     }
//     if (mounted) {
//       setState(() {
//         _activeFieldId = null;
//       });
//     }
//     FocusScope.of(context).unfocus();
//   }
//
//   void _showKeyboard(int id) {
//     for (var focusNode in _focusNodes.values) {
//       focusNode.unfocus();
//     }
//
//     setState(() {
//       _activeFieldId = id;
//     });
//
//     Future.delayed(const Duration(milliseconds: 50), () {
//       _focusNodes[id]?.requestFocus();
//     });
//   }
//
//   bool get canGoBack => _currentQuestionIndex > 0;
//
//   bool get canGoNext => _currentQuestionIndex < _questions.length - 1;
//
//   bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
//
//   bool get hasActiveKeyboard => _activeFieldId != null;
//
//   // LaTeX ni backendga yuborish uchun konvertatsiya
//   String _convertToLatex(String input) {
//     if (input.isEmpty || input == r'\Box') return '';
//
//     // Agar allaqachon LaTeX formatida bo'lsa
//     if (input.startsWith(r'\(') && input.endsWith(r'\)')) {
//       return input;
//     }
//
//     // LaTeX formatiga o'tkazish
//     return r'\(' + input + r'\)';
//   }
//
//   void _saveCurrentAnswer() {
//     if (_questions.isEmpty) return;
//
//     final currentQuestion = _questions[_currentQuestionIndex];
//     final questionType = currentQuestion['question_type'] as String?;
//
//     switch (questionType) {
//       case 'text':
//         _saveTextAnswer(currentQuestion['id'] as int?);
//         break;
//
//       case 'composite':
//         _saveCompositeAnswer(currentQuestion);
//         break;
//
//       case 'choice':
//         break;
//
//       default:
//         debugPrint('Noma\'lum question type: $questionType');
//     }
//   }
//
//   void _saveTextAnswer(int? id) {
//     if (id == null) return;
//     final controller = _controllers[id];
//     if (controller != null) {
//       final text = controller.currentEditingValue();
//       if (text.isNotEmpty && text != r'\Box') {
//         _answers[id] = _convertToLatex(text);
//       } else {
//         _answers.remove(id);
//       }
//     }
//   }
//
//   void _saveCompositeAnswer(Map<String, dynamic> question) {
//     final questionId = question['id'] as int?;
//     if (questionId == null) return;
//
//     final subQuestions = question['sub_questions'] as List<dynamic>?;
//     if (subQuestions == null) return;
//
//     Map<int, String> compositeAnswer = {};
//     bool hasAnyAnswer = false;
//
//     for (var subQuestion in subQuestions) {
//       final subQuestionId = subQuestion['id'] as int;
//       final controller = _controllers[subQuestionId];
//
//       if (controller != null) {
//         final text = controller.currentEditingValue();
//         if (text.isNotEmpty && text != r'\Box') {
//           compositeAnswer[subQuestionId] = _convertToLatex(text);
//           hasAnyAnswer = true;
//         }
//       }
//     }
//
//     if (hasAnyAnswer) {
//       _answers[questionId] = compositeAnswer;
//     } else {
//       _answers.remove(questionId);
//     }
//   }
//
//   void _navigateQuestion(bool forward) {
//     _saveCurrentAnswer();
//     // _hideKeyboard(); // BU QATORNI OLIB TASHLANG yoki comment qiling
//     setState(() {
//       _currentQuestionIndex += forward ? 1 : -1;
//       _visitedQuestions.add(_currentQuestionIndex);
//     });
//     Future.delayed(const Duration(milliseconds: 100), () {
//       _activateFirstField();
//     });
//   }
//
//   void _activateFirstField() {
//     if (!mounted || _questions.isEmpty) return;
//
//     final currentQuestion = _questions[_currentQuestionIndex];
//     final questionType = currentQuestion['question_type'] as String?;
//
//     int? firstFieldId;
//
//     switch (questionType) {
//       case 'text':
//         firstFieldId = currentQuestion['id'] as int?;
//         break;
//
//       case 'composite':
//         final subQuestions = currentQuestion['sub_questions'] as List<dynamic>?;
//         if (subQuestions != null && subQuestions.isNotEmpty) {
//           firstFieldId = subQuestions[0]['id'] as int?;
//         }
//         break;
//
//       case 'choice':
//         // Choice uchun keyboard yopamiz
//         _hideKeyboard();
//         return;
//
//       default:
//         return;
//     }
//
//     if (firstFieldId != null && _activeFieldId != null) {
//       // Agar klaviatura ochiq bo'lsa, faqat yangi fieldni aktiv qilish
//       setState(() {
//         _activeFieldId = firstFieldId;
//       });
//       Future.delayed(const Duration(milliseconds: 50), () {
//         _focusNodes[firstFieldId]?.requestFocus();
//       });
//     } else if (firstFieldId != null && _activeFieldId == null) {
//       // Agar klaviatura yopiq bo'lsa, ochish
//       _showKeyboard(firstFieldId);
//     }
//   }
//
//   Future<void> _finishTest() async {
//     _saveCurrentAnswer();
//     _hideKeyboard();
//     await _checkAnswers();
//   }
//
//   Future<void> _checkAnswers() async {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(
//         child: CircularProgressIndicator(color: Color(0xFF007AFF)),
//       ),
//     );
//
//     var token = sl<LocalSource>().getAccessToken();
//
//     List<Map<String, dynamic>> textAnswers = [];
//     List<Map<String, dynamic>> choiceAnswers = [];
//     List<Map<String, dynamic>> compositeAnswers = [];
//
//     for (var question in _questions) {
//       final questionType = question['question_type'] as String?;
//       final questionId = question['id'] as int;
//
//       switch (questionType) {
//         case 'text':
//           final answer = _answers[questionId];
//           String answerText = '';
//           if (answer != null &&
//               answer is String &&
//               answer.isNotEmpty &&
//               answer != r'\Box') {
//             answerText = answer;
//           }
//           textAnswers.add({
//             'question_id': questionId,
//             'answer_uz': answerText,
//           });
//           break;
//
//         case 'composite':
//           final compositeAnswer = _answers[questionId];
//           List<String> answers = [];
//           final subQuestions = question['sub_questions'] as List<dynamic>?;
//           if (subQuestions != null) {
//             for (var subQuestion in subQuestions) {
//               final subId = subQuestion['id'] as int;
//               String subAnswerText = '';
//               if (compositeAnswer != null && compositeAnswer is Map) {
//                 final subAnswer = compositeAnswer[subId];
//                 if (subAnswer != null &&
//                     subAnswer is String &&
//                     subAnswer.isNotEmpty &&
//                     subAnswer != r'\Box') {
//                   subAnswerText = subAnswer;
//                 }
//               }
//               answers.add(subAnswerText);
//             }
//           }
//           compositeAnswers.add({
//             'question_id': questionId,
//             'answers': answers,
//           });
//           break;
//
//         case 'choice':
//           final answer = _answers[questionId];
//           if (answer != null && answer is String && answer.isNotEmpty) {
//             choiceAnswers.add({
//               'question_id': questionId,
//               'choices': [int.tryParse(answer) ?? 0],
//             });
//           }
//           break;
//       }
//     }
//
//     final requestBody = {
//       'text_answers': textAnswers,
//       'choice_answers': choiceAnswers,
//       'composite_answers': compositeAnswers,
//     };
//
//     print('Request body: ${jsonEncode(requestBody)}');
//
//     try {
//       final apiUrl = widget.arguments.isDiagnostic
//           ? 'https://api.iqmath.uz/api/v1/func_student/my-generate-check-answer/'
//           : 'https://api.iqmath.uz/api/v1/func_student/my-check-answer/';
//
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Authorization': '$token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(requestBody),
//       );
//
//       alice.onHttpResponse(response);
//       _lastCheckAnswerResponse = jsonDecode(response.body);
//       if (mounted) {
//         Navigator.of(context).pop();
//       }
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Check answer response: $data');
//
//         int correctCount = 0;
//         int incorrectCount = 0;
//         int answeredCount = 0;
//
//         final questionResults = data['question'] as List<dynamic>? ?? [];
//         for (var result in questionResults) {
//           final answer = result['answer'];
//           if (answer == true) {
//             correctCount++;
//             answeredCount++;
//           } else if (answer == false) {
//             incorrectCount++;
//             answeredCount++;
//           }
//         }
//
//         final totalQuestions = _questions.length;
//
//         final resultData = data['result'] as List<dynamic>? ?? [];
//         double score = 0.0;
//         if (resultData.isNotEmpty) {
//           score = (resultData[0]['score'] as num?)?.toDouble() ?? 0.0;
//         }
//         if (widget.arguments.isDiagnostic) {
//           _showSimpleResultsDialog(totalQuestions, correctCount, score);
//         } else {
//           _showResultsDialog(totalQuestions, answeredCount, correctCount,
//               incorrectCount, data, score);
//         }
//       } else if (response.statusCode == 400) {
//         TopNotification.showError(
//           context,
//           message: response.body.toString(),
//           title: 'Testni to\'liq bajaring',
//         );
//       } else {
//         print('Check answer failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Check answer error: $e');
//       if (mounted) {
//         Navigator.of(context).pop();
//       }
//     }
//   }
//
//   // HTML entities va LaTeX ni to'g'ri parse qilish
//   String _cleanHtmlEntities(String text) {
//     return text
//         .replaceAll('&nbsp;', ' ')
//         .replaceAll('&amp;', '&')
//         .replaceAll('&lt;', '<')
//         .replaceAll('&gt;', '>')
//         .replaceAll('&quot;', '"')
//         .replaceAll('&#39;', "'")
//         .replaceAll('&ldquo;', '"')
//         .replaceAll('&rdquo;', '"')
//         .replaceAll('&lsquo;', "'")
//         .replaceAll('&rsquo;', "'")
//         .trim();
//   }
//
//   // HTML teglarini tozalash
//   String _stripHtmlTags(String html) {
//     return html
//         .replaceAll(RegExp(r'<p>'), '')
//         .replaceAll(RegExp(r'</p>'), '\n')
//         .replaceAll(RegExp(r'<br\s*/?>'), '\n')
//         .replaceAll(RegExp(r'<[^>]*>'), '')
//         .trim();
//   }
//
//   // LaTeX matnni parse qilish va render qilish
//   Widget _buildLatexText(String text) {
//     // HTML entities tozalash
//     final cleanedText = _cleanHtmlEntities(_stripHtmlTags(text));
//
//     // LaTeX pattern: \( ... \) yoki \[ ... \]
//     final latexPattern = RegExp(r'\\\((.*?)\\\)|\\\[(.*?)\\\]');
//     final matches = latexPattern.allMatches(cleanedText);
//
//     if (matches.isEmpty) {
//       // LaTeX yo'q - oddiy matn
//       return Text(
//         cleanedText,
//         style: const TextStyle(
//           fontSize: 20,
//           color: Color(0xFF1C1C1E),
//           height: 1.5,
//           fontWeight: FontWeight.w400,
//         ),
//       );
//     }
//
//     List<InlineSpan> spans = [];
//     int lastIndex = 0;
//
//     for (final match in matches) {
//       // LaTeX dan oldingi oddiy matn
//       if (match.start > lastIndex) {
//         final plainText = cleanedText.substring(lastIndex, match.start);
//         if (plainText.isNotEmpty) {
//           spans.add(TextSpan(
//             text: plainText,
//             style: const TextStyle(
//               fontSize: 20,
//               color: Color(0xFF1C1C1E),
//               height: 1.5,
//             ),
//           ));
//         }
//       }
//
//       // LaTeX formula (\( \) yoki \[ \] ichidagi)
//       final latexCode = match.group(1) ?? match.group(2) ?? '';
//       if (latexCode.isNotEmpty) {
//         try {
//           spans.add(WidgetSpan(
//             alignment: PlaceholderAlignment.middle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
//               child: Math.tex(
//                 latexCode,
//                 textStyle: const TextStyle(
//                   fontSize: 22,
//                   color: Color(0xFF1C1C1E),
//                 ),
//                 mathStyle: MathStyle.text,
//               ),
//             ),
//           ));
//         } catch (e) {
//           // Agar LaTeX parse bo'lmasa, oddiy matn ko'rsatish
//           spans.add(TextSpan(
//             text: latexCode,
//             style: const TextStyle(
//               fontSize: 20,
//               color: Color(0xFFFF3B30),
//               height: 1.5,
//             ),
//           ));
//           debugPrint('LaTeX parse error: $e');
//         }
//       }
//
//       lastIndex = match.end;
//     }
//
//     // Qolgan oddiy matn
//     if (lastIndex < cleanedText.length) {
//       final remainingText = cleanedText.substring(lastIndex);
//       if (remainingText.isNotEmpty) {
//         spans.add(TextSpan(
//           text: remainingText,
//           style: const TextStyle(
//             fontSize: 20,
//             color: Color(0xFF1C1C1E),
//             height: 1.5,
//           ),
//         ));
//       }
//     }
//
//     return RichText(
//       text: TextSpan(children: spans),
//     );
//   }
//
//   void _showResultsDialog(
//       int totalQuestions,
//       int answeredCount,
//       int correctCount,
//       int incorrectCount,
//       Map<String, dynamic> results,
//       double score) {
//     if (!mounted) return;
//
//     final percentage = score.toInt();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: IconButton(
//                     icon: const Icon(Icons.close,
//                         size: 28, color: Color(0xFF2C3545)),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       Navigator.of(context).pop();
//                     },
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   width: 120,
//                   height: 120,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     clipBehavior: Clip.none,
//                     children: [
//                       Positioned(
//                         bottom: -10,
//                         child: SvgPicture.network(
//                             'https://iqmath.uz/icons/award.svg'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 Text(
//                   'Sizning ballingiz $correctCount',
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1a1a2e),
//                     letterSpacing: 0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Siz $totalQuestions savoldan $correctCount tasiga to\'g\'ri javob berdingiz!',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFF64748B),
//                     fontWeight: FontWeight.w500,
//                     height: 1.4,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   // 'Sizning natijangiz: $percentage%',
//                   'Sizning natijangiz: ${percentage.toInt()}%',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFF64748B),
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 32),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         height: 52,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _showDetailedResultsDialog(results);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF007AFF),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 0,
//                             shadowColor: Colors.transparent,
//                           ),
//                           child: const Text(
//                             'Mening natijalarim',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         height: 52,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             setState(() {
//                               _currentQuestionIndex = 0;
//                               _answers.clear();
//                               _visitedQuestions.clear(); // <-- QO'SHING
//                               _visitedQuestions.add(0); // <-- QO'SHING
//                               _isLoading = true;
//                             });
//                             _loadQuestions();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF007AFF),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 0,
//                             shadowColor: Colors.transparent,
//                           ),
//                           child: const Text(
//                             'Qayta topshirish',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         height: 52,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.popUntil(
//                                 context, (route) => route.isFirst);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF007AFF),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 0,
//                             shadowColor: Colors.transparent,
//                           ),
//                           child: const Text(
//                             'Bosh sahifaga qaytish',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
// // _buildQuestionContentWithImages metodini to'liq almashtiring:
//
//   Widget _buildQuestionContentWithImages(String html) {
//     final base64Pattern = RegExp(
//         r'<img[^>]*src="data:image/[^;]+;base64,([A-Za-z0-9+/=]+)"[^>]*>');
//     final matches = base64Pattern.allMatches(html);
//
//     if (matches.isEmpty) {
//       // Rasmlar yo'q, faqat LaTeX bilan matn
//       return _buildLatexText(html);
//     }
//
//     String textOnly = html.replaceAll(RegExp(r'<img[^>]*>'), '').trim();
//     List<Widget> widgets = [];
//
//     if (textOnly.isNotEmpty && textOnly != '<p></p>') {
//       widgets.add(_buildLatexText(textOnly));
//     }
//
//     for (var match in matches) {
//       final base64String = match.group(1)!;
//
//       try {
//         final imageBytes = base64Decode(base64String);
//
//         widgets.add(
//           Center(
//             child: Container(
//               constraints: const BoxConstraints(
//                 maxWidth: double.infinity,
//                 maxHeight: 300,
//               ),
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.white, width: 1),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.memory(
//                   imageBytes,
//                   fit: BoxFit.contain,
//                   gaplessPlayback: true,
//                   filterQuality: FilterQuality.medium,
//                   errorBuilder: (context, error, stackTrace) {
//                     return const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.broken_image,
//                               size: 40, color: Color(0xFF8E8E93)),
//                           SizedBox(height: 6),
//                           Text(
//                             'Rasmni yuklashda xatolik',
//                             style: TextStyle(
//                               color: Color(0xFF8E8E93),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//
//         if (match != matches.last) {
//           widgets.add(const SizedBox(height: 0));
//         }
//       } catch (e) {
//         debugPrint('Base64 decode error: $e');
//       }
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisSize: MainAxisSize.min,
//       children: widgets,
//     );
//   }
//
// // _buildQuestionText metodini ham yangilang:
//
//   Widget _buildQuestionText(String html) {
//     final base64Pattern = RegExp(
//         r'<img[^>]*src="data:image/[^;]+;base64,([A-Za-z0-9+/=]+)"[^>]*>');
//     final matches = base64Pattern.allMatches(html);
//
//     if (matches.isNotEmpty) {
//       String textOnly = html.replaceAll(RegExp(r'<img[^>]*>'), '').trim();
//
//       List<Widget> widgets = [];
//
//       if (textOnly.isNotEmpty && textOnly != '<p></p>') {
//         widgets.add(_buildLatexText(textOnly));
//       }
//
//       for (var match in matches) {
//         final base64String = match.group(1)!;
//
//         if (!_imageCache.containsKey(base64String)) {
//           _imageCache[base64String] = base64Decode(base64String);
//         }
//
//         widgets.add(
//           Center(
//             child: Container(
//               constraints: const BoxConstraints(
//                 maxWidth: double.infinity,
//                 maxHeight: 450,
//               ),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
//               ),
//               child: Image.memory(
//                 _imageCache[base64String]!,
//                 fit: BoxFit.contain,
//                 gaplessPlayback: true,
//                 filterQuality: FilterQuality.high,
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.broken_image,
//                             size: 48, color: Color(0xFF8E8E93)),
//                         SizedBox(height: 8),
//                         Text(
//                           'Rasmni yuklashda xatolik',
//                           style: TextStyle(color: Color(0xFF8E8E93)),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         );
//
//         if (match != matches.last) {
//           widgets.add(const SizedBox(height: 0));
//         }
//       }
//
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: widgets,
//       );
//     }
//
//     // Rasmlar yo'q - faqat LaTeX bilan matn
//     return _buildLatexText(html);
//   }
//
//   void _showSimpleResultsDialog(
//       int totalQuestions, int correctCount, double percentage) {
//     if (!mounted) return;
//
//     final score = percentage.toInt();
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//           child: Container(
//             padding: const EdgeInsets.all(32),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).pop();
//                       Navigator.of(context).pop();
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       child: const Icon(
//                         Icons.close,
//                         size: 28,
//                         color: Color(0xFF2C3545),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   width: 120,
//                   height: 120,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     clipBehavior: Clip.none,
//                     children: [
//                       Positioned(
//                         bottom: -10,
//                         child: SvgPicture.network(
//                             'https://iqmath.uz/icons/award.svg'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 Text(
//                   'Sizning ballingiz $score',
//                   style: const TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1C2A3A),
//                     letterSpacing: 0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Siz $totalQuestions savoldan $correctCount tasiga to\'g\'ri javob berdingiz!',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFF64748B),
//                     fontWeight: FontWeight.w500,
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Sizning natijangiz: ${percentage.toInt()}%',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFF64748B),
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 40),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         height: 56,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             setState(() {
//                               _currentQuestionIndex = 0;
//                               _answers.clear();
//                               _visitedQuestions.clear();
//                               _visitedQuestions.add(0);
//                               _isLoading = true;
//                             });
//                             _loadQuestions();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF2196F3),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 0,
//                             shadowColor: Colors.transparent,
//                           ),
//                           child: const Text(
//                             'Qayta topshirish',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: SizedBox(
//                         height: 56,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             Navigator.of(context).pop(true);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF4CAF50),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 0,
//                             shadowColor: Colors.transparent,
//                           ),
//                           child: const Text(
//                             'Tavsiya',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: const Center(
//           child: CupertinoActivityIndicator(
//             radius: 12,
//           ),
//         ),
//       );
//     }
//
//     if (_errorMessage != null) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: Text(widget.arguments.taskName ?? ''),
//           backgroundColor: Colors.white,
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline,
//                   size: 64, color: Color(0xFFFF3B30)),
//               const SizedBox(height: 16),
//               Text(
//                 _errorMessage!,
//                 style: const TextStyle(fontSize: 17, color: Color(0xFF8E8E93)),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               FilledButton(
//                 onPressed: () {
//                   setState(() {
//                     _isLoading = true;
//                     _errorMessage = null;
//                   });
//                   _loadQuestions();
//                 },
//                 style: FilledButton.styleFrom(
//                     backgroundColor: const Color(0xFF007AFF)),
//                 child: const Text('Qayta urinish'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (_questions.isEmpty) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: Text(widget.arguments.taskName ?? ''),
//           backgroundColor: Colors.white,
//           leading: SizedBox.shrink(),
//         ),
//         body: const Center(
//           child: Text('Savollar topilmadi',
//               style: TextStyle(fontSize: 17, color: Color(0xFF8E8E93))),
//         ),
//       );
//     }
//
//     final currentQuestion = _questions[_currentQuestionIndex];
//
//     return BlocBuilder<AppBloc, AppState>(
//       builder: (context, state) {
//         print(state.appLocale);
//         return Scaffold(
//           backgroundColor: Colors.white,
//           resizeToAvoidBottomInset: false,
//           appBar: _buildAppBar(),
//           body: Stack(
//             children: [
//               Column(
//                 children: [
//                   _buildProgressBar(),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: _hideKeyboard,
//                       behavior: HitTestBehavior.opaque,
//                       child: SingleChildScrollView(
//                         padding: EdgeInsets.only(
//                           left: 20.0,
//                           right: 20.0,
//                           top: 16.0,
//                           bottom: hasActiveKeyboard ? 400 : 90,
//                         ),
//                         child: Column(
//                           children: [
//                             _buildQuestionWidget(currentQuestion),
//                             const SizedBox(height: 8),
//                             _buildQuestionNavigator(),
//                             const SizedBox(height: 16),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (!hasActiveKeyboard) _buildBottomBar(),
//                 ],
//               ),
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeOutCubic,
//                 left: 0,
//                 right: 0,
//                 bottom: hasActiveKeyboard ? 0 : -400,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD1D1D6),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: const Offset(0, -2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildBottomBar(),
//                       if (hasActiveKeyboard)
//                         Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               height: 320,
//                               color: const Color(0xFFD1D1D6),
//                               child: MathKeyboard(
//                                 controller: _controllers[_activeFieldId]!,
//                                 variables: const [
//                                   '<',
//                                   '>',
//                                   '=',
//                                   'x',
//                                   'y',
//                                   'z',
//                                   'a',
//                                   'b',
//                                   'c',
//                                   'n',
//                                   'm'
//                                 ],
//                                 type: MathKeyboardType.expression,
//                                 onSubmit: () {
//                                   _hideKeyboard();
//                                   _saveCurrentAnswer();
//                                   isLastQuestion
//                                       ? _finishTest()
//                                       : _navigateQuestion(true);
//                                 },
//                               ),
//                             ),
//                             Container(
//                               height: MediaQuery.of(context).padding.bottom,
//                               color: const Color(0xFFD1D1D6),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildQuestionWidget(Map<String, dynamic> question) {
//     final questionType = question['question_type'] as String?;
//
//     switch (questionType) {
//       case 'text':
//         return _buildTextQuestion(question);
//       case 'composite':
//         return _buildCompositeQuestion(question);
//       case 'choice':
//         return _buildChoiceQuestion(question);
//       default:
//         return _buildUnsupportedQuestion(questionType);
//     }
//   }
//
//   Widget _buildUnsupportedQuestion(String? questionType) {
//     return Container(
//       padding: const EdgeInsets.all(24.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 16,
//               offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.warning_amber_rounded,
//               size: 64, color: Color(0xFFFF9500)),
//           const SizedBox(height: 16),
//           const Text(
//             'Qo\'llab-quvvatlanmaydigan savol turi',
//             style: TextStyle(
//               fontSize: 19,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1C1C1E),
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Turi: ${questionType ?? "noma\'lum"}',
//             style: const TextStyle(
//               fontSize: 15,
//               color: Color(0xFF8E8E93),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       backgroundColor: Colors.white,
//       surfaceTintColor: Colors.transparent,
//       automaticallyImplyLeading: false,
//       title: Text(
//         widget.arguments.taskName ?? '',
//         style: const TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF1C1C1E),
//             letterSpacing: -0.4),
//       ),
//       centerTitle: false,
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: const Color(0xFF007AFF).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             '${_currentQuestionIndex + 1}/${_questions.length}',
//             style: const TextStyle(
//                 color: Color(0xFF007AFF),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//                 letterSpacing: -0.3),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProgressBar() {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOutCubic,
//       tween: Tween<double>(
//         begin: _currentQuestionIndex / _questions.length,
//         end: (_currentQuestionIndex + 1) / _questions.length,
//       ),
//       builder: (context, value, _) => Container(
//         height: 3,
//         decoration: BoxDecoration(
//           color: const Color(0xFFE5E5EA),
//           boxShadow: [
//             BoxShadow(
//                 color: const Color(0xFF007AFF).withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2)),
//           ],
//         ),
//         child: FractionallySizedBox(
//           alignment: Alignment.centerLeft,
//           widthFactor: value,
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                   colors: [Color(0xFF007AFF), Color(0xFF5856D6)]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.only(right: 16, left: 16, top: 12, bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border:
//             const Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2)),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         bottom: !hasActiveKeyboard,
//         child: Row(
//           children: [
//             Expanded(child: _buildBackButton()),
//             const SizedBox(width: 12),
//             Expanded(child: _buildNextButton()),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBackButton() {
//     return SizedBox(
//       height: 50,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF5856D6), Color(0xFF007AFF)],
//           ),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//                 color: const Color(0xFF5856D6).withOpacity(0.3),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4)),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: canGoBack
//                 ? () {
//                     _saveCurrentAnswer();
//                     // _hideKeyboard(); // BU QATORNI OLIB TASHLANG
//                     setState(() {
//                       _currentQuestionIndex -= 1;
//                       _visitedQuestions.add(_currentQuestionIndex);
//                     });
//                     Future.delayed(const Duration(milliseconds: 100), () {
//                       _activateFirstField();
//                     });
//                   }
//                 : null,
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.arrow_back_ios_rounded,
//                     size: 16,
//                     color: canGoBack
//                         ? Colors.white
//                         : Colors.white.withOpacity(0.5),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Orqaga',
//                     style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: -0.3,
//                         color: canGoBack
//                             ? Colors.white
//                             : Colors.white.withOpacity(0.5)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNextButton() {
//     return SizedBox(
//       height: 50,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//               colors: [Color(0xFF007AFF), Color(0xFF5856D6)]),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//                 color: const Color(0xFF007AFF).withOpacity(0.3),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4)),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () {
//               _saveCurrentAnswer();
//               // _hideKeyboard(); // BU QATORNI OLIB TASHLANG
//               if (isLastQuestion) {
//                 _hideKeyboard(); // Faqat tugatishda yopamiz
//                 _finishTest();
//               } else {
//                 setState(() {
//                   _currentQuestionIndex += 1;
//                   _visitedQuestions.add(_currentQuestionIndex);
//                 });
//                 Future.delayed(const Duration(milliseconds: 100), () {
//                   _activateFirstField();
//                 });
//               }
//             },
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     isLastQuestion ? 'Tugatish' : 'Keyingi',
//                     style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: -0.3,
//                         color: Colors.white),
//                   ),
//                   const SizedBox(width: 8),
//                   Icon(
//                     isLastQuestion
//                         ? Icons.check_circle_rounded
//                         : Icons.arrow_forward_ios_rounded,
//                     size: 16,
//                     color: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextQuestion(Map<String, dynamic> question) {
//     final questionId = question['id'] as int?;
//     final questionText = question['question_text_uz'] as String? ?? '';
//
//     if (questionId == null) return const SizedBox.shrink();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         _buildQuestionBadge('text'),
//         const SizedBox(height: 6),
//         _buildQuestionText(questionText),
//         const SizedBox(height: 6),
//         _buildMathFieldInput(questionId), // compositeQuestionId yo'q
//       ],
//     );
//   }
//
//   Widget _buildCompositeQuestion(Map<String, dynamic> question) {
//     final questionId = question['id'] as int?;
//     final questionText = question['question_text_uz'] as String? ?? '';
//     final subQuestions = question['sub_questions'] as List<dynamic>? ?? [];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         _buildQuestionBadge('composite'),
//         const SizedBox(height: 6),
//         _buildQuestionText(questionText),
//         const SizedBox(height: 6),
//         ...subQuestions.asMap().entries.map((entry) {
//           final index = entry.key;
//           final sq = entry.value as Map<String, dynamic>;
//           return Column(
//             children: [
//               _buildSubQuestion(sq, questionId!),
//               if (index < subQuestions.length - 1) const SizedBox(height: 6),
//             ],
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildChoiceQuestion(Map<String, dynamic> question) {
//     final questionId = question['id'] as int?;
//     final questionText = question['question_text_uz'] as String? ?? '';
//     final choices = question['choices'] as List<dynamic>? ?? [];
//     final questionCategory = question['question_category'] as String?;
//
//     if (questionId == null) return const SizedBox.shrink();
//
//     final isRadioButton = questionCategory == 'radio_button';
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         _buildQuestionBadge('choice'),
//         const SizedBox(height: 6),
//         _buildQuestionText(questionText),
//         const SizedBox(height: 6),
//         ...choices.map((choice) {
//           final choiceData = choice as Map<String, dynamic>;
//           final choiceId = choiceData['id'] as int;
//           final choiceLetter = choiceData['letter'] as String? ?? '';
//           final choiceText = choiceData['text_uz'] as String? ?? '';
//
//           return _buildChoiceOption(
//             questionId,
//             choiceId,
//             choiceLetter,
//             choiceText,
//             isRadioButton,
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildChoiceOption(int questionId, int choiceId, String letter,
//       String text, bool isRadioButton) {
//     final isSelected = _answers[questionId] == choiceId.toString();
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 6),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             setState(() {
//               if (isRadioButton) {
//                 _answers[questionId] = choiceId.toString();
//               } else {
//                 if (isSelected) {
//                   _answers.remove(questionId);
//                 } else {
//                   _answers[questionId] = choiceId.toString();
//                 }
//               }
//             });
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? const Color(0xFF007AFF).withOpacity(0.1)
//                   : const Color(0xFFF5F5F7),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: isSelected
//                     ? const Color(0xFF007AFF)
//                     : const Color(0xFFE5E5EA),
//                 width: isSelected ? 2 : 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: isSelected ? const Color(0xFF007AFF) : Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isSelected
//                           ? const Color(0xFF007AFF)
//                           : const Color(0xFFE5E5EA),
//                       width: 2,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       letter,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color:
//                             isSelected ? Colors.white : const Color(0xFF1C1C1E),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     text,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight:
//                           isSelected ? FontWeight.w600 : FontWeight.w400,
//                       color: const Color(0xFF1C1C1E),
//                     ),
//                   ),
//                 ),
//                 if (isSelected)
//                   const Icon(
//                     Icons.check_circle_rounded,
//                     color: Color(0xFF007AFF),
//                     size: 22,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuestionBadge(String type) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: const Color(0xFF007AFF).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         'Savol ${_currentQuestionIndex + 1}',
//         style: const TextStyle(
//           color: Color(0xFF007AFF),
//           fontWeight: FontWeight.w600,
//           fontSize: 13,
//           letterSpacing: -0.2,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMathFieldInput(int id, {int? compositeQuestionId}) {
//     final controller = _controllers[id];
//     final focusNode = _focusNodes[id];
//     if (controller == null || focusNode == null) return const SizedBox.shrink();
//
//     final isActive = _activeFieldId == id;
//     final hasValue = controller.currentEditingValue().isNotEmpty &&
//         controller.currentEditingValue() != r'\Box';
//
//     // Agar composite savol ichida bo'lsa va boshqa sub-question'larga javob berilgan bo'lsa
//     bool shouldHighlightEmpty = false;
//     if (compositeQuestionId != null && !hasValue) {
//       shouldHighlightEmpty = _hasAnySubAnswer(compositeQuestionId);
//     }
//
//     // Composite savol ichida bo'lsa kichikroq, aks holda kattaroq
//     final minHeight = compositeQuestionId != null ? 56.0 : 100.0;
//     final maxHeight = compositeQuestionId != null ? 120.0 : 200.0;
//
//     return GestureDetector(
//       onTap: () => _showKeyboard(id),
//       behavior: HitTestBehavior.opaque,
//       child: AbsorbPointer(
//         absorbing: true,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             minHeight: minHeight,
//             maxHeight: maxHeight,
//           ),
//           child: IntrinsicHeight(
//             child: MathField(
//               controller: controller,
//               focusNode: focusNode,
//               opensKeyboard: false,
//               autofocus: true,
//               variables: const [
//                 '<',
//                 '>',
//                 '=',
//                 'x',
//                 'y',
//                 'z',
//                 'a',
//                 'b',
//                 'c',
//                 'n',
//                 'm'
//               ],
//               keyboardType: MathKeyboardType.expression,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(16)),
//                   borderSide: BorderSide(
//                     color: shouldHighlightEmpty
//                         ? const Color(0xFFFF3B30)
//                         : hasValue
//                             ? const Color(0xFF34C759)
//                             : isActive
//                                 ? const Color(0xFF007AFF)
//                                 : const Color(0xFFE5E5EA),
//                     width:
//                         isActive || hasValue || shouldHighlightEmpty ? 2 : 1.5,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(16)),
//                   borderSide: BorderSide(
//                     color: shouldHighlightEmpty
//                         ? const Color(0xFFFF3B30)
//                         : hasValue
//                             ? const Color(0xFF34C759)
//                             : const Color(0xFFE5E5EA),
//                     width: hasValue || shouldHighlightEmpty ? 2 : 1.5,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(16)),
//                   borderSide: BorderSide(
//                     color: shouldHighlightEmpty
//                         ? const Color(0xFFFF3B30)
//                         : const Color(0xFF007AFF),
//                     width: 2,
//                   ),
//                 ),
//                 hintText: 'Javobni kiriting',
//                 hintStyle: TextStyle(
//                   color: shouldHighlightEmpty
//                       ? const Color(0xFFFF3B30).withOpacity(0.7)
//                       : const Color(0xFF8E8E93),
//                   fontSize: 16,
//                 ),
//                 contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
//                 filled: true,
//                 fillColor: shouldHighlightEmpty
//                     ? const Color(0xFFFF3B30).withOpacity(0.05)
//                     : isActive
//                         ? const Color(0xFF007AFF).withOpacity(0.05)
//                         : Colors.white,
//               ),
//               onChanged: (value) {},
//               onSubmitted: (value) {
//                 _saveCurrentAnswer();
//                 if (isLastQuestion) {
//                   _finishTest();
//                 } else {
//                   _navigateQuestion(true);
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   bool _hasAnySubAnswer(int compositeQuestionId) {
//     final answer = _answers[compositeQuestionId];
//     if (answer == null || answer is! Map) return false;
//
//     for (var value in answer.values) {
//       if (value is String && value.isNotEmpty && value != r'\Box') {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   bool _isSubQuestionAnswered(int compositeQuestionId, int subQuestionId) {
//     final answer = _answers[compositeQuestionId];
//     if (answer == null || answer is! Map) return false;
//
//     final subAnswer = answer[subQuestionId];
//     return subAnswer is String && subAnswer.isNotEmpty && subAnswer != r'\Box';
//   }
//
//   Widget _buildSubQuestion(
//       Map<String, dynamic> subQuestion, int compositeQuestionId) {
//     final id = subQuestion['id'] as int?;
//     final text1 = subQuestion['text1_uz'] as String? ?? '';
//     final text2 = subQuestion['text2_uz'] as String? ?? '';
//
//     if (id == null) return const SizedBox.shrink();
//
//     return _buildLabeledInput(id, text1, text2,
//         compositeQuestionId: compositeQuestionId);
//   }
//
//   Widget _buildLabeledInput(int id, String label, String unit,
//       {int? compositeQuestionId}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (label.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 if (unit.isNotEmpty) ...[
//                   const SizedBox(width: 6),
//                   Text(
//                     '($unit)',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF8E8E93),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         if (unit.isNotEmpty && label.isEmpty)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Text(
//               'Birlik: $unit',
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF8E8E93),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         _buildMathFieldInput(id, compositeQuestionId: compositeQuestionId),
//       ],
//     );
//   }
//
//   Widget _buildQuestionNavigator() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Savollar',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1C1C1E),
//               letterSpacing: -0.3,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Wrap(
//             spacing: 6,
//             runSpacing: 6,
//             children: List.generate(_questions.length, (index) {
//               final question = _questions[index];
//               final questionId = question['id'] as int?;
//               final questionType = question['question_type'] as String?;
//
//               bool isAnswered = false;
//               bool isPartiallyAnswered = false;
//
//               if (questionId != null && _answers.containsKey(questionId)) {
//                 final answer = _answers[questionId];
//
//                 if (questionType == 'composite') {
//                   // Composite savol uchun
//                   final subQuestions =
//                       question['sub_questions'] as List<dynamic>? ?? [];
//                   int answeredCount = 0;
//
//                   if (answer is Map) {
//                     for (var subQ in subQuestions) {
//                       final subId = subQ['id'] as int;
//                       final subAnswer = answer[subId];
//                       if (subAnswer is String &&
//                           subAnswer.isNotEmpty &&
//                           subAnswer != r'\Box') {
//                         answeredCount++;
//                       }
//                     }
//                   }
//
//                   if (answeredCount == subQuestions.length) {
//                     isAnswered = true; // Hammasi to'ldirilgan
//                   } else if (answeredCount > 0) {
//                     isPartiallyAnswered = true; // Qisman to'ldirilgan
//                   }
//                 } else {
//                   // Text yoki Choice savol uchun
//                   if (answer is String &&
//                       answer.isNotEmpty &&
//                       answer != r'\Box') {
//                     isAnswered = true;
//                   } else if (answer is Map && answer.isNotEmpty) {
//                     isAnswered = true;
//                   }
//                 }
//               }
//
//               final isCurrentQuestion = index == _currentQuestionIndex;
//               final isVisited = _visitedQuestions.contains(index);
//               final isSkipped =
//                   isVisited && !isAnswered && !isPartiallyAnswered;
//
//               // Ranglarni aniqlash
//               Color backgroundColor;
//               Color borderColor;
//               Color textColor;
//
//               if (isCurrentQuestion) {
//                 // Hozirgi savol - ko'k
//                 backgroundColor = const Color(0xFF007AFF);
//                 borderColor = const Color(0xFF007AFF);
//                 textColor = Colors.white;
//               } else if (isAnswered) {
//                 // To'liq to'ldirilgan - yashil
//                 backgroundColor = const Color(0xFF34C759).withOpacity(0.1);
//                 borderColor = const Color(0xFF34C759);
//                 textColor = const Color(0xFF34C759);
//               } else if (isPartiallyAnswered || isSkipped) {
//                 // Qisman to'ldirilgan yoki ko'rilgan lekin to'ldirilmagan - qizil
//                 backgroundColor = const Color(0xFFFF3B30).withOpacity(0.1);
//                 borderColor = const Color(0xFFFF3B30);
//                 textColor = const Color(0xFFFF3B30);
//               } else {
//                 // Hali ko'rilmagan - oq
//                 backgroundColor = Colors.white;
//                 borderColor = const Color(0xFFE5E5EA);
//                 textColor = const Color(0xFF1C1C1E);
//               }
//
//               return GestureDetector(
//                 onTap: () {
//                   _saveCurrentAnswer();
//                   // _hideKeyboard(); // BU QATORNI OLIB TASHLANG
//                   setState(() {
//                     _currentQuestionIndex = index;
//                     _visitedQuestions.add(index);
//                   });
//
//                   Future.delayed(const Duration(milliseconds: 100), () {
//                     _activateFirstField();
//                   });
//                 },
//                 child: Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: backgroundColor,
//                     border: Border.all(
//                       color: borderColor,
//                       width: isCurrentQuestion ? 2 : 1.5,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${index + 1}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: textColor,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Map<String, dynamic>? _lastCheckAnswerResponse;
//
//   void _showDetailedResultsDialog(Map<String, dynamic> results) {
//     final questionResults = results['question'] as List<dynamic>? ?? [];
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.85,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const Expanded(
//                       child: Text(
//                         'Mening natijalarim',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.black),
//                       onPressed: () => Navigator.of(context).pop(),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                   ],
//                 ),
//               ),
//               Flexible(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: questionResults.length,
//                   itemBuilder: (context, index) {
//                     final result = questionResults[index];
//                     final questionIndex = result['index'] as int;
//                     final isCorrect = result['answer'] == true;
//                     final questionText = result['question_uz'] as String? ?? '';
//
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: isCorrect
//                             ? const Color(0xFF34C759).withOpacity(0.1)
//                             : const Color(0xFFFF3B30).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: isCorrect
//                               ? const Color(0xFF34C759)
//                               : const Color(0xFFFF3B30),
//                           width: 2,
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 32,
//                                 height: 32,
//                                 decoration: BoxDecoration(
//                                   color: isCorrect
//                                       ? const Color(0xFF34C759)
//                                       : const Color(0xFFFF3B30),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     '$questionIndex',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   isCorrect ? 'To\'g\'ri' : 'Noto\'g\'ri',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: isCorrect
//                                         ? const Color(0xFF34C759)
//                                         : const Color(0xFFFF3B30),
//                                   ),
//                                 ),
//                               ),
//                               Icon(
//                                 isCorrect ? Icons.check_circle : Icons.cancel,
//                                 color: isCorrect
//                                     ? const Color(0xFF34C759)
//                                     : const Color(0xFFFF3B30),
//                                 size: 28,
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           _buildQuestionContentWithImages(questionText),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     top: BorderSide(color: Color(0xFFE5E5EA), width: 1),
//                   ),
//                 ),
//                 child: SafeArea(
//                   top: false,
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => _sendToMentor(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF007AFF),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'Mentorga yuborish',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _sendToMentor() async {
//     if (_lastCheckAnswerResponse == null) {
//       TopNotification.showError(
//         context,
//         message: 'Natijalar topilmadi',
//         title: 'Xatolik',
//       );
//       return;
//     }
//
//     // Loading ko'rsatish
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(
//         child: CircularProgressIndicator(color: Color(0xFF007AFF)),
//       ),
//     );
//
//     var token = sl<LocalSource>().getAccessToken();
//
//     try {
//       final response = await http.post(
//         Uri.parse(
//             'https://api.iqmath.uz/api/v1/func_student/student-independent/'),
//         headers: {
//           'Authorization': '$token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(_lastCheckAnswerResponse),
//       );
//
//       alice.onHttpResponse(response);
//
//       if (mounted) {
//         Navigator.of(context).pop(); // Loading dialogni yopish
//       }
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         final success = data['success'] as bool? ?? false;
//         final message = data['message'] as String? ?? '';
//         final telegramLink = data['telegram_link'] as String? ?? '';
//
//         if (success && telegramLink.isNotEmpty) {
//           _showTelegramBotDialog(message, telegramLink);
//         } else {
//           TopNotification.showError(
//             context,
//             message: message.isNotEmpty ? message : 'Xatolik yuz berdi',
//             title: 'Xatolik',
//           );
//         }
//       } else {
//         TopNotification.showError(
//           context,
//           message: 'Server xatoligi: ${response.statusCode}',
//           title: 'Xatolik',
//         );
//       }
//     } catch (e) {
//       debugPrint('Send to mentor error: $e');
//       if (mounted) {
//         Navigator.of(context).pop(); // Loading dialogni yopish
//         TopNotification.showError(
//           context,
//           message: 'Tarmoq xatoligi: $e',
//           title: 'Xatolik',
//         );
//       }
//     }
//   }
//
//   void _showTelegramBotDialog(String message, String telegramLink) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF007AFF).withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.telegram,
//                   size: 48,
//                   color: Color(0xFF007AFF),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 message,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF1C1C1E),
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     int count = 0;
//                     Navigator.popUntil(context, (route) {
//                       count++;
//                       return count == 7;
//                     });
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       Navigator.pop(context, 'Telegram');
//                     });
//                     // // Telegram botni ochish
//                     // // URL launcher ishlatish kerak
//                     // debugPrint('Telegram link: $telegramLink');
//                     // BaseFunctions.launchUrlStart(url: telegramLink);
//                     //
//                     // // Dialoglarni yopish va testni reset qilish
//                     // Navigator.of(context).pop(); // Telegram dialog
//                     // Navigator.of(context).pop(); // Detailed results dialog
//                     // Navigator.of(context).pop(); // Main results dialog
//                     //
//                     // // Testni qayta boshlash
//                     // setState(() {
//                     //   _currentQuestionIndex = 0;
//                     //   _answers.clear();
//                     //   _lastCheckAnswerResponse = null;
//                     //   _isLoading = true;
//                     // });
//                     // _loadQuestions();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF007AFF),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Botga o\'tish',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/widgets/top_notification.dart';
import 'package:my_flutter_template/features/subject/presentation/localization/subject_localization.dart';
import 'package:my_flutter_template/features/subject/presentation/mixin/question_mixin.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/topic_card.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../../../diagnostics/presentation/diagnostic_texts.dart';
import '../../../diagnostics/presentation/pages/diagnostic_results_page.dart';
import '../../../home/presentation/pages/home_parent/widget/parent_assimilation_page.dart';

class QuestionPage extends StatefulWidget {
  final QuestionPageArguments arguments;

  const QuestionPage({
    super.key,
    required this.arguments,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> with QuestionMixin {
  List<dynamic> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  final Map<int, dynamic> _answers = {};
  final Map<int, MathFieldEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  final Map<String, Uint8List> _imageCache = {};
  int? _activeFieldId;
  final Set<int> _visitedQuestions = {};
  String? _currentLocale;
  Map<String, dynamic>? _lastCheckAnswerResponse;

  @override
  void initState() {
    super.initState();
    _visitedQuestions.add(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentLocale = context.read<AppBloc>().state.appLocale ?? 'uz';
      _loadQuestions();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _imageCache.clear();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    var token = sl<LocalSource>().getAccessToken();
    try {
      final response = widget.arguments.isDiagnostic
          ? await http.post(
              Uri.parse(
                  'https://api.iqmath.uz/api/v1/func_student/my-generate-test/'),
              headers: {
                'Authorization': '$token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'level': 1,
                'subject_id': widget.arguments.subjectId,
              }),
            )
          : await http.get(
              Uri.parse(
                  'https://api.iqmath.uz/api/v1/func_student/my-question/${widget.arguments.topic?.id}/?level=${1}'),
              headers: {
                'Authorization': '$token',
              },
            );

      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        debugPrint(response.body);
        final data = jsonDecode(response.body);
        setState(() {
          _questions = data['questions'] ?? [];
          _isLoading = false;
          _initializeControllers();
        });
      } else {
        setState(() {
          _errorMessage = 'error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'network';
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    for (var question in _questions) {
      final questionType = question['question_type'] as String?;

      switch (questionType) {
        case 'text':
          _createController(question['id'] as int);
          break;

        case 'composite':
          final subQuestions = question['sub_questions'] as List<dynamic>?;
          if (subQuestions != null) {
            for (var subQuestion in subQuestions) {
              final subId = subQuestion['id'] as int;
              _createController(subId);
            }
          }
          break;

        case 'choice':
          break;

        default:
          debugPrint('Noma\'lum question type: $questionType');
      }
    }
  }

  void _createController(int id) {
    _controllers[id] = MathFieldEditingController();
    _focusNodes[id] = FocusNode();

    _focusNodes[id]!.addListener(() {
      if (_focusNodes[id]!.hasFocus) {
        setState(() {
          _activeFieldId = id;
        });
      } else {
        if (_activeFieldId == id) {
          setState(() {
            _activeFieldId = null;
          });
        }
      }
    });
  }

  void _hideKeyboard() {
    for (var focusNode in _focusNodes.values) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
    }
    if (mounted) {
      setState(() {
        _activeFieldId = null;
      });
    }
    FocusScope.of(context).unfocus();
  }

  void _showKeyboard(int id) {
    for (var focusNode in _focusNodes.values) {
      focusNode.unfocus();
    }

    setState(() {
      _activeFieldId = id;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      _focusNodes[id]?.requestFocus();
    });
  }

  bool get canGoBack => _currentQuestionIndex > 0;

  bool get canGoNext => _currentQuestionIndex < _questions.length - 1;

  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;

  bool get hasActiveKeyboard => _activeFieldId != null;

  String _convertToLatex(String input) {
    if (input.isEmpty || input == r'\Box') return '';
    if (input.startsWith(r'\(') && input.endsWith(r'\)')) {
      return input;
    }
    return r'\(' + input + r'\)';
  }

  void _saveCurrentAnswer() {
    if (_questions.isEmpty) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final questionType = currentQuestion['question_type'] as String?;

    switch (questionType) {
      case 'text':
        _saveTextAnswer(currentQuestion['id'] as int?);
        break;
      case 'composite':
        _saveCompositeAnswer(currentQuestion);
        break;
      case 'choice':
        break;
      default:
        debugPrint('Noma\'lum question type: $questionType');
    }
  }

  void _saveTextAnswer(int? id) {
    if (id == null) return;
    final controller = _controllers[id];
    if (controller != null) {
      final text = controller.currentEditingValue();
      if (text.isNotEmpty && text != r'\Box') {
        _answers[id] = _convertToLatex(text);
      } else {
        _answers.remove(id);
      }
    }
  }

  void _saveCompositeAnswer(Map<String, dynamic> question) {
    final questionId = question['id'] as int?;
    if (questionId == null) return;

    final subQuestions = question['sub_questions'] as List<dynamic>?;
    if (subQuestions == null) return;

    Map<int, String> compositeAnswer = {};
    bool hasAnyAnswer = false;

    for (var subQuestion in subQuestions) {
      final subQuestionId = subQuestion['id'] as int;
      final controller = _controllers[subQuestionId];

      if (controller != null) {
        final text = controller.currentEditingValue();
        if (text.isNotEmpty && text != r'\Box') {
          compositeAnswer[subQuestionId] = _convertToLatex(text);
          hasAnyAnswer = true;
        }
      }
    }

    if (hasAnyAnswer) {
      _answers[questionId] = compositeAnswer;
    } else {
      _answers.remove(questionId);
    }
  }

  void _navigateQuestion(bool forward) {
    _saveCurrentAnswer();
    setState(() {
      _currentQuestionIndex += forward ? 1 : -1;
      _visitedQuestions.add(_currentQuestionIndex);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _activateFirstField();
    });
  }

  void _activateFirstField() {
    if (!mounted || _questions.isEmpty) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final questionType = currentQuestion['question_type'] as String?;

    int? firstFieldId;

    switch (questionType) {
      case 'text':
        firstFieldId = currentQuestion['id'] as int?;
        break;
      case 'composite':
        final subQuestions = currentQuestion['sub_questions'] as List<dynamic>?;
        if (subQuestions != null && subQuestions.isNotEmpty) {
          firstFieldId = subQuestions[0]['id'] as int?;
        }
        break;
      case 'choice':
        _hideKeyboard();
        return;
      default:
        return;
    }

    if (firstFieldId != null && _activeFieldId != null) {
      setState(() {
        _activeFieldId = firstFieldId;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _focusNodes[firstFieldId]?.requestFocus();
      });
    } else if (firstFieldId != null && _activeFieldId == null) {
      _showKeyboard(firstFieldId);
    }
  }

  Future<void> _finishTest() async {
    _saveCurrentAnswer();
    _hideKeyboard();
    await _checkAnswers();
  }

  Future<void> _checkAnswers() async {
    if (!mounted) return;

    final locale = context.read<AppBloc>().state.appLocale ?? 'uz';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF007AFF)),
      ),
    );

    var token = sl<LocalSource>().getAccessToken();

    List<Map<String, dynamic>> textAnswers = [];
    List<Map<String, dynamic>> choiceAnswers = [];
    List<Map<String, dynamic>> compositeAnswers = [];

    for (var question in _questions) {
      final questionType = question['question_type'] as String?;
      final questionId = question['id'] as int;

      switch (questionType) {
        case 'text':
          final answer = _answers[questionId];
          String answerText = '';
          if (answer != null &&
              answer is String &&
              answer.isNotEmpty &&
              answer != r'\Box') {
            answerText = answer;
          }
          textAnswers.add({
            'question_id': questionId,
            'answer_uz': answerText,
          });
          break;

        case 'composite':
          final compositeAnswer = _answers[questionId];
          List<String> answers = [];
          final subQuestions = question['sub_questions'] as List<dynamic>?;
          if (subQuestions != null) {
            for (var subQuestion in subQuestions) {
              final subId = subQuestion['id'] as int;
              String subAnswerText = '';
              if (compositeAnswer != null && compositeAnswer is Map) {
                final subAnswer = compositeAnswer[subId];
                if (subAnswer != null &&
                    subAnswer is String &&
                    subAnswer.isNotEmpty &&
                    subAnswer != r'\Box') {
                  subAnswerText = subAnswer;
                }
              }
              answers.add(subAnswerText);
            }
          }
          compositeAnswers.add({
            'question_id': questionId,
            'answers': answers,
          });
          break;

        case 'choice':
        case 'image_choice':
          final answer = _answers[questionId];
          if (answer != null && answer is String && answer.isNotEmpty) {
            choiceAnswers.add({
              'question_id': questionId,
              'choices': [int.tryParse(answer) ?? 0],
            });
          }
          break;
      }
    }

    final requestBody = {
      'text_answers': textAnswers,
      'choice_answers': choiceAnswers,
      'composite_answers': compositeAnswers,
    };

    try {
      final apiUrl = widget.arguments.isDiagnostic
          ? 'https://api.iqmath.uz/api/v1/func_student/my-generate-check-answer/'
          : 'https://api.iqmath.uz/api/v1/func_student/my-check-answer/';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      alice.onHttpResponse(response);
      _lastCheckAnswerResponse = jsonDecode(response.body);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        int correctCount = 0;
        int incorrectCount = 0;
        int answeredCount = 0;

        final questionResults = data['question'] as List<dynamic>? ?? [];
        for (var result in questionResults) {
          final answer = result['answer'];
          if (answer == true) {
            correctCount++;
            answeredCount++;
          } else if (answer == false) {
            incorrectCount++;
            answeredCount++;
          }
        }

        final totalQuestions = _questions.length;

        final resultData = data['result'] as List<dynamic>? ?? [];
        double score = 0.0;
        if (resultData.isNotEmpty) {
          score = (resultData[0]['score'] as num?)?.toDouble() ?? 0.0;
        }

        if (widget.arguments.isDiagnostic) {
          _showSimpleResultsDialog(totalQuestions, correctCount, score, locale);
        } else {
          _showResultsDialog(totalQuestions, answeredCount, correctCount,
              incorrectCount, data, score, locale);
        }
      } else if (response.statusCode == 400) {
        TopNotification.showError(
          context,
          message: jsonDecode(response.body)['message'].toString(),
          title: QuestionPageTranslations.t('completeTest', locale),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _cleanHtmlEntities(String text) {
    return text
    // Common spaces and separators
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ')
        .replaceAll('&ensp;', ' ')
        .replaceAll('&emsp;', ' ')
        .replaceAll('&thinsp;', ' ')

    // Quotes
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8217;', "'")

    // Mathematical and special symbols
        .replaceAll('&bull;', '•')    // Bullet point
        .replaceAll('&#8226;', '•')   // Bullet point
        .replaceAll('&middot;', '·')  // Middle dot
        .replaceAll('&#183;', '·')    // Middle dot
        .replaceAll('&times;', '×')   // Multiplication sign
        .replaceAll('&#215;', '×')    // Multiplication sign
        .replaceAll('&divide;', '÷')  // Division sign
        .replaceAll('&#247;', '÷')    // Division sign
        .replaceAll('&plusmn;', '±')  // Plus-minus
        .replaceAll('&#177;', '±')    // Plus-minus
        .replaceAll('&minus;', '−')   // Minus sign
        .replaceAll('&#8722;', '−')   // Minus sign

    // Comparison operators
        .replaceAll('&lt;', '<')
        .replaceAll('&#60;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#62;', '>')
        .replaceAll('&le;', '≤')
        .replaceAll('&#8804;', '≤')
        .replaceAll('&ge;', '≥')
        .replaceAll('&#8805;', '≥')
        .replaceAll('&ne;', '≠')
        .replaceAll('&#8800;', '≠')

    // Other common symbols
        .replaceAll('&amp;', '&')
        .replaceAll('&#38;', '&')
        .replaceAll('&deg;', '°')     // Degree symbol
        .replaceAll('&#176;', '°')    // Degree symbol
        .replaceAll('&frac12;', '½')
        .replaceAll('&frac14;', '¼')
        .replaceAll('&frac34;', '¾')

    // Dashes
        .replaceAll('&ndash;', '–')   // En dash
        .replaceAll('&#8211;', '–')   // En dash
        .replaceAll('&mdash;', '—')   // Em dash
        .replaceAll('&#8212;', '—')   // Em dash

    // Greek letters (common in math)
        .replaceAll('&alpha;', 'α')
        .replaceAll('&beta;', 'β')
        .replaceAll('&gamma;', 'γ')
        .replaceAll('&delta;', 'δ')
        .replaceAll('&pi;', 'π')
        .replaceAll('&theta;', 'θ')
        .replaceAll('&lambda;', 'λ')
        .replaceAll('&mu;', 'μ')
        .replaceAll('&sigma;', 'σ')
        .replaceAll('&omega;', 'ω')

    // Remove any remaining unprocessed HTML entities (fallback)
        .replaceAllMapped(
      RegExp(r'&[a-zA-Z]+;'),
          (match) => '', // or you could return the original if you prefer
    )

        .trim();
  }

  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<p>'), '')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  Widget _buildLatexText(String text) {
    final cleanedText = _cleanHtmlEntities(_stripHtmlTags(text));
    final latexPattern = RegExp(r'\\\((.*?)\\\)|\\\[(.*?)\\\]');
    final matches = latexPattern.allMatches(cleanedText);

    if (matches.isEmpty) {
      return Text(
        cleanedText,
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFF1C1C1E),
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        final plainText = cleanedText.substring(lastIndex, match.start);
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(
            text: plainText,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF1C1C1E),
              height: 1.5,
            ),
          ));
        }
      }

      final latexCode = match.group(1) ?? match.group(2) ?? '';
      if (latexCode.isNotEmpty) {
        try {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Math.tex(
                latexCode,
                textStyle: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFF1C1C1E),
                ),
                mathStyle: MathStyle.text,
              ),
            ),
          ));
        } catch (e) {
          spans.add(TextSpan(
            text: latexCode,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFFFF3B30),
              height: 1.5,
            ),
          ));
          debugPrint('LaTeX parse error: $e');
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < cleanedText.length) {
      final remainingText = cleanedText.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(
          text: remainingText,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF1C1C1E),
            height: 1.5,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildQuestionContentWithImages(String html) {
    final base64Pattern = RegExp(
        r'<img[^>]*src="data:image/[^;]+;base64,([A-Za-z0-9+/=]+)"[^>]*>');
    final matches = base64Pattern.allMatches(html);

    if (matches.isEmpty) {
      return _buildLatexText(html);
    }

    String textOnly = html.replaceAll(RegExp(r'<img[^>]*>'), '').trim();
    List<Widget> widgets = [];

    if (textOnly.isNotEmpty && textOnly != '<p></p>') {
      widgets.add(_buildLatexText(textOnly));
    }

    for (var match in matches) {
      final base64String = match.group(1)!;

      try {
        final imageBytes = base64Decode(base64String);

        widgets.add(
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: double.infinity,
                maxHeight: 300,
              ),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image,
                              size: 40, color: Color(0xFF8E8E93)),
                          SizedBox(height: 6),
                          Text(
                            'Rasmni yuklashda xatolik',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        if (match != matches.last) {
          widgets.add(const SizedBox(height: 0));
        }
      } catch (e) {
        debugPrint('Base64 decode error: $e');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget _buildQuestionText(String html) {
    final base64Pattern = RegExp(
        r'<img[^>]*src="data:image/[^;]+;base64,([A-Za-z0-9+/=]+)"[^>]*>');
    final matches = base64Pattern.allMatches(html);

    if (matches.isNotEmpty) {
      String textOnly = html.replaceAll(RegExp(r'<img[^>]*>'), '').trim();

      List<Widget> widgets = [];

      if (textOnly.isNotEmpty && textOnly != '<p></p>') {
        widgets.add(_buildLatexText(textOnly));
      }

      for (var match in matches) {
        final base64String = match.group(1)!;

        if (!_imageCache.containsKey(base64String)) {
          _imageCache[base64String] = base64Decode(base64String);
        }

        widgets.add(
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: double.infinity,
                maxHeight: 450,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
              ),
              child: Image.memory(
                _imageCache[base64String]!,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image,
                            size: 48, color: Color(0xFF8E8E93)),
                        SizedBox(height: 8),
                        Text(
                          'Rasmni yuklashda xatolik',
                          style: TextStyle(color: Color(0xFF8E8E93)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        if (match != matches.last) {
          widgets.add(const SizedBox(height: 0));
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      );
    }

    return _buildLatexText(html);
  }

  void _showResultsDialog(
      int totalQuestions,
      int answeredCount,
      int correctCount,
      int incorrectCount,
      Map<String, dynamic> results,
      double score,
      String? locale) {
    if (!mounted) return;

    final percentage = score.toInt();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close,
                        size: 28, color: Color(0xFF2C3545)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        bottom: -10,
                        child: SvgPicture.network(
                            'https://iqmath.uz/icons/award.svg'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '${QuestionPageTranslations.t('yourScore', locale)} $correctCount',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a2e),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  QuestionPageTranslations.t('youAnswered', locale, params: {
                    'total': totalQuestions,
                    'correct': correctCount
                  }),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${QuestionPageTranslations.t('yourResult', locale)}: ${percentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            _showDetailedResultsDialog(results, locale);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            QuestionPageTranslations.t('myResults', locale),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _currentQuestionIndex = 0;
                              _answers.clear();
                              _visitedQuestions.clear();
                              _visitedQuestions.add(0);
                              _isLoading = true;
                            });
                            _loadQuestions();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            QuestionPageTranslations.t('retake', locale),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            QuestionPageTranslations.t('backToHome', locale),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
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
        ),
      ),
    );
  }

  /// Diagnostika testi natijasi — saytdagi DiagnosticResultModal:
  /// natija kartasi va "Qayta topshirish" / "Natijalarim" tugmalari.
  void _showSimpleResultsDialog(
      int totalQuestions, int correctCount, double percentage, String? locale) {
    if (!mounted) return;

    final percent = percentage.round();
    final wrongCount = math.max(totalQuestions - correctCount, 0);
    String t(String key, [Map<String, Object>? args]) =>
        DiagnosticTexts.get(locale, key, args);

    void retake(BuildContext dialogContext) {
      Navigator.of(dialogContext).pop();
      setState(() {
        _currentQuestionIndex = 0;
        _answers.clear();
        _visitedQuestions.clear();
        _visitedQuestions.add(0);
        _isLoading = true;
      });
      _loadQuestions();
    }

    void openResults(BuildContext dialogContext) {
      Navigator.of(dialogContext).pop();
      Navigator.of(context).pushReplacementNamed(
        Routes.diagnosticResults,
        arguments: DiagnosticResultsArgs(
          subjectId: widget.arguments.subjectId ?? '',
          title: widget.arguments.taskName,
        ),
      );
    }

    Widget statRow(IconData icon, Color color, String label, int value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF3B4257)),
              ),
            ),
            Text(
              '$value ${t('pcs')}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2A4A),
              ),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 26, color: Color(0xFF2C3545)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),

                // Natija kartasi
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEEF3FF), Color(0xFFF7FAFF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t('resultCongrats')} 🎉',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5D87FF),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t('resultAnswered', {
                                    'total': totalQuestions,
                                    'answer': correctCount,
                                  }),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    height: 1.25,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E2A4A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 84,
                            height: 84,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Image.network(
                              'https://iqmath.uz/images/kubik.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.emoji_events_rounded,
                                color: Color(0xFFF59E0B),
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('resultLabel'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A93A6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // IntrinsicHeight: scroll ichida balandlik cheksiz — stretch'siz qator
                      // xato berib, oynaning pastki qismi bo'sh (oq) chizilardi
                      IntrinsicHeight(
                        child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 112,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0EAFF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$percent%',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF3758F9),
                                  ),
                                ),
                                Text(
                                  t('resultPercentLabel'),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF5C6A93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  statRow(Icons.check_circle_outline_rounded,
                                      const Color(0xFF10B981),
                                      t('resultCorrectAnswers'), correctCount),
                                  statRow(Icons.cancel_outlined,
                                      const Color(0xFFF43F5E),
                                      t('resultWrongAnswers'), wrongCount),
                                  statRow(Icons.description_outlined,
                                      const Color(0xFF5D87FF),
                                      t('resultTotalQuestions'), totalQuestions),
                                ],
                              ),
                            ),
                          ),
                        ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  t('satisfiedQuestion'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A93A6),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => retake(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3758F9),
                            side: const BorderSide(color: Color(0xFFD6DEEC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(t('retake'),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => openResults(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3758F9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.description_outlined,
                              size: 18),
                          label: Text(t('myResults'),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailedResultsDialog(
      Map<String, dynamic> results, String? locale) {
    final questionResults = results['question'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        QuestionPageTranslations.t('myResults', locale),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: questionResults.length,
                  itemBuilder: (context, index) {
                    final result = questionResults[index];
                    final questionIndex = result['index'] as int;
                    final isCorrect = result['answer'] == true;
                    final questionText = locale == 'ru'
                        ? (result['question_ru'] as String? ?? '')
                        : (result['question_uz'] as String? ?? '');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF34C759).withOpacity(0.1)
                            : const Color(0xFFFF3B30).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCorrect
                              ? const Color(0xFF34C759)
                              : const Color(0xFFFF3B30),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFFFF3B30),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$questionIndex',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isCorrect
                                      ? QuestionPageTranslations.t(
                                          'correct', locale)
                                      : QuestionPageTranslations.t(
                                          'incorrect', locale),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect
                                        ? const Color(0xFF34C759)
                                        : const Color(0xFFFF3B30),
                                  ),
                                ),
                              ),
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFFFF3B30),
                                size: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildQuestionContentWithImages(questionText),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E5EA), width: 1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _sendToMentor(locale),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        QuestionPageTranslations.t('sendToMentor', locale),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendToMentor(String? locale) async {
    if (_lastCheckAnswerResponse == null) {
      TopNotification.showError(
        context,
        message: QuestionPageTranslations.t('resultsNotFound', locale),
        title: QuestionPageTranslations.t('error', locale),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF007AFF)),
      ),
    );

    var token = sl<LocalSource>().getAccessToken();

    try {
      final response = await http.post(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/student-independent/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(_lastCheckAnswerResponse),
      );

      alice.onHttpResponse(response);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String? ?? '';
        final telegramLink = data['telegram_link'] as String? ?? '';

        if (success && telegramLink.isNotEmpty) {
          _showTelegramBotDialog(message, telegramLink, locale);
        } else {
          TopNotification.showError(
            context,
            message: message.isNotEmpty
                ? message
                : QuestionPageTranslations.t('errorOccurred', locale),
            title: QuestionPageTranslations.t('error', locale),
          );
        }
      } else {
        TopNotification.showError(
          context,
          message:
              '${QuestionPageTranslations.t('serverError', locale)}: ${response.statusCode}',
          title: QuestionPageTranslations.t('error', locale),
        );
      }
    } catch (e) {
      debugPrint('Send to mentor error: $e');
      if (mounted) {
        Navigator.of(context).pop();
        TopNotification.showError(
          context,
          message: '${QuestionPageTranslations.t('networkError', locale)}: $e',
          title: QuestionPageTranslations.t('error', locale),
        );
      }
    }
  }

  void _showTelegramBotDialog(
      String message, String telegramLink, String? locale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.telegram,
                  size: 48,
                  color: Color(0xFF007AFF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1C1C1E),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      count++;
                      return count == 7;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context, 'Telegram');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    QuestionPageTranslations.t('goToBot', locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        if (_isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: CupertinoActivityIndicator(radius: 12),
            ),
          );
        }

        if (_errorMessage != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(widget.arguments.taskName ?? ''),
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Color(0xFFFF3B30)),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage == 'error'
                        ? QuestionPageTranslations.t('errorLoading', locale)
                        : QuestionPageTranslations.t('errorOccurred', locale),
                    style:
                        const TextStyle(fontSize: 17, color: Color(0xFF8E8E93)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _loadQuestions();
                    },
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF)),
                    child: Text(QuestionPageTranslations.t('retry', locale)),
                  ),
                ],
              ),
            ),
          );
        }

        if (_questions.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(widget.arguments.taskName ?? ''),
              backgroundColor: Colors.white,
              leading: const SizedBox.shrink(),
            ),
            body: Center(
              child: Text(
                QuestionPageTranslations.t('questionsNotFound', locale),
                style: const TextStyle(fontSize: 17, color: Color(0xFF8E8E93)),
              ),
            ),
          );
        }

        final currentQuestion = _questions[_currentQuestionIndex];

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(locale),
          body: Stack(
            children: [
              Column(
                children: [
                  _buildProgressBar(),
                  Expanded(
                    child: GestureDetector(
                      onTap: _hideKeyboard,
                      behavior: HitTestBehavior.opaque,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          top: 16.0,
                          bottom: hasActiveKeyboard ? 400 : 90,
                        ),
                        child: Column(
                          children: [
                            _buildQuestionWidget(currentQuestion, locale),
                            const SizedBox(height: 8),
                            _buildQuestionNavigator(locale),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!hasActiveKeyboard) _buildBottomBar(locale),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                bottom: hasActiveKeyboard ? 0 : -400,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBottomBar(locale),
                      if (hasActiveKeyboard)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 320,
                              color: const Color(0xFFD1D1D6),
                              child: MathKeyboard(
                                controller: _controllers[_activeFieldId]!,
                                variables: const [
                                  '<',
                                  '>',
                                  '=',
                                  'x',
                                  'y',
                                  'z',
                                  'a',
                                  'b',
                                  'c',
                                  'n',
                                  'm',
                                  '∅'
                                ],
                                type: MathKeyboardType.expression,
                                onSubmit: () {
                                  _hideKeyboard();
                                  _saveCurrentAnswer();
                                  isLastQuestion
                                      ? _finishTest()
                                      : _navigateQuestion(true);
                                },
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).padding.bottom,
                              color: const Color(0xFFD1D1D6),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(String? locale) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        widget.arguments.taskName ?? '',
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.4),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentQuestionIndex + 1}/${_questions.length}',
            style: const TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      tween: Tween<double>(
        begin: _currentQuestionIndex / _questions.length,
        end: (_currentQuestionIndex + 1) / _questions.length,
      ),
      builder: (context, value, _) => Container(
        height: 3,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF5856D6)]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(String? locale) {
    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            const Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !hasActiveKeyboard,
        child: Row(
          children: [
            Expanded(child: _buildBackButton(locale)),
            const SizedBox(width: 12),
            Expanded(child: _buildNextButton(locale)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(String? locale) {
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5856D6), Color(0xFF007AFF)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF5856D6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canGoBack
                ? () {
                    _saveCurrentAnswer();
                    setState(() {
                      _currentQuestionIndex -= 1;
                      _visitedQuestions.add(_currentQuestionIndex);
                    });
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _activateFirstField();
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: canGoBack
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    QuestionPageTranslations.t('back', locale),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: canGoBack
                            ? Colors.white
                            : Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(String? locale) {
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _saveCurrentAnswer();
              if (isLastQuestion) {
                _hideKeyboard();
                _finishTest();
              } else {
                setState(() {
                  _currentQuestionIndex += 1;
                  _visitedQuestions.add(_currentQuestionIndex);
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  _activateFirstField();
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastQuestion
                        ? QuestionPageTranslations.t('finish', locale)
                        : QuestionPageTranslations.t('next', locale),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastQuestion
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question, String? locale) {
    final questionType = question['question_type'] as String?;

    switch (questionType) {
      case 'text':
        return _buildTextQuestion(question, locale);
      case 'composite':
        return _buildCompositeQuestion(question, locale);
      case 'choice':
        return _buildChoiceQuestion(question, locale);
      case 'image_choice': // NEW CASE
        return _buildImageChoiceQuestion(question, locale);
      default:
        return _buildUnsupportedQuestion(questionType, locale);
    }
  }

  Widget _buildUnsupportedQuestion(String? questionType, String? locale) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 64, color: Color(0xFFFF9500)),
          const SizedBox(height: 16),
          Text(
            QuestionPageTranslations.t('unsupportedQuestionType', locale),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${QuestionPageTranslations.t('type', locale)}: ${questionType ?? "noma\'lum"}',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBadge(String type, String? locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${QuestionPageTranslations.t('question', locale)} ${_currentQuestionIndex + 1}',
        style: const TextStyle(
          color: Color(0xFF007AFF),
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildTextQuestion(Map<String, dynamic> question, String? locale) {
    final questionId = question['id'] as int?;
    final questionText = locale == 'ru'
        ? (question['question_text_ru'] as String? ?? '')
        : (question['question_text_uz'] as String? ?? '');

    if (questionId == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionBadge('text', locale),
        const SizedBox(height: 6),
        _buildQuestionText(questionText),
        const SizedBox(height: 6),
        _buildMathFieldInput(questionId, locale),
      ],
    );
  }

  Widget _buildCompositeQuestion(
      Map<String, dynamic> question, String? locale) {
    final questionId = question['id'] as int?;
    final questionText = locale == 'ru'
        ? (question['question_text_ru'] as String? ?? '')
        : (question['question_text_uz'] as String? ?? '');
    final subQuestions = question['sub_questions'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionBadge('composite', locale),
        const SizedBox(height: 6),
        _buildQuestionText(questionText),
        const SizedBox(height: 6),
        ...subQuestions.asMap().entries.map((entry) {
          final index = entry.key;
          final sq = entry.value as Map<String, dynamic>;
          return Column(
            children: [
              _buildSubQuestion(sq, questionId!, locale),
              if (index < subQuestions.length - 1) const SizedBox(height: 6),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildChoiceQuestion(Map<String, dynamic> question, String? locale) {
    final questionId = question['id'] as int?;
    final questionText = locale == 'ru'
        ? (question['question_text_ru'] as String? ?? '')
        : (question['question_text_uz'] as String? ?? '');
    final choices = question['choices'] as List<dynamic>? ?? [];
    final questionCategory = question['question_category'] as String?;

    if (questionId == null) return const SizedBox.shrink();

    final isRadioButton = questionCategory == 'radio_button';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionBadge('choice', locale),
        const SizedBox(height: 6),
        _buildQuestionText(questionText),
        const SizedBox(height: 6),
        ...choices.map((choice) {
          final choiceData = choice as Map<String, dynamic>;
          final choiceId = choiceData['id'] as int;
          final choiceLetter = choiceData['letter'] as String? ?? '';
          final choiceText = locale == 'ru'
              ? (choiceData['text_ru'] as String? ?? '')
              : (choiceData['text_uz'] as String? ?? '');

          return _buildChoiceOption(
            questionId,
            choiceId,
            choiceLetter,
            choiceText,
            isRadioButton,
          );
        }),
      ],
    );
  }

  Widget _buildChoiceOption(int questionId, int choiceId, String letter,
      String text, bool isRadioButton) {
    final isSelected = _answers[questionId] == choiceId.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isRadioButton) {
                _answers[questionId] = choiceId.toString();
              } else {
                if (isSelected) {
                  _answers.remove(questionId);
                } else {
                  _answers[questionId] = choiceId.toString();
                }
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF007AFF).withOpacity(0.1)
                  : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFE5E5EA),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF007AFF)
                          : const Color(0xFFE5E5EA),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF007AFF),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubQuestion(Map<String, dynamic> subQuestion,
      int compositeQuestionId, String? locale) {
    final id = subQuestion['id'] as int?;
    final text1 = locale == 'ru'
        ? (subQuestion['text1_ru'] as String? ?? '')
        : (subQuestion['text1_uz'] as String? ?? '');
    final text2 = locale == 'ru'
        ? (subQuestion['text2_ru'] as String? ?? '')
        : (subQuestion['text2_uz'] as String? ?? '');

    if (id == null) return const SizedBox.shrink();

    return _buildLabeledInput(id, text1, text2,
        compositeQuestionId: compositeQuestionId, locale: locale);
  }

  Widget _buildLabeledInput(int id, String label, String unit,
      {int? compositeQuestionId, String? locale}) {
    // Check if label or unit contains LaTeX
    final labelHasLatex = label.contains(r'\(') || label.contains(r'\[');
    final unitHasLatex = unit.contains(r'\(') || unit.contains(r'\[');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: labelHasLatex
                      ? _buildLatexTextForLabel(label)
                      : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '(',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      unitHasLatex
                          ? _buildLatexTextForUnit(unit)
                          : Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        ')',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        if (unit.isNotEmpty && label.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Birlik: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                unitHasLatex
                    ? _buildLatexTextForUnit(unit)
                    : Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        _buildMathFieldInput(id, locale,
            compositeQuestionId: compositeQuestionId),
      ],
    );
  }


// Add this new method in your _QuestionPageState class,
// right after the _buildLatexText method:

  Widget _buildLatexTextForLabel(String text) {
    final cleanedText = _cleanHtmlEntities(_stripHtmlTags(text));
    final latexPattern = RegExp(r'\\\((.*?)\\\)|\\\[(.*?)\\\]');
    final matches = latexPattern.allMatches(cleanedText);

    if (matches.isEmpty) {
      return Text(
        cleanedText,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        final plainText = cleanedText.substring(lastIndex, match.start);
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(
            text: plainText,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ));
        }
      }

      final latexCode = match.group(1) ?? match.group(2) ?? '';
      if (latexCode.isNotEmpty) {
        try {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              child: Math.tex(
                latexCode,
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                mathStyle: MathStyle.text,
              ),
            ),
          ));
        } catch (e) {
          spans.add(TextSpan(
            text: latexCode,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ));
          debugPrint('LaTeX parse error in label: $e');
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < cleanedText.length) {
      final remainingText = cleanedText.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(
          text: remainingText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

// Add this helper method for rendering LaTeX in unit text (gray color):

  Widget _buildLatexTextForUnit(String text) {
    final cleanedText = _cleanHtmlEntities(_stripHtmlTags(text));
    final latexPattern = RegExp(r'\\\((.*?)\\\)|\\\[(.*?)\\\]');
    final matches = latexPattern.allMatches(cleanedText);

    if (matches.isEmpty) {
      return Text(
        cleanedText,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF8E8E93),
          fontWeight: FontWeight.w500,
        ),
      );
    }

    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        final plainText = cleanedText.substring(lastIndex, match.start);
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(
            text: plainText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ));
        }
      }

      final latexCode = match.group(1) ?? match.group(2) ?? '';
      if (latexCode.isNotEmpty) {
        try {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              child: Math.tex(
                latexCode,
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E93),
                ),
                mathStyle: MathStyle.text,
              ),
            ),
          ));
        } catch (e) {
          spans.add(TextSpan(
            text: latexCode,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ));
          debugPrint('LaTeX parse error in unit: $e');
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < cleanedText.length) {
      final remainingText = cleanedText.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(
          text: remainingText,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildMathFieldInput(int id, String? locale,
      {int? compositeQuestionId}) {
    final controller = _controllers[id];
    final focusNode = _focusNodes[id];
    if (controller == null || focusNode == null) return const SizedBox.shrink();

    final isActive = _activeFieldId == id;
    final hasValue = controller.currentEditingValue().isNotEmpty &&
        controller.currentEditingValue() != r'\Box';

    bool shouldHighlightEmpty = false;
    if (compositeQuestionId != null && !hasValue) {
      shouldHighlightEmpty = _hasAnySubAnswer(compositeQuestionId);
    }

    final minHeight = compositeQuestionId != null ? 56.0 : 100.0;
    final maxHeight = compositeQuestionId != null ? 120.0 : 200.0;

    return GestureDetector(
      onTap: () => _showKeyboard(id),
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        absorbing: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          child: IntrinsicHeight(
            child: MathField(
              controller: controller,
              focusNode: focusNode,
              opensKeyboard: false,
              autofocus: true,
              variables: const [
                '<',
                '>',
                '=',
                'x',
                'y',
                'z',
                'a',
                'b',
                'c',
                'n',
                'm',
                '∅',
              ],
              keyboardType: MathKeyboardType.expression,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: shouldHighlightEmpty
                        ? const Color(0xFFFF3B30)
                        : hasValue
                            ? const Color(0xFF34C759)
                            : isActive
                                ? const Color(0xFF007AFF)
                                : const Color(0xFFE5E5EA),
                    width:
                        isActive || hasValue || shouldHighlightEmpty ? 2 : 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: shouldHighlightEmpty
                        ? const Color(0xFFFF3B30)
                        : hasValue
                            ? const Color(0xFF34C759)
                            : const Color(0xFFE5E5EA),
                    width: hasValue || shouldHighlightEmpty ? 2 : 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: shouldHighlightEmpty
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF007AFF),
                    width: 2,
                  ),
                ),
                hintText: QuestionPageTranslations.t('enterAnswer', locale),
                hintStyle: TextStyle(
                  color: shouldHighlightEmpty
                      ? const Color(0xFFFF3B30).withOpacity(0.7)
                      : const Color(0xFF8E8E93),
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                filled: true,
                fillColor: shouldHighlightEmpty
                    ? const Color(0xFFFF3B30).withOpacity(0.05)
                    : isActive
                        ? const Color(0xFF007AFF).withOpacity(0.05)
                        : Colors.white,
              ),
              onChanged: (value) {},
              onSubmitted: (value) {
                _saveCurrentAnswer();
                if (isLastQuestion) {
                  _finishTest();
                } else {
                  _navigateQuestion(true);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _hasAnySubAnswer(int compositeQuestionId) {
    final answer = _answers[compositeQuestionId];
    if (answer == null || answer is! Map) return false;

    for (var value in answer.values) {
      if (value is String && value.isNotEmpty && value != r'\Box') {
        return true;
      }
    }
    return false;
  }

  Widget _buildQuestionNavigator(String? locale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            QuestionPageTranslations.t('questions', locale),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_questions.length, (index) {
              final question = _questions[index];
              final questionId = question['id'] as int?;
              final questionType = question['question_type'] as String?;

              bool isAnswered = false;
              bool isPartiallyAnswered = false;

              if (questionId != null && _answers.containsKey(questionId)) {
                final answer = _answers[questionId];

                if (questionType == 'composite') {
                  final subQuestions =
                      question['sub_questions'] as List<dynamic>? ?? [];
                  int answeredCount = 0;

                  if (answer is Map) {
                    for (var subQ in subQuestions) {
                      final subId = subQ['id'] as int;
                      final subAnswer = answer[subId];
                      if (subAnswer is String &&
                          subAnswer.isNotEmpty &&
                          subAnswer != r'\Box') {
                        answeredCount++;
                      }
                    }
                  }

                  if (answeredCount == subQuestions.length) {
                    isAnswered = true;
                  } else if (answeredCount > 0) {
                    isPartiallyAnswered = true;
                  }
                } else {
                  if (answer is String &&
                      answer.isNotEmpty &&
                      answer != r'\Box') {
                    isAnswered = true;
                  } else if (answer is Map && answer.isNotEmpty) {
                    isAnswered = true;
                  }
                }
              }

              final isCurrentQuestion = index == _currentQuestionIndex;
              final isVisited = _visitedQuestions.contains(index);
              final isSkipped =
                  isVisited && !isAnswered && !isPartiallyAnswered;

              Color backgroundColor;
              Color borderColor;
              Color textColor;

              if (isCurrentQuestion) {
                backgroundColor = const Color(0xFF007AFF);
                borderColor = const Color(0xFF007AFF);
                textColor = Colors.white;
              } else if (isAnswered) {
                backgroundColor = const Color(0xFF34C759).withOpacity(0.1);
                borderColor = const Color(0xFF34C759);
                textColor = const Color(0xFF34C759);
              } else if (isPartiallyAnswered || isSkipped) {
                backgroundColor = const Color(0xFFFF3B30).withOpacity(0.1);
                borderColor = const Color(0xFFFF3B30);
                textColor = const Color(0xFFFF3B30);
              } else {
                backgroundColor = Colors.white;
                borderColor = const Color(0xFFE5E5EA);
                textColor = const Color(0xFF1C1C1E);
              }

              return GestureDetector(
                onTap: () {
                  _saveCurrentAnswer();
                  setState(() {
                    _currentQuestionIndex = index;
                    _visitedQuestions.add(index);
                  });

                  Future.delayed(const Duration(milliseconds: 100), () {
                    _activateFirstField();
                  });
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundColor,
                    border: Border.all(
                      color: borderColor,
                      width: isCurrentQuestion ? 2 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImageChoiceQuestion(
      Map<String, dynamic> question, String? locale) {
    final questionId = question['id'] as int?;
    final questionText = locale == 'ru'
        ? (question['question_text_ru'] as String? ?? '')
        : (question['question_text_uz'] as String? ?? '');
    final choices = question['choices'] as List<dynamic>? ?? [];
    final questionCategory = question['question_category'] as String?;

    if (questionId == null) return const SizedBox.shrink();

    final isRadioButton = questionCategory == 'radio_button';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuestionBadge('image_choice', locale),
        const SizedBox(height: 6),
        _buildQuestionText(questionText),
        const SizedBox(height: 10),
        // Grid layout for image choices with smaller size
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: choices.length,
          itemBuilder: (context, index) {
            final choice = choices[index] as Map<String, dynamic>;
            final choiceId = choice['id'] as int;
            final choiceLetter = choice['letter'] as String? ?? '';
            final imageUrl = choice['image_url'] as String? ?? '';

            return _buildImageChoiceOption(
              questionId,
              choiceId,
              choiceLetter,
              imageUrl,
              isRadioButton,
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageChoiceOption(
    int questionId,
    int choiceId,
    String letter,
    String imageUrl,
    bool isRadioButton,
  ) {
    final isSelected = _answers[questionId] == choiceId.toString();

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isRadioButton) {
            _answers[questionId] = choiceId.toString();
          } else {
            if (isSelected) {
              _answers.remove(questionId);
            } else {
              _answers[questionId] = choiceId.toString();
            }
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007AFF).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Letter badge - smaller
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF007AFF)
                    : const Color(0xFFF5F5F7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
            // Image container - compact
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF007AFF),
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 24,
                                    color: Color(0xFF8E8E93),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Xato',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 24,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
