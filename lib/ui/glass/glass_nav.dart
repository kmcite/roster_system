import 'package:flutter/material.dart';
import 'package:roster_system/ui/glass/glass_kit.dart';
import 'package:roster_system/ui/glass/glass_theme.dart';

/// Floating capsule navigation — icons only, sliding highlight (not a classic tab bar).
class GlassNavDock extends StatelessWidget {
  const GlassNavDock({
    super.key,
    required this.page,
    required this.onSelected,
    required this.items,
    this.isScrolling = false,
    this.onPillDragStart,
    this.onPillDragUpdate,
    this.onPillDragEnd,
  });

  /// Fractional page offset (0 .. items.length - 1), synced with [PageView].
  final double page;
  final ValueChanged<int> onSelected;
  final List<({IconData icon, String label})> items;
  final bool isScrolling;
  final GestureDragStartCallback? onPillDragStart;
  final GestureDragUpdateCallback? onPillDragUpdate;
  final GestureDragEndCallback? onPillDragEnd;

  static const _itemSize = 52.0;
  static const _settleDuration = Duration(milliseconds: 320);

  int get _roundedPage => page.round().clamp(0, items.length - 1);

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    final isDark = context.glassIsDark;
    final dockWidth = _itemSize * items.length + 16;
    final pillLeft = 8 + page.clamp(0, items.length - 1.0) * _itemSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            items[_roundedPage].label,
            key: ValueKey(_roundedPage),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: accent.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            width: dockWidth,
            height: AppGlassTheme.navDockHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppGlassTheme.border(AppGlassTheme.radiusFull),
                color: context.glassFillStrong,
                border: Border.all(color: context.glassBorderStrong),
                boxShadow: context.glassShadow(prominent: true),
              ),
              child: ClipRRect(
                borderRadius: AppGlassTheme.border(AppGlassTheme.radiusFull),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < items.length; i++)
                            _DockItem(
                              icon: items[i].icon,
                              label: items[i].label,
                              selected: _roundedPage == i,
                              proximity: (1 - (page - i).abs()).clamp(0.0, 1.0),
                              onTap: () => onSelected(i),
                            ),
                        ],
                      ),
                    ),
                    AnimatedPositioned(
                      duration: isScrolling ? Duration.zero : _settleDuration,
                      curve: Curves.easeOutCubic,
                      left: pillLeft,
                      top: 8,
                      width: _itemSize,
                      height: AppGlassTheme.navDockHeight - 16,
                      child: _DockDragPill(
                        onDragStart: onPillDragStart,
                        onDragUpdate: onPillDragUpdate,
                        onDragEnd: onPillDragEnd,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: AppGlassTheme.border(AppGlassTheme.radiusFull),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent.withValues(alpha: isDark ? 0.35 : 0.22),
                                accent.withValues(alpha: isDark ? 0.18 : 0.1),
                              ],
                            ),
                            border: Border.all(color: accent.withValues(alpha: 0.35)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draggable shell indicator — drives [PageView] from the parent shell.
class _DockDragPill extends StatelessWidget {
  const _DockDragPill({
    required this.child,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final Widget child;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: child,
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.proximity,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final double proximity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.glassAccent;
    final scale = 1.0 + proximity * 0.08;
    final iconSize = 22.0 + proximity * 2;
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: GlassNavDock._itemSize,
            height: GlassNavDock._itemSize,
            child: Center(
              child: AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: Color.lerp(
                    accent.withValues(alpha: 0.42),
                    accent,
                    proximity,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Root shell: swipeable pages with a floating dock overlay.
class GlassShell extends StatefulWidget {
  const GlassShell({
    super.key,
    required this.pages,
    required this.selectedIndex,
    required this.onSelected,
    required this.dockItems,
  });

  final List<Widget> pages;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<({IconData icon, String label})> dockItems;

  @override
  State<GlassShell> createState() => _GlassShellState();
}

class _GlassShellState extends State<GlassShell> {
  late PageController _pageController;
  double _page = 0;
  var _isScrolling = false;
  var _isDraggingPill = false;

  @override
  void initState() {
    super.initState();
    _page = widget.selectedIndex.toDouble();
    _pageController = PageController(initialPage: widget.selectedIndex)
      ..addListener(_syncPageFromController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.position.isScrollingNotifier
          .addListener(_syncPageFromController);
    });
  }

  void _syncPageFromController() {
    if (!_pageController.hasClients) return;
    final next = _pageController.page;
    if (next == null) return;
    final scrolling = _pageController.position.isScrollingNotifier.value;
    if (next != _page || scrolling != _isScrolling) {
      setState(() {
        _page = next;
        _isScrolling = scrolling;
      });
    }
  }

  @override
  void didUpdateWidget(GlassShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        _pageController.hasClients &&
        (_pageController.page ?? -1).round() != widget.selectedIndex) {
      _pageController.animateToPage(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    if (_pageController.hasClients) {
      _pageController.position.isScrollingNotifier
          .removeListener(_syncPageFromController);
    }
    _pageController.removeListener(_syncPageFromController);
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPillDragStart(DragStartDetails _) {
    setState(() => _isDraggingPill = true);
  }

  void _scrubByDragDelta(double dx) {
    if (!_pageController.hasClients) return;
    final position = _pageController.position;
    final target = (position.pixels - dx).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _pageController.jumpTo(target);
  }

  void _onPillDragUpdate(DragUpdateDetails details) {
    _scrubByDragDelta(details.delta.dx);
  }

  void _onPillDragEnd(DragEndDetails details) {
    setState(() => _isDraggingPill = false);
    if (!_pageController.hasClients) return;
    final current = _pageController.page ?? _page;
    final velocity = details.velocity.pixelsPerSecond.dx;
    var target = current.round();
    if (velocity.abs() > 400) {
      target = velocity < 0 ? current.floor() + 1 : current.ceil() - 1;
    }
    target = target.clamp(0, widget.pages.length - 1);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageSettled(int index) {
    widget.onSelected(index);
    setState(() => _page = index.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageSettled,
            children: widget.pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: AppGlassTheme.navDockBottomMargin,
                ),
                child: GlassNavDock(
                  page: _page,
                  isScrolling: _isScrolling || _isDraggingPill,
                  items: widget.dockItems,
                  onSelected: _goToPage,
                  onPillDragStart: _onPillDragStart,
                  onPillDragUpdate: _onPillDragUpdate,
                  onPillDragEnd: _onPillDragEnd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
