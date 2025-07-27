import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository repository;

  CreateHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    await repository.addHabit(habit);
  }
}

class GetAllHabitsUseCase {
  final HabitRepository repository;

  GetAllHabitsUseCase(this.repository);

  Future<List<Habit>> call() async {
    return await repository.getAllHabits();
  }
}

class UpdateHabitUseCase {
  final HabitRepository repository;

  UpdateHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    await repository.updateHabit(habit);
  }
}

class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteHabit(id);
  }
}

class WatchHabitsUseCase {
  final HabitRepository repository;

  WatchHabitsUseCase(this.repository);

  Stream<List<Habit>> call() {
    return repository.watchHabits();
  }
}
