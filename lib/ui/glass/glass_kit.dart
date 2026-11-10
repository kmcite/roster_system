import 'package:flutter/material.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';

/// Visual weight without backdrop blur — solid layered surfaces.
enum GlassSurface { standard, elevated, primary }

BoxDecoration glassDecoration(
  BuildContext context, {
  required double radius,
  GlassSurface surface = GlassSurface.standard,
  Color? tint,
}) {
  final isDark = context.glassIsDark;
  final fill = tint ?? switch (surface) {
    GlassSurface.standard => context.glassFill,
    GlassSurface.elevated => context.glassFillStrong,
    GlassSurface.primary => context.glassAccent.withValues(alpha: 0.92),
  };
  final borderColor = surface == GlassSurface.primary
      ? context.glassAccent.withValues(alpha: 0.45)
      : context.glassBorder;

  Gradient? gradient;
  if (tint == null && surface == GlassSurface.elevated) {
    gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.06),
              fill,
            ]
          : [
              Colors.white,
              fill,
            ],
    );
  } else if (surface == GlassSurface.primary) {
    gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        context.glassAccent.withValues(alpha: 0.95),
        context.glassAccent.withValues(alpha: 0.82),
      ],
    );
  }

  return BoxDecoration(
    borderRadius: AppGlassTheme.border(radius),
    border: Border.all(color: borderColor),
    color: gradient == null ? fill : null,
    gradient: gradient,
    boxShadow: surface == GlassSurface.standard
        ? null
        : context.glassShadow(prominent: surface == GlassSurface.elevated),
  );
}

class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppGlassTheme.backdropGradient(context.glassIsDark),
          stops: const [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = AppGlassTheme.radiusMd,
    this.surface = GlassSurface.standard,
    this.tint,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double radius;
  final GlassSurface surface;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: glassDecoration(
          context,
          radius: radius,
          surface: surface,
          tint: tint,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    return GlassBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}

class GlassRouteScaffold extends StatelessWidget {
  const GlassRouteScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final titleColor = context.glassIsDark ? Colors.white : const Color(0xFF1A2A44);
    return GlassScaffold(
      appBar: title == null
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: leading,
              title: Text(title!, style: TextStyle(fontWeight: FontWeight.w700, color: titleColor)),
              actions: actions,
            ),
      body: SafeArea(child: body),
    );
  }
}

class GlassTabPage extends StatelessWidget {
  const GlassTabPage({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.eyebrow,
    this.actions = const [],
    this.floatingActionButton,
    this.reserveNavInset = true,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;

  /// When true, keeps list content and FAB above the floating nav dock.
  final bool reserveNavInset;

  @override
  Widget build(BuildContext context) {
    final isDark = context.glassIsDark;
    final accent = context.glassAccent;
    final bottomInset = reserveNavInset ? AppGlassTheme.navContentInset(context) : 20.0;

    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 14, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (eyebrow != null)
                            Text(eyebrow!, style: AppGlassTheme.sectionEyebrow(context, isDark: isDark)),
                          if (eyebrow != null) const SizedBox(height: 6),
                          Text(title, style: AppGlassTheme.pageTitle(context, isDark: isDark)),
                          if (subtitle != null) ...[
                            const SizedBox(height: 6),
                            Text(subtitle!, style: AppGlassTheme.pageSubtitle(context, isDark: isDark)),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: AppGlassTheme.border(AppGlassTheme.radiusFull),
                              gradient: LinearGradient(
                                colors: [
                                  accent,
                                  context.glassSecondary.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: body,
                ),
              ),
            ],
          ),
        ),
        if (floatingActionButton != null)
          Positioned(
            right: AppGlassTheme.navDockHorizontalMargin,
            bottom: bottomInset - 8,
            child: floatingActionButton!,
          ),
      ],
    );
  }
}

class GlassSectionHeader extends StatelessWidget {
  const GlassSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
                color: context.glassAccent,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final radius = AppGlassTheme.border(AppGlassTheme.radiusSm);
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          decoration: glassDecoration(
            context,
            radius: AppGlassTheme.radiusSm,
            surface: GlassSurface.elevated,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: context.glassAccent),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: tooltip == null ? button : Tooltip(message: tooltip!, child: button),
    );
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.primary = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;
  final bool primary;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    final radius = AppGlassTheme.border(AppGlassTheme.radiusSm);
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: primary ? Colors.white : accent),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: primary ? Colors.white : accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: radius,
        child: Ink(
          decoration: glassDecoration(
            context,
            radius: AppGlassTheme.radiusSm,
            surface: primary ? GlassSurface.primary : GlassSurface.standard,
            tint: primary ? null : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: content,
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class GlassFab extends StatelessWidget {
  const GlassFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      primary: true,
      icon: icon,
      label: label,
      onPressed: onPressed,
    );
  }
}

class GlassStatBanner extends StatelessWidget {
  const GlassStatBanner({
    super.key,
    required this.title,
    required this.value,
    required this.leading,
    this.trailing,
  });

