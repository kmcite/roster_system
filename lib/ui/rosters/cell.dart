import 'package:flutter/material.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';

class Cell extends StatelessWidget {
  const Cell(
    this.data, {
    this.onPressed,
    super.key,
  });

  final String data;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isAssigned = data != '-' && data != '—';
    final accent = context.glassAccent;
    return GlassTappableCard(
      onTap: onPressed,
      tint: isAssigned ? accent.withValues(alpha: 0.22) : null,
      child: Center(
        child: Text(
          data,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isAssigned ? FontWeight.w700 : FontWeight.w500,
            color: isAssigned ? accent : accent.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
