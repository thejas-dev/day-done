import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/settings/domain/notification_mode.dart';
import 'package:todo_tracker/features/settings/presentation/providers/settings_provider.dart';

/// Settings screen: bedtime picker, morning check-in picker,
/// notification mode selector.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => _SettingsBody(
          bedtime: settings.bedtime,
          morningCheckin: settings.morningCheckin,
          notificationMode: settings.notificationMode,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Failed to load settings: $error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({
    required this.bedtime,
    required this.morningCheckin,
    required this.notificationMode,
  });

  final DateTime bedtime;
  final DateTime morningCheckin;
  final NotificationMode notificationMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      children: [
        // ── Bedtime ──────────────────────────────────────────────────
        _SectionHeader(title: 'Schedule'),
        const SizedBox(height: AppSpacing.sm),
        _SettingsTile(
          icon: Icons.bedtime_outlined,
          title: 'Bedtime',
          subtitle: _formatTime(bedtime),
          onTap: () => _pickBedtime(context, ref),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SettingsTile(
          icon: Icons.wb_sunny_outlined,
          title: 'Morning check-in',
          subtitle: _formatTime(morningCheckin),
          onTap: () => _pickMorningCheckin(context, ref),
        ),

        const SizedBox(height: AppSpacing.xl2),

        // ── Notification mode ────────────────────────────────────────
        _SectionHeader(title: 'Notifications'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Choose how often DayDone reminds you about pending tasks.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _NotificationModeSelector(
          selected: notificationMode,
          onChanged: (mode) {
            ref.read(settingsActionsProvider.notifier).updateNotificationMode(mode);
          },
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Show a custom picker for bedtime (6:00 PM - 3:00 AM, 15-min increments).
  Future<void> _pickBedtime(BuildContext context, WidgetRef ref) async {
    final times = _generateBedtimeSlots();
    final currentIndex = _findClosestIndex(times, bedtime);

    final selected = await _showTimePicker(
      context: context,
      title: 'Set bedtime',
      times: times,
      initialIndex: currentIndex,
    );

    if (selected != null) {
      await ref.read(settingsActionsProvider.notifier).updateBedtime(selected);
    }
  }

  /// Show a custom picker for morning check-in (5:00 AM - 12:00 PM, 15-min).
  Future<void> _pickMorningCheckin(BuildContext context, WidgetRef ref) async {
    final times = _generateMorningSlots();
    final currentIndex = _findClosestIndex(times, morningCheckin);

    final selected = await _showTimePicker(
      context: context,
      title: 'Set morning check-in',
      times: times,
      initialIndex: currentIndex,
    );

    if (selected != null) {
      await ref
          .read(settingsActionsProvider.notifier)
          .updateMorningCheckin(selected);
    }
  }

  /// Bedtime range: 6:00 PM (18:00) to 3:00 AM (03:00), 15-min increments.
  List<DateTime> _generateBedtimeSlots() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final slots = <DateTime>[];

    // 18:00 to 23:45 today
    for (var h = 18; h <= 23; h++) {
      for (var m = 0; m < 60; m += 15) {
        slots.add(DateTime(today.year, today.month, today.day, h, m));
      }
    }
    // 00:00 to 03:00 tomorrow (stored as next-day times, but we store hour/min)
    for (var h = 0; h <= 3; h++) {
      for (var m = 0; m < 60; m += 15) {
        if (h == 3 && m > 0) break;
        slots.add(DateTime(tomorrow.year, tomorrow.month, tomorrow.day, h, m));
      }
    }

    return slots;
  }

  /// Morning check-in range: 5:00 AM to 12:00 PM, 15-min increments.
  List<DateTime> _generateMorningSlots() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slots = <DateTime>[];

    for (var h = 5; h <= 12; h++) {
      for (var m = 0; m < 60; m += 15) {
        if (h == 12 && m > 0) break;
        slots.add(DateTime(today.year, today.month, today.day, h, m));
      }
    }

    return slots;
  }

  int _findClosestIndex(List<DateTime> times, DateTime target) {
    final targetMinutes = target.hour * 60 + target.minute;
    var closest = 0;
    var minDiff = 99999;

    for (var i = 0; i < times.length; i++) {
      final slotMinutes = times[i].hour * 60 + times[i].minute;
      final diff = (slotMinutes - targetMinutes).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = i;
      }
    }
    return closest;
  }

  Future<DateTime?> _showTimePicker({
    required BuildContext context,
    required String title,
    required List<DateTime> times,
    required int initialIndex,
  }) async {
    DateTime? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return _TimePickerSheet(
          title: title,
          times: times,
          initialIndex: initialIndex,
          onSelected: (dt) {
            result = dt;
            ctx.pop();
          },
        );
      },
    );

    return result;
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationModeSelector extends StatelessWidget {
  const _NotificationModeSelector({
    required this.selected,
    required this.onChanged,
  });

  final NotificationMode selected;
  final ValueChanged<NotificationMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: NotificationMode.values.map((mode) {
        return _NotificationModeOption(
          mode: mode,
          isSelected: mode == selected,
          onTap: () => onChanged(mode),
        );
      }).toList(),
    );
  }
}

class _NotificationModeOption extends StatelessWidget {
  const _NotificationModeOption({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final NotificationMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  _modeIcon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _modeTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _modeDescription,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _modeIcon => switch (mode) {
        NotificationMode.minimal => Icons.notifications_off_outlined,
        NotificationMode.standard => Icons.notifications_outlined,
        NotificationMode.persistent => Icons.notifications_active_outlined,
      };

  String get _modeTitle => switch (mode) {
        NotificationMode.minimal => 'Minimal',
        NotificationMode.standard => 'Standard',
        NotificationMode.persistent => 'Persistent',
      };

  String get _modeDescription => switch (mode) {
        NotificationMode.minimal => 'Bedtime reminder only',
        NotificationMode.standard =>
          'Morning check-in, 2h & 1h before bedtime',
        NotificationMode.persistent =>
          'Morning + frequent reminders as bedtime approaches',
      };
}

/// Bottom sheet for scrollable time selection.
class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({
    required this.title,
    required this.times,
    required this.initialIndex,
    required this.onSelected,
  });

  final String title;
  final List<DateTime> times;
  final int initialIndex;
  final ValueChanged<DateTime> onSelected;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  String _formatSlot(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              widget.title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Time grid
            SizedBox(
              height: 280,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemCount: widget.times.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        _formatSlot(widget.times[index]),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            ElevatedButton(
              onPressed: () => widget.onSelected(widget.times[_selectedIndex]),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