  final String title;
  final String value;
  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    return GlassPanel(
      surface: GlassSurface.elevated,
      radius: AppGlassTheme.radiusLg,
      child: Row(
        children: [
          GlassCircle(child: leading),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(title, style: TextStyle(color: accent.withValues(alpha: 0.75))),
                Text(
                  value,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accent),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class GlassCircle extends StatelessWidget {
  const GlassCircle({super.key, required this.child, this.size = 52});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: size / 2,
      surface: GlassSurface.standard,
      padding: EdgeInsets.zero,
      child: SizedBox(width: size, height: size, child: Center(child: child)),
    );
  }
}

class GlassAvatar extends StatelessWidget {
  const GlassAvatar({super.key, required this.label, this.size = 48});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = label.isEmpty ? '?' : label.substring(0, 1).toUpperCase();
    return GlassCircle(
      size: size,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: context.glassAccent,
        ),
      ),
    );
  }
}

class GlassListTile extends StatelessWidget {
  const GlassListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing = const Icon(Icons.chevron_right_rounded),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = AppGlassTheme.border(AppGlassTheme.radiusMd);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: glassDecoration(context, radius: AppGlassTheme.radiusMd),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (subtitle != null)
                        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassEmptyState extends StatelessWidget {
  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        surface: GlassSurface.elevated,
        radius: AppGlassTheme.radiusLg,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(icon, size: 52, color: context.glassAccent.withValues(alpha: 0.7)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: context.glassIsDark ? Colors.white70 : const Color(0xFF2A3A52),
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}

class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (label != null)
          Text(label!, style: TextStyle(fontWeight: FontWeight.w600, color: context.glassAccent)),
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: TextStyle(color: context.glassIsDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class GlassSearchField extends StatelessWidget {
  const GlassSearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      hint: hint,
      prefixIcon: Icon(Icons.search_rounded, color: context.glassAccent),
      onChanged: onChanged,
    );
  }
}

class GlassDialogFrame extends StatelessWidget {
  const GlassDialogFrame({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final Widget title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      surface: GlassSurface.elevated,
      radius: AppGlassTheme.radiusLg,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.glassAccent,
            ),
            child: title,
          ),
          body,
          if (actions.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: actions,
            ),
        ],
      ),
    );
  }
}

Future<T?> showGlassDialog<T>(BuildContext context, {required Widget builder}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black45,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: builder,
    ),
  );
}

Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black45,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: GlassPanel(
          surface: GlassSurface.elevated,
          margin: const EdgeInsets.fromLTRB(
            AppGlassTheme.navDockHorizontalMargin,
            0,
            AppGlassTheme.navDockHorizontalMargin,
            AppGlassTheme.navDockBottomMargin,
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          radius: AppGlassTheme.radiusLg,
          child: child,
        ),
      );
    },
  );
}

class GlassChip extends StatelessWidget {
  const GlassChip({super.key, required this.label, this.icon, this.onTap});

  final String label;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = AppGlassTheme.border(AppGlassTheme.radiusSm);
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (icon != null) icon!,
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
    if (onTap == null) {
      return GlassPanel(
        radius: AppGlassTheme.radiusSm,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: labelRow,
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: glassDecoration(context, radius: AppGlassTheme.radiusSm),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: labelRow,
        ),
      ),
    );
  }
}

class GlassCoverageBar extends StatelessWidget {
  const GlassCoverageBar({
    super.key,
    required this.filled,
    required this.total,
    this.label,
  });

  final int filled;
  final int total;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    final variant = context.glassSecondary;
    final progress = total == 0 ? 0.0 : filled / total;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label ?? 'Duty coverage',
                  style: TextStyle(fontWeight: FontWeight.w600, color: accent),
                ),
              ),
              Text('$filled / $total', style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
            ],
          ),
          ClipRRect(
            borderRadius: AppGlassTheme.border(AppGlassTheme.radiusXs),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: accent.withValues(alpha: 0.12),
              color: variant,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassDayChip extends StatelessWidget {
  const GlassDayChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.filledCount,
    this.slotTotal,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? filledCount;
  final int? slotTotal;

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    final radius = AppGlassTheme.border(AppGlassTheme.radiusSm);
    final meta = filledCount != null && slotTotal != null ? '$filledCount/$slotTotal' : null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: glassDecoration(
              context,
              radius: AppGlassTheme.radiusSm,
              tint: selected ? accent.withValues(alpha: 0.15) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: selected ? accent : accent.withValues(alpha: 0.55),
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.0,
                      color: accent.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassTappableCard extends StatelessWidget {
  const GlassTappableCard({
    super.key,
    required this.onTap,
    required this.child,
    this.tint,
    this.surface = GlassSurface.standard,
    this.padding = const EdgeInsets.all(16),
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color? tint;
  final GlassSurface surface;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final radius = AppGlassTheme.border(AppGlassTheme.radiusMd);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: glassDecoration(
            context,
            radius: AppGlassTheme.radiusMd,
            surface: surface,
            tint: tint,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
