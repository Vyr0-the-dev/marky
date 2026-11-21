import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _onboardingShownKey = 'marky_onboarding_shown';

Future<bool> hasSeenOnboarding() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingShownKey) ?? false;
}

Future<void> markOnboardingSeen() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingShownKey, true);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);

    final List<_OnboardingPage> pages = <_OnboardingPage>[
      _OnboardingPage(
        icon: Icons.share_rounded,
        title: l10n?.onboardingPage1Title ?? 'Save from anywhere',
        body: l10n?.onboardingPage1Body ??
            'Share links directly to Marky from any app. Paste a URL, scan a QR code, or type it in — your library grows effortlessly.',
      ),
      _OnboardingPage(
        icon: Icons.sell_outlined,
        title: l10n?.onboardingPage2Title ?? 'Organize with tags',
        body: l10n?.onboardingPage2Body ??
            'Tag bookmarks by topic, group them in collections, and favorite the best ones. Everything stays tidy and easy to find.',
      ),
      _OnboardingPage(
        icon: Icons.auto_fix_high_rounded,
        title: l10n?.onboardingPage3Title ?? 'Automate the busywork',
        body: l10n?.onboardingPage3Body ??
            'Create rules to auto-tag, auto-archive, or auto-collect links as they arrive. Set it once and let Marky handle the rest.',
      ),
      _OnboardingPage(
        icon: Icons.auto_stories_outlined,
        title: l10n?.onboardingPage4Title ?? 'Read distraction-free',
        body: l10n?.onboardingPage4Body ??
            'Set reminders for unread links, search with operators, and enjoy a calm offline-first Reader mode.',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: ReadingRoomSpacing.md),
            Row(
              children: <Widget>[
                const Spacer(),
                TextButton(
                  onPressed: _finish,
                  child: Text(
                    _currentPage == pages.length - 1
                        ? (l10n?.onboardingDone ?? 'Get started')
                        : (l10n?.onboardingSkip ?? 'Skip'),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ReadingRoomSpacing.xl,
                    ),
                    child: pages[index],
                  );
                },
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(pages.length, (int index) {
                final bool active = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            const SizedBox(height: ReadingRoomSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.xl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed:
                      _currentPage == pages.length - 1 ? _finish : _nextPage,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    _currentPage == pages.length - 1
                        ? (l10n?.onboardingDone ?? 'Get started')
                        : (l10n?.onboardingNext ?? 'Next'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: ReadingRoomSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    unawaited(
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _finish() {
    unawaited(markOnboardingSeen());
    Navigator.of(context).pop();
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Spacer(flex: 2),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: ReadingRoomSpacing.xxxl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: ReadingRoomSpacing.md),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}
