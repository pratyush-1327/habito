import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_entry.dart';
import '../../../domain/usecases/habit_entry_usecases.dart';

part 'habit_calendar_event.dart';
part 'habit_calendar_state.dart';

class HabitCalendarBloc extends Bloc<HabitCalendarEvent, HabitCalendarState> {
  final ToggleHabitUseCase toggleHabitUseCase;
  final GetHabitEntriesForMonthUseCase getHabitEntriesForMonthUseCase;
  final GetHabitEntryUseCase getHabitEntryUseCase;
  final MarkMissedHabitsUseCase markMissedHabitsUseCase;

  HabitCalendarBloc({
    required this.toggleHabitUseCase,
    required this.getHabitEntriesForMonthUseCase,
    required this.getHabitEntryUseCase,
    required this.markMissedHabitsUseCase,
  }) : super(const HabitCalendarInitial()) {
    on<LoadHabitCalendar>(_onLoadHabitCalendar);
    on<ToggleHabitForDate>(_onToggleHabitForDate);
    on<MarkMissedHabits>(_onMarkMissedHabits);
  }

  Future<void> _onLoadHabitCalendar(
    LoadHabitCalendar event,
    Emitter<HabitCalendarState> emit,
  ) async {
    try {
      emit(const HabitCalendarLoading());

      final entries =
          await getHabitEntriesForMonthUseCase(event.year, event.month);

      // Group entries by habit ID and day
      final Map<String, Map<int, HabitEntry>> habitEntries = {};

      for (final habit in event.habits) {
        habitEntries[habit.id] = {};
      }

      for (final entry in entries) {
        if (habitEntries[entry.habitId] != null) {
          habitEntries[entry.habitId]![entry.date.day] = entry;
        }
      }

      emit(HabitCalendarLoaded(
        year: event.year,
        month: event.month,
        habitEntries: habitEntries,
        habits: event.habits,
      ));
    } catch (e) {
      emit(HabitCalendarError(e.toString()));
    }
  }

  Future<void> _onToggleHabitForDate(
    ToggleHabitForDate event,
    Emitter<HabitCalendarState> emit,
  ) async {
    try {
      await toggleHabitUseCase(event.habitId, event.date);

      // Reload calendar if current state is loaded
      if (state is HabitCalendarLoaded) {
        final currentState = state as HabitCalendarLoaded;
        add(LoadHabitCalendar(
          year: currentState.year,
          month: currentState.month,
          habits: currentState.habits,
        ));
      }
    } catch (e) {
      emit(HabitCalendarError(e.toString()));
    }
  }

  Future<void> _onMarkMissedHabits(
    MarkMissedHabits event,
    Emitter<HabitCalendarState> emit,
  ) async {
    try {
      await markMissedHabitsUseCase(event.habitIds, event.date);

      // Reload calendar if current state is loaded
      if (state is HabitCalendarLoaded) {
        final currentState = state as HabitCalendarLoaded;
        add(LoadHabitCalendar(
          year: currentState.year,
          month: currentState.month,
          habits: currentState.habits,
        ));
      }
    } catch (e) {
      emit(HabitCalendarError(e.toString()));
    }
  }
}
