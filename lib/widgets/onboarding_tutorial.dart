import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/tutorial_service.dart';

class OnboardingTutorial extends StatefulWidget {
  const OnboardingTutorial({
    super.key,
    required this.child,
    required this.welcomeKey,
    required this.statsKey,
    required this.calendarKey,
    required this.tasksKey,
    required this.habitsKey,
  });

  final Widget child;
  final GlobalKey welcomeKey;
  final GlobalKey statsKey;
  final GlobalKey calendarKey;
  final GlobalKey tasksKey;
  final GlobalKey habitsKey;

  @override
  State<OnboardingTutorial> createState() => _OnboardingTutorialState();
}

class _OnboardingTutorialState extends State<OnboardingTutorial> {
  static const _pages = [
    _TutorialPage(
      'lib/assets/images/tutorial/welcome.svg',
      'Bienvenue sur Chronos !',
      'Organisez votre temps et gardez une vue claire de vos priorites depuis votre accueil.',
    ),
    _TutorialPage(
      'lib/assets/images/tutorial/stats.svg',
      'Suivez vos statistiques',
      'Visualisez votre progression et votre rythme de travail au fil des jours.',
    ),
    _TutorialPage(
      'lib/assets/images/tutorial/calendar.svg',
      'Planifiez votre semaine',
      'Retrouvez vos evenements et les jours importants dans le calendrier.',
    ),
    _TutorialPage(
      'lib/assets/images/tutorial/tasks.svg',
      'Gerez vos taches',
      'Ajoutez, completez et organisez les actions qui font avancer vos projets.',
    ),
    _TutorialPage(
      'lib/assets/images/tutorial/habits.svg',
      'Construisez vos habitudes',
      'Suivez les habitudes que vous voulez maintenir et avancez regulierement.',
    ),
  ];

  int _pageIndex = 0;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    if (!await TutorialService.shouldShowTutorial() || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  Future<void> _close() async {
    await TutorialService.markTutorialAsSeen();
    if (mounted) setState(() => _visible = false);
  }

  void _next() {
    if (_pageIndex == _pages.length - 1) {
      _close();
      return;
    }
    setState(() => _pageIndex += 1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_visible)
          _TutorialPageView(
            page: _pages[_pageIndex],
            pageIndex: _pageIndex,
            pageCount: _pages.length,
            onPrevious: _pageIndex == 0
                ? null
                : () => setState(() => _pageIndex -= 1),
            onNext: _next,
            onSkip: _close,
          ),
      ],
    );
  }
}

class _TutorialPage {
  const _TutorialPage(this.image, this.title, this.description);

  final String image;
  final String title;
  final String description;
}

class _TutorialPageView extends StatelessWidget {
  const _TutorialPageView({
    required this.page,
    required this.pageIndex,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
  });

  final _TutorialPage page;
  final int pageIndex;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text('Passer le tutoriel'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      SvgPicture.asset(page.image, height: 220),
                      const SizedBox(height: 28),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pageCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: index == pageIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == pageIndex
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (onPrevious != null)
                    OutlinedButton(
                      onPressed: onPrevious,
                      child: const Text('Precedent'),
                    )
                  else
                    const SizedBox(width: 104),
                  const Spacer(),
                  FilledButton(
                    onPressed: onNext,
                    child: Text(
                      pageIndex == pageCount - 1 ? 'Commencer' : 'Suivant',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
