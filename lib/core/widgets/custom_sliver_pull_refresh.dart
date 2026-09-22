import 'package:flutter/cupertino.dart';

import 'custom_loading_indicator.dart';

class CustomSliverPullRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const CustomSliverPullRefresh({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance,
          refreshIndicatorExtent) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: refreshIndicatorExtent,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: CustomLoadingIndicator(
                size:
                    pulledExtent >= refreshIndicatorExtent ? 50 : pulledExtent,
              ),
            ),
          ),
        );
      },
    );
  }
}
