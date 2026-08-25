import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/theme/theme_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, required this.nextPageBuilder});

  final WidgetBuilder nextPageBuilder;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoRotation;
  late final Animation<Offset> _logoPosition;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final Animation<Offset> _titlePosition;
  late final Animation<double> _titleOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // ─────────────────────────────────────────
    // LOGO
    // ─────────────────────────────────────────

    // Le logo roule plusieurs fois avant d'arriver
    // au centre.
    _logoRotation = Tween<double>(
      begin: -2.5,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.62,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Arrive depuis la gauche
    _logoPosition = Tween<Offset>(
      begin: const Offset(-1.8, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.62,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Petit effet de zoom pendant l'arrivée
    _logoScale = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.62,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.18,
          curve: Curves.easeIn,
        ),
      ),
    );

    // ─────────────────────────────────────────
    // TITRE CHRONOS
    // ─────────────────────────────────────────

    // Le texte arrive du bas
    _titlePosition = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.58,
          0.88,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.60,
          0.82,
          curve: Curves.easeIn,
        ),
      ),
    );

    _controller.forward().then((_) => _finishSplash());
  }

  Future<void> _finishSplash() async {
    await ref.read(loadThemeProvider.future);
    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextPageBuilder(context),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─────────────────────────────
                // LOGO
                // ─────────────────────────────
                FadeTransition(
                  opacity: _logoOpacity,
                  child: SlideTransition(
                    position: _logoPosition,
                    child: RotationTransition(
                      turns: _logoRotation,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Image.asset(
                          'lib/assets/images/Logo.png',
                          width: 170,
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ─────────────────────────────
                // NOM CHRONOS
                // ─────────────────────────────
                FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titlePosition,
                    child: const Text(
                      'CHRONOS',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: Color(0xFF1683F7),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

