import 'package:flutter/material.dart';

enum SnackType { success, error, warning, info }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _SnackbarWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.error);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.info);
}

class _SnackbarWidget extends StatefulWidget {
  final String message;
  final SnackType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _SnackbarWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _controller.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _SnackStyle _style(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    switch (widget.type) {
      case SnackType.success:
      case SnackType.info:
        return _SnackStyle(
          color: colorScheme.primary,
          bgColor: colorScheme.primary.withValues(alpha: 0.12),
          icon: widget.type == SnackType.success
              ? Icons.check_circle_rounded
              : Icons.info_rounded,
        );
      case SnackType.error:
        return _SnackStyle(
          color: colorScheme.error,
          bgColor: colorScheme.error.withValues(alpha: 0.12),
          icon: Icons.error_rounded,
        );
      case SnackType.warning:
        final warningColor = theme.brightness == Brightness.dark
            ? Colors.amber.shade300
            : Colors.orange.shade800;
        return _SnackStyle(
          color: warningColor,
          bgColor: warningColor.withValues(alpha: 0.12),
          icon: Icons.warning_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _style(theme);
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () async {
                await _controller.reverse();
                widget.onDismiss();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: style.color.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: style.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(style.icon, color: style.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnackStyle {
  final Color color;
  final Color bgColor;
  final IconData icon;

  _SnackStyle({required this.color, required this.bgColor, required this.icon});
}
