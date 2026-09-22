import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';

// ============================================================
// MODELS
// ============================================================

class AccountSession {
  final int sessionId;
  final String phone;
  final String role;
  final String? firstName;

  AccountSession({
    required this.sessionId,
    required this.phone,
    required this.role,
    this.firstName,
  });

  factory AccountSession.fromJson(Map<String, dynamic> json) {
    return AccountSession(
      sessionId: json['session_id'] ?? json['id'] ?? 0,
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'student',
      firstName: json['first_name'] ?? json['name'],
    );
  }

  List<Color> get avatarColors {
    final colors = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
      [const Color(0xFFFCCF31), const Color(0xFFF55555)],
      [const Color(0xFF96FBC4), const Color(0xFFF9F586)],
    ];
    final idx = phone.isNotEmpty
        ? phone.codeUnitAt(phone.length - 1) % colors.length
        : 0;
    return colors[idx];
  }

  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName![0].toUpperCase();
    }
    return phone.isNotEmpty ? phone[phone.length - 1] : '?';
  }

  String get displayName => firstName ?? _formatPhone(phone);
}

// ============================================================
// SWITCH ACCOUNT RESPONSE MODEL
// ============================================================

class SwitchAccountResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String role;
  final String phone;
  final int sessionId;

  SwitchAccountResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.role,
    required this.phone,
    required this.sessionId,
  });

  factory SwitchAccountResponse.fromJson(Map<String, dynamic> json) {
    return SwitchAccountResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      role: json['role'] ?? 'student',
      phone: json['phone'] ?? '',
      sessionId: json['session_id'] ?? 0,
    );
  }
}

// ============================================================
// VERIFY CODE RESPONSE MODEL
// ============================================================

class VerifyCodeResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String role;
  final String phone;
  final int sessionId;

  VerifyCodeResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.role,
    required this.phone,
    required this.sessionId,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      role: json['role'] ?? 'student',
      phone: json['phone'] ?? '',
      sessionId: json['session_id'] ?? 0,
    );
  }
}

// ============================================================
// API RESULT — success / error birga
// ============================================================

class ApiResult<T> {
  final T? data;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;

  ApiResult.success(this.data) : errorMessage = null;

  ApiResult.error(this.errorMessage) : data = null;
}

// ============================================================
// API SERVICE
// ============================================================

class MultiAccountService {
  static const _base = 'https://api.iqmath.uz/api/v1/auth/user/auth';

  // ── Get Sessions ──
  static Future<ApiResult<List<AccountSession>>> getSessions(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/sessions/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accounts = (data['accounts'] as List<dynamic>? ?? [])
            .map((e) => AccountSession.fromJson(e))
            .toList();
        return ApiResult.success(accounts);
      }
      return ApiResult.error(_extractError(response.body, response.statusCode));
    } catch (e) {
      return ApiResult.error('Tarmoq xatosi: $e');
    }
  }

  // ── Switch Account — SwitchAccountResponse qaytaradi ──
  static Future<ApiResult<SwitchAccountResponse>> switchAccount(
      String token, int sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/switch-account/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({'session_id': sessionId}),
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        return ApiResult.success(
          SwitchAccountResponse.fromJson(json.decode(response.body)),
        );
      }
      return ApiResult.error(_extractError(response.body, response.statusCode));
    } catch (e) {
      return ApiResult.error('Tarmoq xatosi: $e');
    }
  }

  // ── Send Code ──
  static Future<ApiResult<bool>> sendCode(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/send-code/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sl<LocalSource>().getAccessToken() ?? '',
        },
        body: json.encode({'phone': phone}),
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) return ApiResult.success(true);
      return ApiResult.error(_extractError(response.body, response.statusCode));
    } catch (e) {
      return ApiResult.error('Tarmoq xatosi: $e');
    }
  }

  // ── Verify Code — VerifyCodeResponse qaytaradi ──
  static Future<ApiResult<VerifyCodeResponse>> verifyCode({
    required String phone,
    required String code,
    required String deviceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/verify-code/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sl<LocalSource>().getAccessToken() ?? '',
        },
        body: json.encode({
          'phone': phone,
          'code': code,
          'device_id': deviceId,
        }),
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        return ApiResult.success(
          VerifyCodeResponse.fromJson(json.decode(response.body)),
        );
      }
      return ApiResult.error(_extractError(response.body, response.statusCode));
    } catch (e) {
      return ApiResult.error('Tarmoq xatosi: $e');
    }
  }

  /// Django REST tipik xato formatlarini parse qiladi
  static String _extractError(String body, int statusCode) {
    try {
      final data = json.decode(body);
      if (data is Map) {
        if (data['detail'] != null) return data['detail'].toString();
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
        final firstVal = data.values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          return firstVal.first.toString();
        }
        return firstVal.toString();
      }
    } catch (_) {}
    return 'Xatolik yuz berdi ($statusCode)';
  }
}

