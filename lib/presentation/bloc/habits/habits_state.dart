part of 'habits_bloc.dart';

abstract class HabitsState {
  const HabitsState();
}

class HabitsInitial extends HabitsState {
  const HabitsInitial();
}

class HabitsLoading extends HabitsState {
  const HabitsLoading();
}

class HabitsLoaded extends HabitsState {
  final List<Habit> habits;

  const HabitsLoaded(this.habits);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitsLoaded &&
        other.habits.length == habits.length &&
        other.habits.every((habit) => habits.contains(habit));
  }

  @override
  int get hashCode => habits.hashCode;
}

class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitsError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
