import 'package:flutter/material.dart';

class AppRefresh extends StatelessWidget {
  const AppRefresh({super.key, required this.onRefresh, required this.child, this.edgeOffset});

  final Future<void> Function() onRefresh;
  final Widget child;
  final double? edgeOffset;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      edgeOffset: edgeOffset ?? 0.0,
      child: PrimaryScrollController.none(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: child,
        ),
      ),
    );
  }
}


