import 'package:flutter/material.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key that tracks whether the automations tour has been seen.
const String automationsTourSeenKey = 'has_seen_automations_tour_v1';

/// Returns whether the user has completed or dismissed the automations tour.
Future<bool> hasSeenAutomationsTour() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(automationsTourSeenKey) ?? false;
}

/// Persistently marks the automations tour as seen so it will not auto-trigger again.
Future<void> markAutomationsTourSeen() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(automationsTourSeenKey, true);
}

/// Displays the stepped contextual automations tour in a Reading Room bottom sheet.
///
/// If [markAsSeen] is true, immediately saves the seen state in [SharedPreferences].
Future<void> showAutomationsTour(
  BuildContext context, {
  bool markAsSeen = true,
  String finishLabel = 'Got it',
}) async {
  if (markAsSeen) {
    await markAutomationsTourSeen();
  }
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ReadingRoomRadii.sheet),
      ),
    ),
    builder: (BuildContext sheetContext) {
      return AutomationsTourSheet(
        finishLabel: finishLabel,
      );
    },
  );
}

/// Data definition for a single tour step.
class _TourStepData {
  const _TourStepData({
    required this.icon,
    required this.title,
    required this.body,
    required this.chips,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> chips;
}

/// Stepped contextual walkthrough for the Automations feature.
class AutomationsTourSheet extends StatefulWidget {
  const AutomationsTourSheet({
    super.key,
    this.onFinish,
    this.finishLabel = 'Got it',
  });

  final VoidCallback? onFinish;
  final String finishLabel;

  @override
  State<AutomationsTourSheet> createState() => _AutomationsTourSheetState();
}

class _AutomationsTourSheetState extends State<AutomationsTourSheet> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_TourStepData> _steps = <_TourStepData>[
    _TourStepData(
      icon: Icons.auto_awesome_rounded,
      title: 'Welcome to Automations',
      body: 'Let Marky organize your bookmarks hands-free. Set up rules to '
          'automatically categorize, tag, and sort your links as they arrive.',
      chips: <String>['Hands-free', 'Automatic', 'Runs on save'],
    ),
    _TourStepData(
      icon: Icons.travel_explore_rounded,
      title: 'Powerful Triggers',
      body: 'Target specific bookmarks by matching domains, keywords in URLs, '
          'content types, or tags. Combine conditions with AND / OR logic.',
      chips: <String>['youtube.com', 'github.com', '/articles/', 'AND / OR'],
    ),
    _TourStepData(
      icon: Icons.bolt_rounded,
      title: 'Instant Actions',
      body: 'Chain multiple actions in one go: auto-tagging, filing into '
          'collections, favorites, archive, or scheduled reminders.',
      chips: <String>['+ Add Tag', 'File to Collection', 'Set Reminder'],
    ),
    _TourStepData(
      icon: Icons.science_rounded,
      title: 'Priority & Testing',
      body:
          'Rules execute in top-to-bottom order whenever bookmarks are added. '
          'Test with a single link and inspect Debug Logs anytime.',
      chips: <String>['Top-to-bottom', 'Single link test', 'Debug logs'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: ReadingRoomMotion.standard,
        curve: ReadingRoomMotion.standardCurve,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: ReadingRoomMotion.standard,
        curve: ReadingRoomMotion.standardCurve,
      );
    }
  }

  void _finish() {
    markAutomationsTourSeen();
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        height: 460,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.lg,
                vertical: ReadingRoomSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Automation Tour',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    key: const Key('automations_tour_close_button'),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                    onPressed: _finish,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  if (mounted) {
                    setState(() {
                      _currentPage = page;
                    });
                  }
                },
                itemCount: _steps.length,
                itemBuilder: (BuildContext context, int index) {
                  final _TourStepData step = _steps[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ReadingRoomSpacing.xl,
                        vertical: ReadingRoomSpacing.md,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(ReadingRoomSpacing.lg),
                              child: Icon(
                                step.icon,
                                size: 36,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: ReadingRoomSpacing.lg),
                          Text(
                            step.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: ReadingRoomSpacing.sm),
                          Text(
                            step.body,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                          if (step.chips.isNotEmpty) ...<Widget>[
                            const SizedBox(height: ReadingRoomSpacing.md),
                            Wrap(
                              spacing: ReadingRoomSpacing.xs,
                              runSpacing: ReadingRoomSpacing.xs,
                              alignment: WrapAlignment.center,
                              children: step.chips
                                  .map(
                                    (String label) => _TourChip(label: label),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ReadingRoomSpacing.lg,
                vertical: ReadingRoomSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  if (_currentPage > 0)
                    TextButton(
                      key: const Key('automations_tour_back_button'),
                      onPressed: _prevPage,
                      child: const Text('Back'),
                    )
                  else
                    TextButton(
                      key: const Key('automations_tour_skip_button'),
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(_steps.length, (int index) {
                      final bool active = index == _currentPage;
                      return AnimatedContainer(
                        duration: ReadingRoomMotion.standard,
                        curve: ReadingRoomMotion.standardCurve,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  if (_currentPage < _steps.length - 1)
                    FilledButton(
                      key: const Key('automations_tour_next_button'),
                      onPressed: _nextPage,
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      key: const Key('automations_tour_finish_button'),
                      onPressed: _finish,
                      child: Text(widget.finishLabel),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourChip extends StatelessWidget {
  const _TourChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReadingRoomSpacing.sm,
        vertical: ReadingRoomSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
