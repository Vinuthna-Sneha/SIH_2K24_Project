import 'package:flutter/material.dart';

class AppScrollbar extends StatelessWidget {
  final Widget child;

  const AppScrollbar({super.key, required this.child, required bool thumbVisibility});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior(), // Use default scroll behavior
      child: Scrollbar(
        thumbVisibility: false, // Make scrollbar invisible
        child: child,
      ),
    );
  }
}
