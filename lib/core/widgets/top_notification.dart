import 'package:flutter/material.dart';

class TopNotification {
  static OverlayEntry? _currentOverlay;

  static void show(
      BuildContext context, {
        required String message,
        String? title,
        Color backgroundColor = Colors.green,
        Color textColor = Colors.white,
        IconData icon = Icons.check_circle,
        Duration duration = const Duration(seconds: 3),
        VoidCallback? onTap,
      }) {
    // Remove existing overlay if any
    _currentOverlay?.remove();

    _currentOverlay = OverlayEntry(
      builder: (context) => TopNotificationWidget(
        message: message,
        title: title,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        duration: duration,
        onTap: onTap,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void showSuccess(
      BuildContext context, {
        required String message,
        String? title,
        Duration duration = const Duration(seconds: 3),
        VoidCallback? onTap,
      }) {
    show(
      context,
      message: message,
      title: title,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showError(
      BuildContext context, {
        required String message,
        String? title,
        Duration duration = const Duration(seconds: 4),
        VoidCallback? onTap,
      }) {
    show(
      context,
      message: message,
      title: title,
      backgroundColor: Colors.red,
      icon: Icons.error,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showWarning(
      BuildContext context, {
        required String message,
        String? title,
        Duration duration = const Duration(seconds: 3),
        VoidCallback? onTap,
      }) {
    show(
      context,
      message: message,
      title: title,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showInfo(
      BuildContext context, {
        required String message,
        String? title,
        Duration duration = const Duration(seconds: 3),
        VoidCallback? onTap,
      }) {
    show(
      context,
      message: message,
      title: title,
      backgroundColor: Colors.blue,
      icon: Icons.info,
      duration: duration,
      onTap: onTap,
    );
  }
}

class TopNotificationWidget extends StatefulWidget {
  final String message;
  final String? title;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const TopNotificationWidget({
    Key? key,
    required this.message,
    this.title,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
              ),
              child: GestureDetector(
                onTap: widget.onTap,
                onPanUpdate: (details) {
                  // Swipe up to dismiss
                  if (details.delta.dy < -5) {
                    _dismiss();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: widget.backgroundColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.textColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.title != null)
                              Text(
                                widget.title!,
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (widget.title != null) const SizedBox(height: 2),
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: widget.textColor,
                                fontSize: 14,
                                fontWeight: widget.title != null
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.textColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.close,
                            color: widget.textColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Usage example:
class NotificationHelper {
  static void showPasswordResetSuccess(BuildContext context) {
    TopNotification.showSuccess(
      context,
      title: 'Muvaffaqiyat',
      message: 'Parolingiz muvaffaqiyatli o\'zgartirildi',
      duration: const Duration(seconds: 4),
    );
  }

  static void showError(BuildContext context, String message, {String? title}) {
    TopNotification.showError(
      context,
      title: title ?? 'Xatolik',
      message: message,
    );
  }

  static void showRegistrationSuccess(BuildContext context) {
    TopNotification.showSuccess(
      context,
      title: 'Tabriklaymiz!',
      message: 'Ro\'yxatdan o\'tish muvaffaqiyatli yakunlandi',
      duration: const Duration(seconds: 3),
    );
  }

  static void showCodeSent(BuildContext context) {
    TopNotification.showInfo(
      context,
      title: 'SMS yuborildi',
      message: 'Tasdiqlash kodi telefon raqamingizga yuborildi',
    );
  }
}