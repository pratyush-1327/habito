part of 'habit_calendar_bloc.dart';

abstract class HabitCalendarEvent {
  const HabitCalendarEvent();
}

class LoadHabitCalendar extends HabitCalendarEvent {
  final int year;
  final int month;
  final List<Habit> habits;

  const LoadHabitCalendar({
    required this.year,
    required this.month,
    required this.habits,
  });
}

class ToggleHabitForDate extends HabitCalendarEvent {
  final String habitId;
  final DateTime date;

  const ToggleHabitForDate({
    required this.habitId,
    required this.date,
  });
}

class MarkMissedHabits extends HabitCalendarEvent {
  final List<String> habitIds;
  final DateTime date;

  const MarkMissedHabits({
    required this.habitIds,
    required this.date,
  });
}
