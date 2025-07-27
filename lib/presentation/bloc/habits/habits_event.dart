part of 'habits_bloc.dart';

abstract class HabitsEvent {
  const HabitsEvent();
}

class LoadHabits extends HabitsEvent {
  const LoadHabits();
}

class AddHabit extends HabitsEvent {
  final String name;
  final String description;
  final String color;
  final String icon;

  const AddHabit({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class UpdateHabit extends HabitsEvent {
  final String id;
  final String? name;
  final String? description;
  final String? color;
  final String? icon;

  const UpdateHabit({
    required this.id,
    this.name,
    this.description,
    this.color,
    this.icon,
  });
}

class DeleteHabit extends HabitsEvent {
  final String id;

  const DeleteHabit(this.id);
}

class WatchHabits extends HabitsEvent {
  const WatchHabits();
}