// ============================================================
// SNACKBAR HELPER
// ============================================================

class _Snack {
  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

// ============================================================
// TELEGRAM-STYLE DRAWER HEADER
// ============================================================

class TelegramAccountHeader extends StatefulWidget {
  final String token;
  final String currentPhone;
  final String? currentName;

  /// Switch muvaffaqiyatli bo'lganda — SplashPage ga redirect
  final VoidCallback onSwitched;

  const TelegramAccountHeader({
    super.key,
    required this.token,
    required this.currentPhone,
    this.currentName,
    required this.onSwitched,
  });

  @override
  State<TelegramAccountHeader> createState() => _TelegramAccountHeaderState();
}

class _TelegramAccountHeaderState extends State<TelegramAccountHeader>
    with SingleTickerProviderStateMixin {
  List<AccountSession> _accounts = [];
  bool _expanded = false;
  bool _loadingSessions = true;
  int? _switchingId;

  late AnimationController _animController;
  late Animation<double> _rotateAnim;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _expandAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);

    _loadSessions();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions({bool showSnackbarOnError = false}) async {
    if (!mounted) return;
    setState(() => _loadingSessions = true);

    final result = await MultiAccountService.getSessions(widget.token);

    if (!mounted) return;
    setState(() => _loadingSessions = false);

    if (result.isSuccess) {
      setState(() => _accounts = result.data ?? []);
    } else if (showSnackbarOnError) {
      _Snack.error(context, result.errorMessage!);
    }
  }

