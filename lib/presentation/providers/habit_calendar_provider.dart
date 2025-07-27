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
    try {
      print(
          '📅 LoadCalendar: Starting for $year/$month with ${habits.length} habits');
      state = state.copyWith(isLoading: true, error: null);

      final entries = await _getHabitEntriesForMonthUseCase(year, month);
      print(
          '📊 LoadCalendar: Retrieved ${entries.length} entries from database');

      // Group entries by habit ID and day (matching BLoC structure)
      final Map<String, Map<int, HabitEntry>> habitEntries = {};

      for (final habit in habits) {
        habitEntries[habit.id] = {};
        print(
            '🏗️ LoadCalendar: Initialized habit ${habit.id} (${habit.name})');
      }

      for (final entry in entries) {
        print(
            '🔗 LoadCalendar: Processing entry - habitId: ${entry.habitId}, day: ${entry.date.day}, status: ${entry.status}');
        if (habitEntries[entry.habitId] != null) {
          habitEntries[entry.habitId]![entry.date.day] = entry;
          print('✅ LoadCalendar: Added entry to state');
        } else {
          print(
              '❌ LoadCalendar: Habit ${entry.habitId} not found in habits list');
        }
      }

      print('📊 LoadCalendar: Final habitEntries structure:');
      habitEntries.forEach((habitId, dayEntries) {
        print('  Habit $habitId: ${dayEntries.length} entries');
        dayEntries.forEach((day, entry) {
          print('    Day $day: ${entry.status}');
        });
      });

      state = HabitCalendarState(
        year: year,
        month: month,
        habitEntries: habitEntries,
        habits: habits,
        isLoading: false,
      );

      print('✅ LoadCalendar: State updated successfully');
    } catch (error) {
      print('❌ LoadCalendar: Error - $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> toggleHabitForDate(String habitId, DateTime date) async {
    try {
      print('🎯 Provider: toggleHabitForDate called for $habitId on $date');

      await _toggleHabitUseCase(habitId, date);

      print('🔄 Provider: Use case completed, reloading calendar...');

      // Get the latest habits from the habits provider instead of using stale state
      // We need to get this from dependency injection since we can't access ref here
      final getAllHabitsUseCase = getIt<GetAllHabitsUseCase>();
      final currentHabits = await getAllHabitsUseCase();

      print('🔄 Provider: Got ${currentHabits.length} habits for reload');

      // Reload calendar with current state and fresh habits
      await loadHabitCalendar(state.year, state.month, currentHabits);

      print('✅ Provider: Calendar reloaded successfully');

      // Verify the entry is in our state
      final entry = getHabitEntry(habitId, date.day);
      print(
          '📊 Provider: Entry in state after reload for habit $habitId on day ${date.day}: ${entry?.status}');

      // Also check if the habit exists in our state
      print('🔍 Provider: Checking if habit $habitId exists in state...');
      print(
          '📋 Provider: Available habits in state: ${state.habits.map((h) => '${h.id}(${h.name})').join(', ')}');
      print(
          '📦 Provider: habitEntries keys: ${state.habitEntries.keys.join(', ')}');
    } catch (error) {
      print('❌ Provider: Error in toggleHabitForDate: $error');
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
