import 'package:flutter/material.dart';

/// Floating bottom nav bar – exact match to the reference screenshot
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartBadgeCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartBadgeCount;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}