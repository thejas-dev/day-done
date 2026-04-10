import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_tracker/core/theme/app_colors.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/calendar_day_tasks_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/providers/calendar_provider.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/filter_chip_bar.dart';
import 'package:todo_tracker/features/tasks/presentation/widgets/task_tile.dart';

/// Calendar view with month navigation and per-date task dots.
/// Tapping a date shows that day's tasks inline below the calendar.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  TaskFilter _filter = const TaskFilter();

  @override
  Widget build(BuildContext context) {
    final indicatorsAsync = ref.watch(
      calendarIndicatorsProvider(_focusedDay.year, _focusedDay.month),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          // Calendar widget
          indicatorsAsync.when(
            data: (indicators) => _buildCalendar(context, indicators),
            loading: () => _buildCalendar(context, const {}),
            error: (_, _) => _buildCalendar(context, const {}),
          ),
          const Divider(height: 1),

          // Selected day's tasks
          Expanded(
            child: _SelectedDayTaskList(
              selectedDay: _selectedDay,
              filter: _filter,
              onFilterChanged: (filter) {
                setState(() => _filter = filter);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
      BuildContext context, Map<DateTime, int> indicators) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return TableCalendar<void>(
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _filter = const TaskFilter(); // Reset filter on date change
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle:
            theme.textTheme.titleMedium ?? const TextStyle(),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: theme.colorScheme.onSurface,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: theme.textTheme.labelSmall ?? const TextStyle(),
        weekendStyle: theme.textTheme.labelSmall ?? const TextStyle(),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: (isLight ? AppColors.primaryLight : AppColors.primaryLightDarkMode),
          shape: BoxShape.circle,
        ),
        todayTextStyle: (theme.textTheme.bodyMedium ?? const TextStyle())
            .copyWith(
                color: isLight
                    ? AppColors.primaryDark
                    : AppColors.primaryDarkDarkMode),
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: (theme.textTheme.bodyMedium ?? const TextStyle())
            .copyWith(color: AppColors.onPrimary),
        defaultTextStyle:
            theme.textTheme.bodyMedium ?? const TextStyle(),
        weekendTextStyle:
            theme.textTheme.bodyMedium ?? const TextStyle(),
        outsideTextStyle: (theme.textTheme.bodyMedium ?? const TextStyle())
            .copyWith(
                color: isLight
                    ? AppColors.textMutedLight
                    : AppColors.textMutedDark),
        markersMaxCount: 1,
        markerDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        markerSize: 6,
        markersAlignment: Alignment.bottomCenter,
        markerMargin: const EdgeInsets.only(top: 2),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final dateKey =
              DateTime(date.year, date.month, date.day);
          final count = indicators[dateKey] ?? 0;
          if (count == 0) return null;
          return Positioned(
            bottom: 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Shows tasks for the selected date: dated tasks + daily instances.
class _SelectedDayTaskList extends ConsumerWidget {
  const _SelectedDayTaskList({
    required this.selectedDay,
    required this.filter,
    required this.onFilterChanged,
  });

  final DateTime selectedDay;
  final TaskFilter filter;
  final ValueChanged<TaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(calendarDayTasksProvider(selectedDay));

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Failed to load tasks: $error'),
      ),
      data: (allTasks) {
        if (allTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No tasks for this date',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final filteredTasks = filter.apply(allTasks);

        return CustomScrollView(
          slivers: [
            // Filter chip bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: FilterChipBar(
                  tasks: allTasks,
                  onFilterChanged: onFilterChanged,
                ),
              ),
            ),

            if (filteredTasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list_off,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No tasks match current filters',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) =>
                    TaskTile(task: filteredTasks[index]),
              ),

            const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl5)),
          ],
        );
      },
    );
  }
}
