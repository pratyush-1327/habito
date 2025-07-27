part of 'habit_calendar_bloc.dart';

abstract class HabitCalendarState {
  const HabitCalendarState();
}

class HabitCalendarInitial extends HabitCalendarState {
  const HabitCalendarInitial();
}

class HabitCalendarLoading extends HabitCalendarState {
  const HabitCalendarLoading();
}

class HabitCalendarLoaded extends HabitCalendarState {
  final int year;
  final int month;
  final Map<String, Map<int, HabitEntry>> habitEntries;
  final List<Habit> habits;

  const HabitCalendarLoaded({
    required this.year,
    required this.month,
    required this.habitEntries,
    required this.habits,
  });

  HabitEntry? getHabitEntry(String habitId, int day) {
    return habitEntries[habitId]?[day];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCalendarLoaded &&
        other.year == year &&
        other.month == month &&
        other.habitEntries.length == habitEntries.length &&
        other.habits.length == habits.length;
  }

  @override
  int get hashCode => Object.hash(year, month, habitEntries, habits);
}

class HabitCalendarError extends HabitCalendarState {
  final String message;

  const HabitCalendarError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCalendarError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
