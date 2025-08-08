import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/usecases/habit_entry_usecases.dart';
import '../../domain/usecases/habit_usecases.dart';
import '../../core/di/dependency_injection.dart';

// Providers for habit entry use cases
final toggleHabitUseCaseProvider = Provider<ToggleHabitUseCase>((ref) {
  return getIt<ToggleHabitUseCase>();
});

final getHabitEntriesForMonthUseCaseProvider =
    Provider<GetHabitEntriesForMonthUseCase>((ref) {
  return getIt<GetHabitEntriesForMonthUseCase>();
});

final markMissedHabitsUseCaseProvider =
    Provider<MarkMissedHabitsUseCase>((ref) {
  return getIt<MarkMissedHabitsUseCase>();
});

// State class to match the BLoC structure
class HabitCalendarState {
  final int year;
  final int month;
  final Map<String, Map<int, HabitEntry>> habitEntries;
  final List<Habit> habits;
  final bool isLoading;
  final String? error;

  const HabitCalendarState({
    required this.year,
    required this.month,
    required this.habitEntries,
    required this.habits,
    this.isLoading = false,
    this.error,
  });

  HabitCalendarState copyWith({
    int? year,
    int? month,
    Map<String, Map<int, HabitEntry>>? habitEntries,
    List<Habit>? habits,
    bool? isLoading,
    String? error,
  }) {
    return HabitCalendarState(
      year: year ?? this.year,
      month: month ?? this.month,
      habitEntries: habitEntries ?? this.habitEntries,
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider for calendar state
final habitCalendarProvider =
    StateNotifierProvider<HabitCalendarNotifier, HabitCalendarState>((ref) {
  return HabitCalendarNotifier(
    ref.read(toggleHabitUseCaseProvider),
    ref.read(getHabitEntriesForMonthUseCaseProvider),
    ref.read(markMissedHabitsUseCaseProvider),
  );
});

class HabitCalendarNotifier extends StateNotifier<HabitCalendarState> {
  final ToggleHabitUseCase _toggleHabitUseCase;
  final GetHabitEntriesForMonthUseCase _getHabitEntriesForMonthUseCase;
  final MarkMissedHabitsUseCase _markMissedHabitsUseCase;

  HabitCalendarNotifier(
    this._toggleHabitUseCase,
    this._getHabitEntriesForMonthUseCase,
    this._markMissedHabitsUseCase,
  ) : super(HabitCalendarState(
          year: DateTime.now().year,
          month: DateTime.now().month,
          habitEntries: {},
          habits: [],
        ));

  Future<void> loadHabitCalendar(
      int year, int month, List<Habit> habits) async {
    if (habits.isEmpty) {
      // Nothing to load yet – keep waiting for habits list.
      return;
    }
    try {
      state = state.copyWith(isLoading: true, error: null);
      final entries = await _getHabitEntriesForMonthUseCase(year, month);

      final Map<String, Map<int, HabitEntry>> habitEntries = {
        for (final h in habits) h.id: <int, HabitEntry>{}
      };

      for (final entry in entries) {
        final map = habitEntries[entry.habitId];
        if (map != null) {
          map[entry.date.day] = entry;
        }
      }

      state = HabitCalendarState(
        year: year,
        month: month,
        habitEntries: habitEntries,
        habits: habits,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> reloadWithFreshHabits() async {
    final getAll = getIt<GetAllHabitsUseCase>();
    final habits = await getAll();
    await loadHabitCalendar(state.year, state.month, habits);
  }

  Future<void> toggleHabitForDate(String habitId, DateTime date) async {
    try {
      await _toggleHabitUseCase(habitId, date);
      await reloadWithFreshHabits();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> markMissedHabits(List<String> habitIds, DateTime date) async {
    try {
      await _markMissedHabitsUseCase(habitIds, date);

      // Reload calendar with current state
      await loadHabitCalendar(state.year, state.month, state.habits);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  HabitEntry? getHabitEntry(String habitId, int day) {
    return state.habitEntries[habitId]?[day];
  }
}
