import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habits_provider.dart';
import '../../providers/habit_calendar_provider.dart';
import '../../../domain/entities/habit_entry.dart';
import '../add_habit_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _currentMonth = DateTime.now();
  final Set<String> _selectedHabitFilters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attemptInitialLoad());
  }

  void _attemptInitialLoad() {
    final habitsValue = ref.read(habitsProvider);
    habitsValue.whenData((habits) {
      if (habits.isNotEmpty) {
        ref.read(habitCalendarProvider.notifier).loadHabitCalendar(
              _currentMonth.year,
              _currentMonth.month,
              habits,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final calendarState = ref.watch(habitCalendarProvider);

    // Reactively reload when habits list changes length (new habit added / first load)
    habitsAsync.whenData((habits) {
      if (calendarState.habits.isEmpty && habits.isNotEmpty) {
        // first population
        ref
            .read(habitCalendarProvider.notifier)
            .loadHabitCalendar(_currentMonth.year, _currentMonth.month, habits);
      }
    });

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
              _attemptInitialLoad();
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
                    _attemptInitialLoad();
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
                    _attemptInitialLoad();
                  },
                ),
              ],
            ),
          ),

          // Calendar content
          Expanded(
            child: habitsAsync.when(
              data: (habits) {
                if (habits.isEmpty) return _buildEmptyState();
                final filtered = _selectedHabitFilters.isEmpty
                    ? habits
                    : habits
                        .where((h) => _selectedHabitFilters.contains(h.id))
                        .toList();
                return Column(
                  children: [
                    _buildHabitFilterChips(habits),
                    Expanded(
                        child: _buildCalendar(
                            filtered.isEmpty ? habits : filtered)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildError(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitFilterChips(List habits) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedHabitFilters.isEmpty,
            onSelected: (_) {
              setState(() => _selectedHabitFilters.clear());
            },
          ),
          const SizedBox(width: 8),
          ...habits.map((h) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: CircleAvatar(
                    backgroundColor: Color(int.parse(h.color)),
                    child: Text(h.icon, style: const TextStyle(fontSize: 14)),
                  ),
                  label: Text(h.name),
                  selected: _selectedHabitFilters.contains(h.id),
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _selectedHabitFilters.add(h.id);
                      } else {
                        _selectedHabitFilters.remove(h.id);
                      }
                    });
                  },
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 72, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Error loading habits',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(habitsProvider.notifier).loadHabits(),
              child: const Text('Retry'),
            )
          ],
        ),
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
          Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25);

      if (!calendarState.isLoading && calendarState.error == null) {
        final entry = ref
            .read(habitCalendarProvider.notifier)
            .getHabitEntry(habit.id, day);
        if (entry != null) {
          switch (entry.status) {
            case HabitStatus.completed:
              color = Colors.green;
              break;
            case HabitStatus.missed:
              color = Colors.red.withOpacity(0.7);
              break;
            case HabitStatus.pending:
              color = Theme.of(context).colorScheme.tertiary;
              break;
          }
        } else if (_isPastDate(
            DateTime(_currentMonth.year, _currentMonth.month, day))) {
          // Past days with no entry: keep subtle neutral (no aggressive red at load)
          color =
              Theme.of(context).colorScheme.outlineVariant.withOpacity(0.15);
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
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final calendarState = ref.watch(habitCalendarProvider);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_monthName(date.month)} ${date.day}, ${date.year}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...habits.map((habit) {
                final entry = calendarState.habitEntries[habit.id]?[date.day];
                final status = entry?.status;
                final completed = status == HabitStatus.completed;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(int.parse(habit.color)),
                      child: Text(habit.icon,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(habit.name),
                    subtitle: status != null
                        ? Text(status.name)
                        : const Text('Not tracked'),
                    trailing: IconButton(
                      icon: Icon(
                        completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: completed
                            ? Colors.green
                            : Theme.of(context).colorScheme.outline,
                      ),
                      onPressed: () async {
                        await ref
                            .read(habitCalendarProvider.notifier)
                            .toggleHabitForDate(habit.id, date);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
