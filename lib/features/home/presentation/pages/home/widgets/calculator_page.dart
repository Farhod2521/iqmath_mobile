import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Main Calculator Screen
/// Contains the display and button grid
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final CalculatorService _calculator = CalculatorService();
  bool _isDarkMode = false; // Light mode by default

  /// Toggle theme mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  /// Handle button press
  void _onButtonPressed(String value) {
    setState(() {
      switch (value) {
        case 'AC':
        case 'C':
          _calculator.allClear();
          break;
        case '+/-':
          _calculator.toggleSign();
          break;
        case '%':
          _calculator.percent();
          break;
        case '+':
        case '-':
        case '×':
        case '÷':
          _calculator.inputOperator(value);
          break;
        case '=':
          _calculator.equals();
          break;
        case '.':
          _calculator.inputDecimal();
          break;
        default:
        // Number input
          _calculator.inputNumber(value);
          break;
      }
    });
  }

  /// Build button grid row
  Widget _buildButtonRow(List<Map<String, dynamic>> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((button) {
          return Expanded(
            flex: button['flex'] ?? 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CalculatorButton(
                text: button['text'],
                type: button['type'],
                onPressed: () => _onButtonPressed(button['value']),
                isWide: button['flex'] == 2,
                isDarkMode: _isDarkMode,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate display height (about 1/3 of screen)
    final displayHeight = screenHeight * 0.35;

    // Determine clear button text (AC or C)
    String clearButtonText = _calculator.shouldShowAC() ? 'AC' : 'C';

    // Theme colors
    final backgroundColor = _isDarkMode ? Colors.black : const Color(0xFFF5F5F5);
    final displayTextColor = _isDarkMode ? Colors.white : Colors.black;
    final historyTextColor = _isDarkMode
        ? Colors.white.withOpacity(0.6)
        : Colors.black.withOpacity(0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Theme toggle button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: displayTextColor,
                  ),
                  onPressed: _toggleTheme,
                ),
              ),
            ),

            // Display
            Container(
              height: displayHeight - 60,
              width: screenWidth,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // History display (operation)
                  if (_calculator.historyDisplay.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _calculator.historyDisplay,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: historyTextColor,
                          letterSpacing: -1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),

                  // Main display text
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _calculator.display,
                      style: TextStyle(
                        fontSize: 96,
                        fontWeight: FontWeight.w300,
                        color: displayTextColor,
                        letterSpacing: -2,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Button Grid
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  children: [
                    // Row 1: AC/C, +/-, %, ÷
                    _buildButtonRow([
                      {
                        'text': clearButtonText,
                        'value': clearButtonText,
                        'type': CalculatorButtonType.function,
                      },
                      {
                        'text': '+/-',
                        'value': '+/-',
                        'type': CalculatorButtonType.function,
                      },
                      {
                        'text': '%',
                        'value': '%',
                        'type': CalculatorButtonType.function,
                      },
                      {
                        'text': '÷',
                        'value': '÷',
                        'type': CalculatorButtonType.operator,
                      },
                    ]),

                    // Row 2: 7, 8, 9, ×
                    _buildButtonRow([
                      {
                        'text': '7',
                        'value': '7',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '8',
                        'value': '8',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '9',
                        'value': '9',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '×',
                        'value': '×',
                        'type': CalculatorButtonType.operator,
                      },
                    ]),

                    // Row 3: 4, 5, 6, -
                    _buildButtonRow([
                      {
                        'text': '4',
                        'value': '4',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '5',
                        'value': '5',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '6',
                        'value': '6',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '-',
                        'value': '-',
                        'type': CalculatorButtonType.operator,
                      },
                    ]),

                    // Row 4: 1, 2, 3, +
                    _buildButtonRow([
                      {
                        'text': '1',
                        'value': '1',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '2',
                        'value': '2',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '3',
                        'value': '3',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '+',
                        'value': '+',
                        'type': CalculatorButtonType.operator,
                      },
                    ]),

                    // Row 5: 0 (wide), ., =
                    _buildButtonRow([
                      {
                        'text': '0',
                        'value': '0',
                        'type': CalculatorButtonType.number,
                        'flex': 2,
                      },
                      {
                        'text': '.',
                        'value': '.',
                        'type': CalculatorButtonType.number,
                      },
                      {
                        'text': '=',
                        'value': '=',
                        'type': CalculatorButtonType.equals,
                      },
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Button types for styling
enum CalculatorButtonType {
  number,
  operator,
  function,
  equals,
}

/// Custom Calculator Button Widget
/// Styled to match iOS calculator appearance with light/dark modes
class CalculatorButton extends StatefulWidget {
  final String text;
  final CalculatorButtonType type;
  final VoidCallback onPressed;
  final bool isWide;
  final bool isDarkMode;

  const CalculatorButton({
    Key? key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.isWide = false,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get button color based on type and theme
  Color get _buttonColor {
    if (widget.isDarkMode) {
      // Dark mode colors
      switch (widget.type) {
        case CalculatorButtonType.number:
          return const Color(0xFF333333);
        case CalculatorButtonType.operator:
          return const Color(0xFFFF9F0A);
        case CalculatorButtonType.function:
          return const Color(0xFFA6A6A6);
        case CalculatorButtonType.equals:
          return const Color(0xFFFF9F0A);
      }
    } else {
      // Light mode colors
      switch (widget.type) {
        case CalculatorButtonType.number:
          return const Color(0xFFFFFFFF);
        case CalculatorButtonType.operator:
          return const Color(0xFFFF9F0A);
        case CalculatorButtonType.function:
          return const Color(0xFFD4D4D2);
        case CalculatorButtonType.equals:
          return const Color(0xFFFF9F0A);
      }
    }
  }

  /// Get text color based on type and theme
  Color get _textColor {
    if (widget.isDarkMode) {
      switch (widget.type) {
        case CalculatorButtonType.function:
          return Colors.black;
        default:
          return Colors.white;
      }
    } else {
      switch (widget.type) {
        case CalculatorButtonType.number:
          return Colors.black;
        case CalculatorButtonType.function:
          return Colors.black;
        case CalculatorButtonType.operator:
        case CalculatorButtonType.equals:
          return Colors.white;
      }
    }
  }

  /// Get pressed button color
  Color get _pressedColor {
    if (widget.isDarkMode) {
      switch (widget.type) {
        case CalculatorButtonType.number:
          return const Color(0xFF4D4D4D);
        case CalculatorButtonType.operator:
        case CalculatorButtonType.equals:
          return const Color(0xFFFFB340);
        case CalculatorButtonType.function:
          return const Color(0xFFD6D6D6);
      }
    } else {
      switch (widget.type) {
        case CalculatorButtonType.number:
          return const Color(0xFFE8E8E8);
        case CalculatorButtonType.operator:
        case CalculatorButtonType.equals:
          return const Color(0xFFFFB340);
        case CalculatorButtonType.function:
          return const Color(0xFFC4C4C2);
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          decoration: BoxDecoration(
            color: _isPressed ? _pressedColor : _buttonColor,
            shape: widget.isWide ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: widget.isWide ? BorderRadius.circular(40) : null,
            // Add shadow for light mode
            boxShadow: !widget.isDarkMode
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: _textColor,
                fontSize: widget.type == CalculatorButtonType.function ? 32 : 38,
                fontWeight: widget.type == CalculatorButtonType.function
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Calculator Logic Service
/// Handles all calculator operations and state management
class CalculatorService {
  String _display = '0';
  String _operand1 = '';
  String _operand2 = '';
  String _operator = '';
  bool _shouldResetDisplay = false;
  bool _hasDecimalPoint = false;
  String _historyDisplay = '';

  /// Get current display value
  String get display => _display;

  /// Get history display (shows operation)
  String get historyDisplay => _historyDisplay;

  /// Maximum display length
  static const int maxDisplayLength = 9;

  /// Update history display
  void _updateHistory() {
    if (_operand1.isNotEmpty && _operator.isNotEmpty) {
      String formattedOperand1 = _formatForHistory(_operand1);
      if (_operand2.isNotEmpty && !_shouldResetDisplay) {
        String formattedOperand2 = _formatForHistory(_operand2);
        _historyDisplay = '$formattedOperand1 $_operator $formattedOperand2';
      } else {
        _historyDisplay = '$formattedOperand1 $_operator';
      }
    } else {
      _historyDisplay = '';
    }
  }

  /// Format number for history display
  String _formatForHistory(String number) {
    double? value = double.tryParse(number);
    if (value == null) return number;

    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  /// Handle number input
  void inputNumber(String number) {
    // Reset display if needed (after operation or result)
    if (_shouldResetDisplay) {
      _display = number;
      _shouldResetDisplay = false;
      _hasDecimalPoint = false;
      _operand2 = _display;
      _updateHistory();
      return;
    }

    // Prevent multiple zeros at start
    if (_display == '0' && number == '0') {
      return;
    }

    // Replace initial zero with number
    if (_display == '0' && number != '.') {
      _display = number;
      if (_operator.isNotEmpty) {
        _operand2 = _display;
        _updateHistory();
      }
      return;
    }

    // Check display length limit
    String testDisplay = _display.replaceAll('-', '').replaceAll('.', '');
    if (testDisplay.length >= maxDisplayLength) {
      return;
    }

    _display += number;
    if (_operator.isNotEmpty) {
      _operand2 = _display;
      _updateHistory();
    }
  }

  /// Handle decimal point input
  void inputDecimal() {
    if (_shouldResetDisplay) {
      _display = '0.';
      _shouldResetDisplay = false;
      _hasDecimalPoint = true;
      if (_operator.isNotEmpty) {
        _operand2 = _display;
        _updateHistory();
      }
      return;
    }

    // Prevent multiple decimal points
    if (_hasDecimalPoint || _display.contains('.')) {
      return;
    }

    _display += '.';
    _hasDecimalPoint = true;
    if (_operator.isNotEmpty) {
      _operand2 = _display;
      _updateHistory();
    }
  }

  /// Handle operator input (+, -, ×, ÷)
  void inputOperator(String operator) {
    // If we already have an operator and operand2, calculate first
    if (_operator.isNotEmpty && _operand2.isNotEmpty && !_shouldResetDisplay) {
      calculate();
    }

    _operand1 = _display;
    _operator = operator;
    _operand2 = '';
    _shouldResetDisplay = true;
    _hasDecimalPoint = false;
    _updateHistory();
  }

  /// Perform calculation
  void calculate() {
    if (_operator.isEmpty || _operand1.isEmpty) {
      return;
    }

    // Use current display as operand2 if not set
    if (_operand2.isEmpty || _shouldResetDisplay) {
      _operand2 = _display;
    }

    double num1 = double.tryParse(_operand1) ?? 0;
    double num2 = double.tryParse(_operand2) ?? 0;
    double result = 0;

    try {
      switch (_operator) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '×':
          result = num1 * num2;
          break;
        case '÷':
          if (num2 == 0) {
            _display = 'Error';
            _reset();
            return;
          }
          result = num1 / num2;
          break;
      }

      // Update history before showing result
      _updateHistory();

      // Format result
      _display = _formatResult(result);

      // For continuous calculations, keep operand2 and operator
      _operand1 = _display;
      _shouldResetDisplay = true;
      _hasDecimalPoint = _display.contains('.');
    } catch (e) {
      _display = 'Error';
      _reset();
    }
  }

  /// Handle equals button
  void equals() {
    if (_operator.isNotEmpty) {
      calculate();
      // After equals, keep history visible but clear operator
      // This way user can see the calculation they just did
      Future.delayed(const Duration(milliseconds: 100), () {
        _operator = '';
        _operand2 = '';
      });
    }
  }

  /// Toggle positive/negative
  void toggleSign() {
    if (_display == '0' || _display == 'Error') {
      return;
    }

    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }

    // Update operand2 if we're in the middle of an operation
    if (_operator.isNotEmpty && !_shouldResetDisplay) {
      _operand2 = _display;
      _updateHistory();
    }
  }

  /// Handle percent button
  void percent() {
    if (_display == 'Error') {
      return;
    }

    double number = double.tryParse(_display) ?? 0;
    number = number / 100;
    _display = _formatResult(number);
    _hasDecimalPoint = _display.contains('.');

    // Update operand2 if we're in the middle of an operation
    if (_operator.isNotEmpty && !_shouldResetDisplay) {
      _operand2 = _display;
      _updateHistory();
    }
  }

  /// Clear all (AC button)
  void allClear() {
    _display = '0';
    _operand1 = '';
    _operand2 = '';
    _operator = '';
    _shouldResetDisplay = false;
    _hasDecimalPoint = false;
    _historyDisplay = '';
  }

  /// Reset internal state (keep display)
  void _reset() {
    _operand1 = '';
    _operand2 = '';
    _operator = '';
    _shouldResetDisplay = true;
    _hasDecimalPoint = false;
    _historyDisplay = '';
  }

  /// Format result to avoid scientific notation and limit decimals
  String _formatResult(double result) {
    // Check for overflow
    if (result.abs() > 999999999) {
      return 'Error';
    }

    // Remove unnecessary decimals
    if (result == result.toInt()) {
      return result.toInt().toString();
    }

    // Format with appropriate decimal places
    String formatted = result.toStringAsFixed(8);
    // Remove trailing zeros
    formatted = formatted.replaceAll(RegExp(r'0*$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');

    // Limit total length
    String withoutNegative = formatted.replaceAll('-', '');
    String withoutDecimal = withoutNegative.replaceAll('.', '');

    if (withoutDecimal.length > maxDisplayLength) {
      int decimalPlaces = maxDisplayLength - withoutDecimal.indexOf('.');
      if (decimalPlaces < 0) decimalPlaces = 0;
      formatted = result.toStringAsFixed(decimalPlaces);
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    return formatted;
  }

  /// Check if current state requires showing "AC" or "C"
  bool shouldShowAC() {
    return _display == '0' && _operand1.isEmpty && _operator.isEmpty;
  }
}