  void _toggleExpanded() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    _expanded ? _animController.forward() : _animController.reverse();
  }

  // ── Switch account — token va barcha ma'lumotlarni LocalSource ga saqlaydi ──
  Future<void> _switchToAccount(AccountSession session) async {
    HapticFeedback.lightImpact();
    setState(() => _switchingId = session.sessionId);

    final result = await MultiAccountService.switchAccount(
        widget.token, session.sessionId);

    if (!mounted) return;
    setState(() => _switchingId = null);

    if (result.isSuccess) {
      final data = result.data!;

      // ✅ LocalSource ga saqlash
      final localSource = sl<LocalSource>();
      localSource.setAccessToken("Bearer ${data.accessToken}");
      localSource.setRefreshToken(data.refreshToken);
      localSource.setPhoneNumber(data.phone);
      // Agar LocalSource da mavjud bo'lsa quyidagilarni ham saqlang:
      // localSource.setRole(data.role);
      // localSource.setSessionId(data.sessionId);
      // localSource.setExpiresIn(data.expiresIn);

      _Snack.success(context, 'Akkount muvaffaqiyatli almashtirildi');
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) widget.onSwitched();
    } else {
      _Snack.error(context, result.errorMessage!);
    }
  }

  Future<void> _addAccount() async {
    setState(() => _expanded = false);
    _animController.reverse();

    await AddAccountSheet.show(context, token: widget.token);

    if (mounted) {
      await _loadSessions(showSnackbarOnError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSession = AccountSession(
      sessionId: -1,
      phone: widget.currentPhone,
      firstName: widget.currentName,
      role: 'student',
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16139F), Color(0xFF10107E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BigAvatar(session: currentSession),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _toggleExpanded,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSession.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatPhone(widget.currentPhone),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotationTransition(
                        turns: _rotateAnim,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          SizeTransition(
            sizeFactor: _expandAnim,
            child: FadeTransition(
              opacity: _expandAnim,
              child: Container(
                color: Colors.black.withOpacity(0.15),
                child: Column(
                  children: [
                    const Divider(color: Colors.white24, height: 1),

                    if (_loadingSessions)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CupertinoActivityIndicator(color: Colors.white),
                      )
                    else if (_accounts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Text(
                          'Boshqa akkountlar yo\'q',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      ..._accounts.map((acc) {
                        final isSwitching = _switchingId == acc.sessionId;
                        return _AccountSwitchTile(
                          session: acc,
                          isSwitching: isSwitching,
                          onTap: _switchingId != null
                              ? null
                              : () => _switchToAccount(acc),
                        );
                      }),

                    _AddAccountTile(onTap: _addAccount),
                    const Divider(color: Colors.white24, height: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar (katta, header uchun) ──
class _BigAvatar extends StatelessWidget {
  final AccountSession session;

  const _BigAvatar({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: Text(
          session.initials,
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Avatar (kichik, tile uchun) ──
class _SmallAvatar extends StatelessWidget {
  final AccountSession session;

  const _SmallAvatar({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: session.avatarColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          session.initials,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Boshqa akkount tile ──
class _AccountSwitchTile extends StatelessWidget {
  final AccountSession session;
  final bool isSwitching;
  final VoidCallback? onTap;

  const _AccountSwitchTile({
    required this.session,
    required this.isSwitching,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white12,
        highlightColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _SmallAvatar(session: session),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.displayName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _formatPhone(session.phone),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isSwitching)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CupertinoActivityIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Akkount qo'shish tile ──
class _AddAccountTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAccountTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white12,
        highlightColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 1.5),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              const Text(
                'Akkount qo\'shish',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADD ACCOUNT BOTTOM SHEET
// ============================================================

class AddAccountSheet extends StatefulWidget {
  final String token;

  const AddAccountSheet({super.key, required this.token});

  static Future<void> show(BuildContext context, {required String token}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddAccountSheet(token: token),
    );
  }

  @override
  State<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<AddAccountSheet> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();

  bool _codeSent = false;
  bool _loading = false;
  String _fieldError = '';

  // TODO: device_info_plus bilan real device_id oling
  final String _deviceId = 'd290f1ee-6c54-4b01-90e6-d701748f0851';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  // ── Send code ──
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 9) {
      setState(() => _fieldError = 'Telefon raqamni to\'liq kiriting');
      return;
    }

    setState(() {
      _loading = true;
      _fieldError = '';
    });

    final result = await MultiAccountService.sendCode(phone);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.isSuccess) {
      setState(() => _codeSent = true);
      Future.delayed(
          const Duration(milliseconds: 100), () => _codeFocus.requestFocus());

      if (mounted) {
        _Snack.success(
            context, 'SMS kod ${_formatPhone(phone)} raqamiga yuborildi');
      }
    } else {
      setState(() => _fieldError = result.errorMessage!);
      if (mounted) _Snack.error(context, result.errorMessage!);
    }
  }

  // ── Verify code — VerifyCodeResponse parse qilib LocalSource ga saqlaydi ──
  Future<void> _verifyCode() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final code = _codeController.text.trim();

    if (code.length < 4) {
      setState(() => _fieldError = 'SMS kodni to\'liq kiriting');
      return;
    }

    setState(() {
      _loading = true;
      _fieldError = '';
    });

    final result = await MultiAccountService.verifyCode(
      phone: phone,
      code: code,
      deviceId: _deviceId,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.isSuccess) {
      final data = result.data!;

      // ✅ LocalSource ga saqlash
      final localSource = sl<LocalSource>();
      localSource.setAccessToken(data.accessToken);
      localSource.setRefreshToken(data.refreshToken);
      localSource.setPhoneNumber(data.phone);
      // Agar LocalSource da mavjud bo'lsa:
      // localSource.setRole(data.role);
      // localSource.setSessionId(data.sessionId);
      // localSource.setExpiresIn(data.expiresIn);

      if (mounted) {
        Navigator.pop(context);
        _Snack.success(context, 'Akkount muvaffaqiyatli qo\'shildi!');
      }
    } else {
      setState(() => _fieldError = result.errorMessage!);
      if (mounted) _Snack.error(context, result.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akkount qo\'shish',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Align(
                      key: ValueKey(_codeSent),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _codeSent
                            ? '${_formatPhone(_phoneController.text)} ga SMS yuborildi'
                            : 'Telefon raqamingizni kiriting',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _TelegramField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    hint: '+998 XX XXX XX XX',
                    keyboardType: TextInputType.phone,
                    enabled: !_codeSent && !_loading,
                    icon: Icons.phone_outlined,
                    autofocus: !_codeSent,
                    onSubmitted: (_) => !_codeSent ? _sendCode() : null,
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _codeSent
                        ? Column(
                      children: [
                        const SizedBox(height: 12),
                        _TelegramField(
                          controller: _codeController,
                          focusNode: _codeFocus,
                          hint: 'SMS kod',
                          keyboardType: TextInputType.number,
                          enabled: !_loading,
                          icon: Icons.lock_outline_rounded,
                          onSubmitted: (_) => _verifyCode(),
                        ),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _fieldError.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFFF453A), size: 15),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _fieldError,
                              style: const TextStyle(
                                  color: Color(0xFFFF453A), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: const Color(0xFF2AABEE),
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _loading
                          ? null
                          : (_codeSent ? _verifyCode : _sendCode),
                      child: _loading
                          ? const CupertinoActivityIndicator(
                          color: Colors.white)
                          : Text(
                        _codeSent ? 'Tasdiqlash' : 'Davom etish',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  if (_codeSent) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: GestureDetector(
                        onTap: _loading
                            ? null
                            : () => setState(() {
                          _codeSent = false;
                          _codeController.clear();
                          _fieldError = '';
                        }),
                        child: Text(
                          'Raqamni o\'zgartirish',
                          style: TextStyle(
                            color: const Color(0xFF2AABEE).withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TELEGRAM FIELD
// ============================================================

class _TelegramField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final bool autofocus;
  final IconData icon;
  final ValueChanged<String>? onSubmitted;

  const _TelegramField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.keyboardType,
    required this.enabled,
    required this.icon,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    const br = BorderRadius.all(Radius.circular(12));
    const noBorder =
    OutlineInputBorder(borderRadius: br, borderSide: BorderSide.none);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      enabled: enabled,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
      cursorColor: const Color(0xFF2AABEE),
      cursorWidth: 2,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: noBorder,
        enabledBorder: noBorder,
        focusedBorder: const OutlineInputBorder(
          borderRadius: br,
          borderSide: BorderSide(color: Color(0xFF2AABEE), width: 1.5),
        ),
        disabledBorder: noBorder,
        errorBorder: noBorder,
        focusedErrorBorder: noBorder,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, size: 18, color: Colors.white38),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 0),
        hintText: hint,
        hintStyle: const TextStyle(
            color: Color(0x4DFFFFFF),
            fontSize: 15,
            fontWeight: FontWeight.w400),
      ),
    );
  }
}

// ============================================================
// HELPER
// ============================================================

String _formatPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12) {
    return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} '
        '${digits.substring(5, 8)} ${digits.substring(8, 10)} '
        '${digits.substring(10)}';
  }
  return digits.startsWith('998') ? '+$digits' : raw;
}

// ============================================================
// INTEGRATSIYA — SettingsDrawer
// ============================================================
//
// Drawer(
//   width: double.infinity,
//   child: SafeArea(
//     child: Column(
//       children: [
//         TelegramAccountHeader(
//           token: localSource.getAccessToken() ?? '',
//           currentPhone: localSource.getPhoneNumber() ?? '',
//           currentName: localSource.getFirstName(),
//           onSwitched: () {
//             Navigator.pop(context);
//             Navigator.of(context, rootNavigator: true)
//               .pushNamedAndRemoveUntil(Routes.splash, (route) => false);
//           },
//         ),
//         Expanded(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [ /* ... */ ],
//           ),
//         ),
//       ],
//     ),
//   ),
// );