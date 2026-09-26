import 'package:flutter/material.dart';
import 'package:one_ui/one_ui.dart';

/// An area of One Business that is planned but not built. Says which
/// release brings it, and what it will do, without mock data.
class ComingLaterScreen extends StatelessWidget {
  const ComingLaterScreen({
    required this.title,
    required this.eyebrow,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String eyebrow;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => OneEmptyState(
    eyebrow: eyebrow,
    title: title,
    message: message,
    icon: icon,
  );
}
