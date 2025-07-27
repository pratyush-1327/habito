import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  static const String _boxName = 'habits';

  Box<Habit>? _box;

  Future<Box<Habit>> get _habitBox async {
    return _box ??= await Hive.openBox<Habit>(_boxName);
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final box = await _habitBox;
    return box.values.where((habit) => habit.isActive).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final box = await _habitBox;
    return box.values.firstWhere(
      (habit) => habit.id == id,
      orElse: () => throw StateError('Habit not found'),
    );
  }

  @override
  Future<void> addHabit(Habit habit) async {
    final box = await _habitBox;
    await box.put(habit.id, habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final box = await _habitBox;
    await box.put(habit.id, habit);
  }

  @override
  Future<void> deleteHabit(String id) async {
    final box = await _habitBox;
    final habit = box.get(id);
    if (habit != null) {
      final updatedHabit = habit.copyWith(isActive: false);
      await box.put(id, updatedHabit);
    }
  }

  @override
  Stream<List<Habit>> watchHabits() async* {
    final box = await _habitBox;
    yield* box
        .watch()
        .map((_) => box.values.where((habit) => habit.isActive).toList());
  }
}
