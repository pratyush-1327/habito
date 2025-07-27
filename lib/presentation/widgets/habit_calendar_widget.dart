import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/habit_calendar/habit_calendar_bloc.dart';

class HabitCalendarWidget extends StatelessWidget {
  final DateTime currentMonth;
  final List<Habit> habits;

  const HabitCalendarWidget({
    super.key,
    required this.currentMonth,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitCalendarBloc, HabitCalendarState>(
      builder: (context, state) {
        if (state is HabitCalendarLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HabitCalendarError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (state is HabitCalendarLoaded) {
          return _buildCalendar(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCalendar(BuildContext context, HabitCalendarLoaded state) {
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Column(
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            DateFormat('MMMM yyyy').format(currentMonth),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),

        // Weekday headers
        _buildWeekdayHeaders(context),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemCount: 42, // 6 rows × 7 days
            itemBuilder: (context, index) {
              final dayOffset = index - firstWeekday;

              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink(); // Empty cell
              }

              final day = dayOffset + 1;
              final date = DateTime(currentMonth.year, currentMonth.month, day);

              return _buildDayCell(context, state, day, date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: weekdays
          .map(
            (weekday) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: Alignment.center,
                child: Text(
                  weekday,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDayCell(
      BuildContext context, HabitCalendarLoaded state, int day, DateTime date) {
    final isToday = _isToday(date);
    final isPastDate = _isPastDate(date);

    return Card(
      margin: const EdgeInsets.all(1.0),
      elevation: isToday ? 4.0 : 1.0,
      color: isToday
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => _onDayTapped(context, date),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Day number
              Text(
                day.toString(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),

              const SizedBox(height: 2),

              // Habit indicators
              Expanded(
                child: _buildHabitIndicators(context, state, day, isPastDate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitIndicators(BuildContext context, HabitCalendarLoaded state,
      int day, bool isPastDate) {
    final indicators = <Widget>[];

    for (final habit in habits.take(3)) {
      // Show max 3 habits per day
      final entry = state.getHabitEntry(habit.id, day);
      final color = _getHabitColor(entry, isPastDate);

      indicators.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          height: 8.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      );
    }

    // Show more indicator if there are more than 3 habits
    if (habits.length > 3) {
      indicators.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          height: 8.0,
          child: Center(
            child: Text(
              '+${habits.length - 3}',
              style: TextStyle(
                fontSize: 6.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: indicators,
    );
  }

  Color _getHabitColor(HabitEntry? entry, bool isPastDate) {
    if (entry == null) {
      return isPastDate ? HabitColors.missed : HabitColors.neutral;
    }

    switch (entry.status) {
      case HabitStatus.completed:
        return HabitColors.success;
      case HabitStatus.missed:
        return HabitColors.missed;
      case HabitStatus.pending:
        return HabitColors.pending;
    }
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  void _onDayTapped(BuildContext context, DateTime date) {
    // Show day detail dialog or navigate to day detail page
    showDialog(
      context: context,
      builder: (context) => HabitDayDialog(
        date: date,
        habits: habits,
      ),
    );
  }
}

class HabitDayDialog extends StatelessWidget {
  final DateTime date;
  final List<Habit> habits;

  const HabitDayDialog({
    super.key,
    required this.date,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');

    return AlertDialog(
      title: Text(dateFormatter.format(date)),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<HabitCalendarBloc, HabitCalendarState>(
          builder: (context, state) {
            if (state is! HabitCalendarLoaded) {
              return const CircularProgressIndicator();
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final entry = state.getHabitEntry(habit.id, date.day);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(habit.color)),
                    child: Text(
                      habit.icon,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(habit.name),
                  trailing: IconButton(
                    icon: Icon(
                      entry?.status == HabitStatus.completed
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: entry?.status == HabitStatus.completed
                          ? HabitColors.success
                          : Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () {
                      context.read<HabitCalendarBloc>().add(
                            ToggleHabitForDate(habitId: habit.id, date: date),
                          );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
