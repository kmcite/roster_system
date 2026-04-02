import 'package:flutter/material.dart';

class Cell extends StatelessWidget {
  final String data;

  final VoidCallback? onPressed;
  const Cell(
    this.data, {
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isAssigned = data != '-';
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isAssigned
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          foregroundColor: isAssigned
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          padding: .symmetric(horizontal: 4, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          data,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
