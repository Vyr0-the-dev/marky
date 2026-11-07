import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:marky/app/theme/reading_room_tokens.dart';
import 'package:marky/core/database/enums/automation_action_type.dart';
import 'package:marky/core/database/enums/automation_trigger_type.dart';
import 'package:marky/core/utils/l10n_extension.dart';
import 'package:marky/features/automation/data/automation_rule_providers.dart';
import 'package:marky/features/automation/domain/automation_rule.dart';

/// Editorial create / edit screen for a single automation rule.
class AutomationRuleEditorScreen extends ConsumerStatefulWidget {
  const AutomationRuleEditorScreen({this.ruleId, super.key});

  /// `null` → create mode, otherwise edit.
  final int? ruleId;

  @override
  ConsumerState<AutomationRuleEditorScreen> createState() =>
      _AutomationRuleEditorScreenState();
}

class _AutomationRuleEditorScreenState
    extends ConsumerState<AutomationRuleEditorScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _priorityCtrl =
      TextEditingController(text: '100');
  final List<_ConditionDraft> _conditions = <_ConditionDraft>[
    _ConditionDraft(),
  ];
  final List<_ActionDraft> _actions = <_ActionDraft>[_ActionDraft()];

  AutomationTriggerLogic _triggerLogic = AutomationTriggerLogic.all;
  AutomationRule? _loadedRule;
  bool _enabled = true;
  bool _saving = false;

  bool get _isEdit => widget.ruleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final AutomationRule? rule = await ref
        .read(automationRuleRepositoryProvider)
        .getById(widget.ruleId!);
    if (rule == null || !mounted) return;
    setState(() {
      _loadedRule = rule;
      _nameCtrl.text = rule.name;
      _descriptionCtrl.text = rule.description ?? '';
      _triggerLogic = rule.triggerLogic;
      _enabled = rule.enabled;
      _priorityCtrl.text = rule.priority.toString();
      for (final _ConditionDraft condition in _conditions) {
        condition.dispose();
      }
      _conditions
        ..clear()
        ..addAll(rule.conditions.map(_ConditionDraft.fromCondition));
      for (final _ActionDraft action in _actions) {
        action.dispose();
      }
      _actions
        ..clear()
        ..addAll(
          rule.actions.isEmpty
              ? <_ActionDraft>[_ActionDraft()]
              : rule.actions.map(_ActionDraft.fromAction),
        );
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priorityCtrl.dispose();
    for (final _ConditionDraft condition in _conditions) {
      condition.dispose();
    }
    for (final _ActionDraft action in _actions) {
      action.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Kuralı Düzenle' : 'Yeni Otomasyon Kuralı',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ReadingRoomSpacing.lg,
          vertical: ReadingRoomSpacing.md,
        ),
        children: <Widget>[
          // ── Kural Profili Kartı ─────────────────────────────
          _buildCard(
            context,
            icon: Icons.tune_rounded,
            title: 'Kural Tanımı',
            accentColor: colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kural Adı',
                    hintText: 'örn. YouTube Videolarını Etiketle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.md),
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (İsteğe Bağlı)',
                    hintText: 'Kuralın amacını kısaca belirtin...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _priorityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Öncelik',
                          helperText: 'Küçük numaralar önce çalışır.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: ReadingRoomSpacing.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Kural Aktif',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: _enabled,
                          onChanged: (bool value) =>
                              setState(() => _enabled = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.xl),

          // ── Koşullar Kartı (EĞER) ───────────────────────────
          _buildCard(
            context,
            icon: Icons.filter_alt_rounded,
            title: 'Koşullar (EĞER)',
            accentColor: colors.secondary,
            trailing: _conditions.length > 1
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_conditions.length} Koşul',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Koşulların sağlanma kuralı:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AutomationTriggerLogic>(
                    segments: <ButtonSegment<AutomationTriggerLogic>>[
                      ButtonSegment<AutomationTriggerLogic>(
                        value: AutomationTriggerLogic.all,
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(context.l10n.automationMatchAll),
                      ),
                      ButtonSegment<AutomationTriggerLogic>(
                        value: AutomationTriggerLogic.any,
                        icon: const Icon(Icons.rule_folder_outlined, size: 16),
                        label: Text(context.l10n.automationMatchAny),
                      ),
                    ],
                    selected: <AutomationTriggerLogic>{_triggerLogic},
                    onSelectionChanged: (Set<AutomationTriggerLogic> selected) {
                      setState(() => _triggerLogic = selected.first);
                    },
                  ),
                ),
                const SizedBox(height: ReadingRoomSpacing.lg),
                for (int i = 0; i < _conditions.length; i++)
                  _buildConditionEditor(context, i),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _addCondition,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(context.l10n.automationAddCondition),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.xl),

          // ── Eylemler Kartı (İSE) ─────────────────────────────
          _buildCard(
            context,
            icon: Icons.bolt_rounded,
            title: context.l10n.automationThen,
            accentColor: colors.tertiary,
            trailing: _actions.length > 1
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.tertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_actions.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < _actions.length; i++)
                  _buildActionEditor(context, i),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _addAction,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(context.l10n.automationAddActionBtn),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.xl),

          // ── Kaydet Butonu ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 22),
              label: Text(
                _isEdit
                    ? 'Değişiklikleri Güncelle'
                    : 'Otomasyon Kuralını Kaydet',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: ReadingRoomSpacing.huge),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color accentColor,
    required Widget child,
    Widget? trailing,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard),
        border: Border.all(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReadingRoomSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(width: ReadingRoomSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: ReadingRoomSpacing.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildConditionEditor(BuildContext context, int index) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final _ConditionDraft condition = _conditions[index];

    return Container(
      margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.md),
      padding: const EdgeInsets.all(ReadingRoomSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard - 2),
        border: Border.all(color: colors.outline.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<AutomationTriggerType>(
                  initialValue: condition.type,
                  decoration: const InputDecoration(
                    labelText: 'Tetikleyici Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: AutomationTriggerType.values
                      .map(
                        (AutomationTriggerType t) =>
                            DropdownMenuItem<AutomationTriggerType>(
                          value: t,
                          child: Text(_triggerLabel(t)),
                        ),
                      )
                      .toList(),
                  onChanged: (AutomationTriggerType? value) {
                    if (value == null) return;
                    setState(() {
                      condition.type = value;
                      if (value == AutomationTriggerType.contentTypeEquals &&
                          (condition.value.text.trim().isEmpty ||
                              !_isValidContentType(condition.value.text))) {
                        condition.value.text = 'article';
                      }
                    });
                  },
                ),
              ),
              if (_conditions.length > 1) ...<Widget>[
                const SizedBox(width: ReadingRoomSpacing.xs),
                IconButton(
                  tooltip: 'Koşulu Sil',
                  onPressed: () => _removeCondition(index),
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: colors.error),
                ),
              ],
            ],
          ),
          const SizedBox(height: ReadingRoomSpacing.md),
          if (condition.type == AutomationTriggerType.contentTypeEquals)
            _buildContentTypeSelector(context, condition)
          else if (condition.type ==
              AutomationTriggerType.readingTimeGreaterThan)
            _buildReadingTimeInput(context, condition)
          else
            TextField(
              controller: condition.value,
              decoration: InputDecoration(
                labelText: _triggerLabel(condition.type),
                hintText: _triggerHint(condition.type),
                helperText: _triggerHelperText(condition.type),
                border: const OutlineInputBorder(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentTypeSelector(
    BuildContext context,
    _ConditionDraft condition,
  ) {
    final ThemeData theme = Theme.of(context);
    final String current = condition.value.text.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'İçerik türünü seçin:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: ReadingRoomSpacing.sm),
        Wrap(
          spacing: ReadingRoomSpacing.sm,
          runSpacing: ReadingRoomSpacing.xs,
          children: _contentTypeOptions.map((option) {
            final bool isSelected = current == option.value ||
                (option.value == 'tweet' && current == 'discussion') ||
                (option.value == 'repository' && current == 'code');

            return FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: Icon(
                option.icon,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              label: Text(option.label),
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ReadingRoomRadii.chip),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    condition.value.text = option.value;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReadingTimeInput(
    BuildContext context,
    _ConditionDraft condition,
  ) {
    final String text = condition.value.text.trim();
    final int? parsed = int.tryParse(text);
    final bool hasError = text.isNotEmpty && (parsed == null || parsed <= 0);

    return TextField(
      controller: condition.value,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'Okuma süresi şundan büyük:',
        hintText: 'örn. 5',
        suffixText: 'dakika',
        errorText: hasError ? 'Pozitif bir dakika değeri girin' : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildActionEditor(BuildContext context, int index) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final _ActionDraft action = _actions[index];
    final bool requiresArg = _actionRequiresArg(action.type);

    return Container(
      margin: const EdgeInsets.only(bottom: ReadingRoomSpacing.md),
      padding: const EdgeInsets.all(ReadingRoomSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(ReadingRoomRadii.standard - 2),
        border: Border.all(color: colors.outline.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<AutomationActionType>(
                  initialValue: action.type,
                  decoration: const InputDecoration(
                    labelText: 'Eylem Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: AutomationActionType.values
                      .map(
                        (AutomationActionType a) =>
                            DropdownMenuItem<AutomationActionType>(
                          value: a,
                          child: Text(_actionLabel(a)),
                        ),
                      )
                      .toList(),
                  onChanged: (AutomationActionType? value) {
                    if (value == null) return;
                    setState(() => action.type = value);
                  },
                ),
              ),
              if (_actions.length > 1) ...<Widget>[
                const SizedBox(width: ReadingRoomSpacing.xs),
                IconButton(
                  tooltip: 'Eylemi Sil',
                  onPressed: () => _removeAction(index),
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20, color: colors.error),
                ),
              ],
            ],
          ),
          if (requiresArg) ...<Widget>[
            const SizedBox(height: ReadingRoomSpacing.md),
            TextField(
              controller: action.arg,
              decoration: InputDecoration(
                labelText: _actionArgHint(action.type),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addCondition() {
    setState(() => _conditions.add(_ConditionDraft()));
  }

  void _removeCondition(int index) {
    if (_conditions.length <= 1) return;
    final _ConditionDraft removed = _conditions.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _addAction() {
    setState(() => _actions.add(_ActionDraft()));
  }

  void _removeAction(int index) {
    if (_actions.length <= 1) return;
    final _ActionDraft removed = _actions.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    final String name = _nameCtrl.text.trim();
    final String description = _descriptionCtrl.text.trim();
    final int priority = int.tryParse(_priorityCtrl.text.trim()) ?? 100;
    final List<AutomationCondition> conditions = <AutomationCondition>[
      for (final _ConditionDraft condition in _conditions)
        AutomationCondition(
          type: condition.type,
          value: condition.value.text.trim(),
        ),
    ];
    final List<AutomationAction> actions = <AutomationAction>[
      for (final _ActionDraft action in _actions)
        AutomationAction(
          type: action.type,
          arg: _actionRequiresArg(action.type) ? action.arg.text.trim() : '',
        ),
    ];

    if (name.isEmpty ||
        conditions.any(
          (AutomationCondition condition) => condition.value.isEmpty,
        ) ||
        actions.isEmpty ||
        actions.any(
          (AutomationAction action) =>
              _actionRequiresArg(action.type) && action.arg.isEmpty,
        )) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.automationFillRequiredFields),
          ),
        );
      return;
    }

    for (final AutomationCondition condition in conditions) {
      if (condition.type == AutomationTriggerType.readingTimeGreaterThan) {
        final int? minutes = int.tryParse(condition.value);
        if (minutes == null || minutes <= 0) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Okuma süresi 0 dakikadan büyük bir sayı olmalıdır.',
                ),
              ),
            );
          return;
        }
      }
    }

    setState(() => _saving = true);

    try {
      final DateTime now = DateTime.now();
      final AutomationCondition primaryCondition = conditions.first;
      final AutomationRule rule = AutomationRule(
        id: widget.ruleId,
        name: name,
        description: description.isEmpty ? null : description,
        enabled: _enabled,
        triggerType: primaryCondition.type,
        triggerValue: primaryCondition.value,
        triggerLogic: _triggerLogic,
        conditions: conditions,
        actions: actions,
        priority: priority,
        executionCount: _loadedRule?.executionCount ?? 0,
        lastExecutedAt: _loadedRule?.lastExecutedAt,
        createdAt: _loadedRule?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(automationRuleRepositoryProvider).save(rule);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.automationRuleSaveError(e.toString())),
            ),
          );
      }
    }
  }

  // ── Labels ──────────────────────────────────────────────────────

  static const List<({String value, String label, IconData icon})>
      _contentTypeOptions = <({String value, String label, IconData icon})>[
    (value: 'article', label: 'Makale', icon: Icons.article_outlined),
    (value: 'video', label: 'Video', icon: Icons.videocam_outlined),
    (value: 'image', label: 'Görsel', icon: Icons.image_outlined),
    (value: 'audio', label: 'Ses', icon: Icons.audiotrack_outlined),
    (value: 'tweet', label: 'Tweet / Gönderi', icon: Icons.tag_rounded),
    (value: 'repository', label: 'Kod Deposu (Repo)', icon: Icons.code_rounded),
  ];

  static bool _isValidContentType(String value) {
    final String clean = value.trim().toLowerCase();
    return _contentTypeOptions.any((option) => option.value == clean) ||
        clean == 'discussion' ||
        clean == 'code';
  }

  static String _triggerLabel(AutomationTriggerType t) {
    switch (t) {
      case AutomationTriggerType.domainEquals:
        return 'Alan adı tam eşleşirse';
      case AutomationTriggerType.domainContains:
        return 'Alan adı içeriyorsa';
      case AutomationTriggerType.urlContains:
        return 'URL içeriyorsa';
      case AutomationTriggerType.sourceTypeEquals:
        return 'Kaynak türü şuna eşitse';
      case AutomationTriggerType.tagContains:
        return 'Etiket ID içeriyorsa';
      case AutomationTriggerType.unreadForDays:
        return 'Şu kadar gün okunmadıysa';
      case AutomationTriggerType.addedWithinDays:
        return 'Son şu kadar günde eklendiyse';
      case AutomationTriggerType.contentTypeEquals:
        return 'İçerik türü şuna eşitse';
      case AutomationTriggerType.readingTimeGreaterThan:
        return 'Okuma süresi şundan büyükse (dk)';
      case AutomationTriggerType.titleContains:
        return 'Başlık içeriyorsa...';
      case AutomationTriggerType.titleMatchesRegex:
        return 'Başlık Regex ile eşleşirse...';
    }
  }

  static String _triggerHint(AutomationTriggerType t) {
    switch (t) {
      case AutomationTriggerType.domainEquals:
        return 'örn. youtube.com';
      case AutomationTriggerType.domainContains:
        return 'örn. github';
      case AutomationTriggerType.urlContains:
        return 'örn. /blog/';
      case AutomationTriggerType.sourceTypeEquals:
        return 'örn. share';
      case AutomationTriggerType.tagContains:
        return 'Etiket ID (örn. 5)';
      case AutomationTriggerType.unreadForDays:
        return 'Gün sayısı (örn. 7)';
      case AutomationTriggerType.addedWithinDays:
        return 'Gün sayısı (örn. 3)';
      case AutomationTriggerType.contentTypeEquals:
        return 'İçerik türü';
      case AutomationTriggerType.readingTimeGreaterThan:
        return 'Dakika (örn. 5)';
      case AutomationTriggerType.titleContains:
        return 'örn. Rehber, Flutter, Güncelleme';
      case AutomationTriggerType.titleMatchesRegex:
        return r'örn. v[0-9]+\.[0-9]+';
    }
  }

  static String? _triggerHelperText(AutomationTriggerType t) {
    switch (t) {
      case AutomationTriggerType.titleContains:
        return 'Başlıkta büyük/küçük harf duyarsız metin arar';
      case AutomationTriggerType.titleMatchesRegex:
        return 'Düzenli ifade (Regex) deseni ile eşleştirir';
      case AutomationTriggerType.domainEquals:
      case AutomationTriggerType.domainContains:
      case AutomationTriggerType.urlContains:
      case AutomationTriggerType.sourceTypeEquals:
      case AutomationTriggerType.tagContains:
      case AutomationTriggerType.unreadForDays:
      case AutomationTriggerType.addedWithinDays:
      case AutomationTriggerType.contentTypeEquals:
      case AutomationTriggerType.readingTimeGreaterThan:
        return null;
    }
  }

  static String _actionLabel(AutomationActionType a) {
    switch (a) {
      case AutomationActionType.addTag:
        return 'Etiket Ekle';
      case AutomationActionType.addToCollection:
        return 'Koleksiyona Ekle';
      case AutomationActionType.setFavorite:
        return 'Favori Durumunu Belirle';
      case AutomationActionType.setArchived:
        return 'Arşiv Durumunu Belirle';
      case AutomationActionType.setPinned:
        return 'Sabitleme Durumunu Belirle';
      case AutomationActionType.addReminder:
        return 'Hatırlatıcı Kur';
    }
  }

  static String _actionArgHint(AutomationActionType a) {
    switch (a) {
      case AutomationActionType.addTag:
        return 'Etiket Adı (örn. teknoloji)';
      case AutomationActionType.addToCollection:
        return 'Koleksiyon Adı veya ID';
      case AutomationActionType.setFavorite:
      case AutomationActionType.setArchived:
      case AutomationActionType.setPinned:
        return 'true (evet) veya false (hayır)';
      case AutomationActionType.addReminder:
        return 'Kaç gün sonra (örn. 3)';
    }
  }

  static bool _actionRequiresArg(AutomationActionType action) {
    return true;
  }
}

class _ConditionDraft {
  _ConditionDraft({
    this.type = AutomationTriggerType.domainEquals,
    String value = '',
  }) : value = TextEditingController(
          text: (type == AutomationTriggerType.contentTypeEquals &&
                  value.trim().isEmpty)
              ? 'article'
              : value,
        );

  factory _ConditionDraft.fromCondition(AutomationCondition condition) {
    return _ConditionDraft(type: condition.type, value: condition.value);
  }

  AutomationTriggerType type;
  final TextEditingController value;

  void dispose() {
    value.dispose();
  }
}

class _ActionDraft {
  _ActionDraft({
    this.type = AutomationActionType.addTag,
    String arg = '',
  }) : arg = TextEditingController(text: arg);

  factory _ActionDraft.fromAction(AutomationAction action) {
    return _ActionDraft(type: action.type, arg: action.arg);
  }

  AutomationActionType type;
  final TextEditingController arg;

  void dispose() {
    arg.dispose();
  }
}
