import 'package:my_flutter_template/features/screen_lock/presentation/page_args/screen_lock_args.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/widgets/keyboard_widget.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/widgets/upper_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/services/refresh_token_service.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../blocs/screen_lock_bloc.dart';

class ScreenLockPage extends StatefulWidget {
  final ScreenLockPageArgs? args;

  const ScreenLockPage({super.key, required this.args});

  @override
  State<ScreenLockPage> createState() => _ScreenLockPageState();
}

class _ScreenLockPageState extends State<ScreenLockPage> {
  final localSource = sl<LocalSource>();
  final RefreshTokenService _refreshTokenService = RefreshTokenService();

  @override
  void initState() {
    super.initState();
    _refreshToken();
    final status = widget.args?.status ??
        (localSource.getPinCode() != null
            ? ScreenLockStatus.check
            : ScreenLockStatus.create);

    debugPrint('📱 ScreenLockPage: initState with status = $status');

    context.read<ScreenLockBloc>().add(
      ScreenLockSetStatusEvent(status: status),
    );
  }

  Future<void> _refreshToken() async {
    print('🔄 Starting token refresh...');
    try {
      if (_refreshTokenService.hasRefreshToken()) {
        await _refreshTokenService.refreshAccessToken();
        print('✅ Token successfully refreshed in MainPage');
      } else {
        print('⚠️ No refresh token found');
      }
    } catch (e) {
      print('❌ Token refresh failed in MainPage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final status = widget.args?.status ??
        (localSource.getPinCode() != null
            ? ScreenLockStatus.check
            : ScreenLockStatus.create);

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Align(
                alignment: Alignment.centerLeft,
                child: canPop
                    ? IconButton(
                        padding: const EdgeInsets.only(left: 12),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Color(0xFF0F172A), size: 26),
                        onPressed: () => Navigator.of(context).maybePop(),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: UpperTextWidget(status: status),
            ),
            SizedBox(
              height: mediaQuery.size.height > 800
                  ? mediaQuery.size.height * 0.42
                  : mediaQuery.size.height * 0.48,
              child: KeyboardWidget(status: status),
            ),
          ],
        ),
      ),
    );
  }
}
