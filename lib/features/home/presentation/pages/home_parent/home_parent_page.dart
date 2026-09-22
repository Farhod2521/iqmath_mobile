import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/add_child_dialog.dart'
    show AddChildDialog;
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_children_widget.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import '../../../../../core/local_source/local_source.dart';
import '../../../../../injector_container.dart';
import '../../../../../router/app_routes.dart';

class HomeParentPage extends StatefulWidget {
  const HomeParentPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeParentPageState();
}

class _HomeParentPageState extends State<HomeParentPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _coinController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController nameController = TextEditingController(
    text: sl<LocalSource>().getFirstName() ?? '',
  );

  final PageController _pageController = PageController();
  int _currentTipIndex = 0;
  Timer? _tipTimer;
  int userBalance = 50000;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTipTimer();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _coinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
    _rotationController.repeat();
    _coinController.repeat();
  }

  void _startTipTimer() {
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _pageController.hasClients) {
        _currentTipIndex = (_currentTipIndex + 1) % 3;
        _pageController.animateToPage(
          _currentTipIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _coinController.dispose();
    _pageController.dispose();
    _refreshNotifier.dispose();
    super.dispose();
  }

  final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      key: scaffoldKey,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    _refreshNotifier.value++;
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(builder: (contextInline) {
                          return _buildUltraMinimalProfileHeader(
                            contextInline,
                            nameController.text,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ParentCardsWidget(
                    refreshNotifier: _refreshNotifier,
                  ),
                ),
                SliverToBoxAdapter(
                  child: AddChildFloatingButton(
                    onPressed: () {
                      _showAddChildDialog(context);
                    },
                  ),
                ),
                SliverGap(80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddChildDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddChildDialog(),
    );

    if (result == true) {
      // Dialog muvaffaqiyatli yopilganda refresh qilish
      _refreshNotifier.value++;
    }
  }

  Widget _buildUltraMinimalProfileHeader(
    BuildContext contextInline,
    String name,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.color.primaryColor1.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                HapticFeedback.lightImpact();
                mainScaffoldKey.currentState?.openDrawer();
              },
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.color.primaryColor1.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: context.color.primaryColor1.withOpacity(0.1),
                  child: const Icon(Icons.person),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
                letterSpacing: -0.3,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(
                    mainRootNavigatorKey.currentContext!, Routes.notification);
              },
              borderRadius: BorderRadius.circular(10),
              splashColor: context.color.primaryColor1.withOpacity(0.15),
              highlightColor: context.color.primaryColor1.withOpacity(0.08),
              child: Ink(
                decoration: BoxDecoration(
                  color: context.color.primaryColor1.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 19,
                    color: context.color.primaryColor1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
