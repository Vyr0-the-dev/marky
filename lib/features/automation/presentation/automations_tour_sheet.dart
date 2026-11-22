import 'package:flutter/material.dart';
import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/utils/l10n_extension.dart';
import 'package:marky/l10n/app_localizations.dart';
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
  String? finishLabel,
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
    this.finishLabel,
  });

  final VoidCallback? onFinish;
  final String? finishLabel;

  @override
  State<AutomationsTourSheet> createState() => _AutomationsTourSheetState();
}

class _AutomationsTourSheetState extends State<AutomationsTourSheet> {
  static const int _stepCount = 4;

  late final PageController _pageController = PageController();
  int _currentPage = 0;

  static List<_TourStepData> _buildSteps(AppLocalizations l10n) {
    return <_TourStepData>[
      _TourStepData(
        icon: Icons.auto_awesome_rounded,
        title: l10n.automationTourStep1Title,
        body: l10n.automationTourStep1Body,
        chips: <String>[
          l10n.automationTourStep1Chip1,
          l10n.automationTourStep1Chip2,
          l10n.automationTourStep1Chip3,
        ],
      ),
      _TourStepData(
        icon: Icons.travel_explore_rounded,
        title: l10n.automationTourStep2Title,
        body: l10n.automationTourStep2Body,
        chips: <String>[
          'youtube.com',
          'github.com',
          '/articles/',
          l10n.automationTourStep2Chip4,
        ],
      ),
      _TourStepData(
        icon: Icons.bolt_rounded,
        title: l10n.automationTourStep3Title,
        body: l10n.automationTourStep3Body,
        chips: <String>[
          l10n.automationTourStep3Chip1,
          l10n.automationTourStep3Chip2,
          l10n.automationTourStep3Chip3,
        ],
      ),
      _TourStepData(
        icon: Icons.science_rounded,
        title: l10n.automationTourStep4Title,
        body: l10n.automationTourStep4Body,
        chips: <String>[
          l10n.automationTourStep4Chip1,
          l10n.automationTourStep4Chip2,
          l10n.automationTourStep4Chip3,
        ],
      ),
    ];
  }

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
    if (_currentPage < _stepCount - 1) {
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
    final AppLocalizations l10n = context.l10n;
    final List<_TourStepData> steps = _buildSteps(l10n);
    final String resolvedFinishLabel =
        widget.finishLabel ?? l10n.automationTourFinish;

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
                    l10n.automationTourTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    key: const Key('automations_tour_close_button'),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: l10n.actionClose,
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
                itemCount: steps.length,
                itemBuilder: (BuildContext context, int index) {
                  final _TourStepData step = steps[index];
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
                      child: Text(l10n.automationTourBack),
                    )
                  else
                    TextButton(
                      key: const Key('automations_tour_skip_button'),
                      onPressed: _finish,
                      child: Text(l10n.automationTourSkip),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(steps.length, (int index) {
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
                  if (_currentPage < steps.length - 1)
                    FilledButton(
                      key: const Key('automations_tour_next_button'),
                      onPressed: _nextPage,
                      child: Text(l10n.automationTourNext),
                    )
                  else
                    FilledButton(
                      key: const Key('automations_tour_finish_button'),
                      onPressed: _finish,
                      child: Text(resolvedFinishLabel),
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
