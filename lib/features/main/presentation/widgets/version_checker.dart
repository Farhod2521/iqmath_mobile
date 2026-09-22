import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Versiya tekshiruvi va "Yangilanish mavjud" oynasini yoqish/o'chirish.
///
/// Vaqtincha `false` qilib qo'yilgan — oyna umuman ko'rsatilmaydi va API ga
/// so'rov ham yuborilmaydi. Qayta yoqish uchun `true` qilish kifoya.
const bool kVersionCheckEnabled = false;

class VersionCheckService {

  VersionCheckService();

  Future<VersionCheckResult> checkVersion() async {
    try {
      // Hozirgi app versiyasini olish
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      print('📱 ════════════════════════════════════════════════════════');
      print('📱 VERSION CHECK STARTED');
      print('📱 ════════════════════════════════════════════════════════');
      print('📱 Current App Version: $currentVersion');
      print('📱 Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');
      print('📱 Build Number: ${packageInfo.buildNumber}');
      print('📱 Package Name: ${packageInfo.packageName}');

      // API dan versiya ma'lumotlarini olish
      print('📱 Fetching version from API...');
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/management/mobile/version/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('📱 ❌ Request timeout after 10 seconds');
          throw Exception('Request timeout');
        },
      );

      print('📱 API Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('📱 ❌ Failed to load version info: ${response.statusCode}');
        throw Exception('Failed to load version info: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      print('📱 API Response Data: $data');

      // Null check va data validation
      if (data == null) {
        print('📱 ❌ Empty response from server');
        throw Exception('Empty response from server');
      }

      String latestVersion;

      // Platform bo'yicha tekshirish
      if (Platform.isAndroid) {
        latestVersion = data['android_latest_version']?.toString() ?? '';
        print('📱 Latest Android Version from API: $latestVersion');
        if (latestVersion.isEmpty) {
          print('📱 ❌ Android version not found in response');
          throw Exception('Android version not found in response');
        }
      } else if (Platform.isIOS) {
        latestVersion = data['ios_latest_version']?.toString() ?? '';
        print('📱 Latest iOS Version from API: $latestVersion');
        if (latestVersion.isEmpty) {
          print('📱 ❌ iOS version not found in response');
          throw Exception('iOS version not found in response');
        }
      } else {
        print('📱 ❌ Unsupported platform');
        throw UnsupportedError('Platform not supported');
      }

      // Versiyalarni solishtirish
      final comparisonResult = _compareVersions(currentVersion, latestVersion);
      final needsUpdate = comparisonResult < 0;

      print('📱 ────────────────────────────────────────────────────────');
      print('📱 COMPARISON RESULT:');
      print('📱 Current: $currentVersion');
      print('📱 Latest:  $latestVersion');
      print('📱 Comparison: ${comparisonResult == -1 ? 'Current < Latest (Update needed)' : comparisonResult == 0 ? 'Current = Latest (Up to date)' : 'Current > Latest (Newer version)'}');
      print('📱 Needs Update: ${needsUpdate ? '✅ YES' : '❌ NO'}');
      print('📱 ════════════════════════════════════════════════════════');

      return VersionCheckResult(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        needsUpdate: needsUpdate,
      );
    } on http.ClientException catch (e) {
      // Internet bilan bog'liq muammolar
      print('📱 ❌ Network error: $e');
      print('📱 ════════════════════════════════════════════════════════');
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      // JSON parse xatoligi
      print('📱 ❌ Invalid response format: $e');
      print('📱 ════════════════════════════════════════════════════════');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      // Boshqa xatolar
      print('📱 ❌ Version check failed: $e');
      print('📱 ════════════════════════════════════════════════════════');
      throw Exception('Version check failed: $e');
    }
  }

  // Versiyalarni solishtirish (1.0.1 vs 1.0.2)
  int _compareVersions(String current, String latest) {
    try {
      print('📱 Comparing versions: $current vs $latest');

      // Versiya formatini tekshirish
      if (current.isEmpty || latest.isEmpty) {
        print('📱 ⚠️ Empty version string detected');
        return 0;
      }

      final currentParts = current.split('.').map((e) {
        final parsed = int.tryParse(e);
        return parsed ?? 0;
      }).toList();

      final latestParts = latest.split('.').map((e) {
        final parsed = int.tryParse(e);
        return parsed ?? 0;
      }).toList();

      print('📱 Current parts: $currentParts');
      print('📱 Latest parts: $latestParts');

      final maxLength = currentParts.length > latestParts.length
          ? currentParts.length
          : latestParts.length;

      for (int i = 0; i < maxLength; i++) {
        final currentPart = i < currentParts.length ? currentParts[i] : 0;
        final latestPart = i < latestParts.length ? latestParts[i] : 0;

        print('📱 Comparing part $i: $currentPart vs $latestPart');

        if (currentPart < latestPart) {
          print('📱 Result: -1 (current < latest)');
          return -1;
        }
        if (currentPart > latestPart) {
          print('📱 Result: 1 (current > latest)');
          return 1;
        }
      }

      print('📱 Result: 0 (versions are equal)');
      return 0; // Versiyalar bir xil
    } catch (e) {
      // Xatolik bo'lsa, yangilanish kerak emas deb hisoblaymiz
      print('📱 ❌ Error comparing versions: $e');
      return 0;
    }
  }
}

class VersionCheckResult {
  final String currentVersion;
  final String latestVersion;
  final bool needsUpdate;

  VersionCheckResult({
    required this.currentVersion,
    required this.latestVersion,
    required this.needsUpdate,
  });
}

class UpdateDialog extends StatefulWidget {
  final String currentVersion;
  final String latestVersion;

  const UpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 340),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.blue.shade50.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(),
                            _buildContent(),
                            _buildButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      child: Column(
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: value * 0.5,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.purple.shade400,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.blue.shade600,
                Colors.purple.shade600,
              ],
            ).createShader(bounds),
            child: const Text(
              'Yangilanish mavjud',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Version cards
          _buildVersionCard(
            'Hozirgi versiya',
            widget.currentVersion,
            Icons.phone_android_rounded,
            Colors.grey.shade100,
            Colors.grey.shade700,
            false,
          ),
          const SizedBox(height: 12),
          // Arrow animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -5 + (value * 10)),
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.blue.withOpacity(0.6),
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildVersionCard(
            'Yangi versiya',
            widget.latestVersion,
            Icons.auto_awesome_rounded,
            Colors.blue.shade50,
            Colors.blue.shade700,
            true,
          ),
          const SizedBox(height: 24),
          // Info message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.orange.shade100.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.shade200.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.priority_high_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ilovadan foydalanish uchun yangilash zarur',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVersionCard(
      String label,
      String version,
      IconData icon,
      Color bgColor,
      Color textColor,
      bool isNew,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew
              ? Colors.blue.shade200.withOpacity(0.5)
              : Colors.grey.shade300.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: isNew
            ? [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: isNew
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade600,
                ],
              )
                  : null,
              color: isNew ? null : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isNew ? Colors.white : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  version,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'YANGI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openStore(context),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade500,
                  Colors.purple.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Hozir yangilash',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    try {
      Uri url;

      if (Platform.isAndroid) {
        url = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.iqmath.mobile',
        );
      } else if (Platform.isIOS) {
        url = Uri.parse(
          'https://apps.apple.com/app/id6753702778',
        );
      } else {
        throw UnsupportedError('Platform not supported');
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackbar(context, 'Store ochishda xatolik yuz berdi');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Xatolik: $e');
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}