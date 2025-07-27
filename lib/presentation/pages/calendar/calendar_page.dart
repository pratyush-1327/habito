import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habits_provider.dart';
import '../../providers/habit_calendar_provider.dart';
import '../add_habit_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCalendarData();
    });
  }

  void _loadCalendarData() {
    final habitsAsync = ref.read(habitsProvider);
    habitsAsync.whenData((habits) {
      ref.read(habitCalendarProvider.notifier).loadHabitCalendar(
            _currentMonth.year,
            _currentMonth.month,
            habits,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime.now();
              });
              _loadCalendarData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddHabitPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month navigation
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _currentMonth =
                          DateTime(_currentMonth.year, _currentMonth.month - 1);
                    });
                    _loadCalendarData();
                  },
                ),
                Text(
                  '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _currentMonth =
                          DateTime(_currentMonth.year, _currentMonth.month + 1);
                    });
                    _loadCalendarData();
                  },
                ),
              ],
            ),
          ),

          // Calendar content
          Expanded(
            child: habitsAsync.when(
              data: (habits) {
                if (habits.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildCalendar(habits);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading habits',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        ref.read(habitsProvider.notifier).loadHabits();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(List habits) {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Column(
      children: [
        // Weekday headers
        _buildWeekdayHeaders(),

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
              final date =
                  DateTime(_currentMonth.year, _currentMonth.month, day);

              return _buildDayCell(day, date, habits);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
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
      ),
    );
  }

  Widget _buildDayCell(int day, DateTime date, List habits) {
    final isToday = _isToday(date);

    return Card(
      margin: const EdgeInsets.all(1.0),
      elevation: isToday ? 4.0 : 1.0,
      color: isToday
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => _onDayTapped(date, habits),
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
                child: _buildHabitIndicators(day, habits),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitIndicators(int day, List habits) {
    final calendarState = ref.watch(habitCalendarProvider);
    final indicators = <Widget>[];

    for (final habit in habits.take(3)) {
      // Show max 3 habits per day
      Color color =
          Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);

      if (!calendarState.isLoading && calendarState.error == null) {
        final entry = ref
            .read(habitCalendarProvider.notifier)
            .getHabitEntry(habit.id, day);

        if (entry != null && entry.status.toString().contains('completed')) {
          color = Colors.green;
        } else if (_isPastDate(
            DateTime(_currentMonth.year, _currentMonth.month, day))) {
          color = Colors.red.withValues(alpha: 0.7);
        }
      }

      indicators.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          height: 6.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
      );
    }

    // Show more indicator if there are more than 3 habits
    if (habits.length > 3) {
      indicators.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          height: 6.0,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            'No Habits Yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first habit to start tracking',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddHabitPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Habit'),
          ),
        ],
      ),
    );
  }

  void _onDayTapped(DateTime date, List habits) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${date.day}/${date.month}/${date.year}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final calendarState = ref.watch(habitCalendarProvider);

              bool isCompleted = false;
              if (!calendarState.isLoading && calendarState.error == null) {
                final entry = ref
                    .read(habitCalendarProvider.notifier)
                    .getHabitEntry(habit.id, date.day);
                isCompleted =
                    entry?.status.toString().contains('completed') ?? false;
              }

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
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted
                        ? Colors.green
                        : Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () {
                    ref
                        .read(habitCalendarProvider.notifier)
                        .toggleHabitForDate(habit.id, date);
                  },
                ),
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
      ),
    );
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

  String _monthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}
