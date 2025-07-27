import '../entities/habit_entry.dart';
import '../repositories/habit_entry_repository.dart';

class ToggleHabitUseCase {
  final HabitEntryRepository repository;

  ToggleHabitUseCase(this.repository);

  Future<void> call(String habitId, DateTime date) async {
    final existingEntry = await repository.getHabitEntry(habitId, date);

    if (existingEntry != null) {
      // If entry exists, toggle between completed and missed
      final newStatus = existingEntry.status == HabitStatus.completed
          ? HabitStatus.missed
          : HabitStatus.completed;

      final updatedEntry = existingEntry.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await repository.updateHabitEntry(updatedEntry);
    } else {
      // Create new entry as completed
      final newEntry = HabitEntry(
        id: '${habitId}_${date.millisecondsSinceEpoch}',
        habitId: habitId,
        date: date,
        status: HabitStatus.completed,
        createdAt: DateTime.now(),
      );

      await repository.addHabitEntry(newEntry);
    }
  }
}

class GetHabitEntriesForMonthUseCase {
  final HabitEntryRepository repository;

  GetHabitEntriesForMonthUseCase(this.repository);

  Future<List<HabitEntry>> call(int year, int month) async {
    return await repository.getHabitEntriesForMonth(year, month);
  }
}

class GetHabitEntryUseCase {
  final HabitEntryRepository repository;

  GetHabitEntryUseCase(this.repository);

  Future<HabitEntry?> call(String habitId, DateTime date) async {
    return await repository.getHabitEntry(habitId, date);
  }
}

class MarkMissedHabitsUseCase {
  final HabitEntryRepository repository;

  MarkMissedHabitsUseCase(this.repository);

  Future<void> call(List<String> habitIds, DateTime date) async {
    for (final habitId in habitIds) {
      final existingEntry = await repository.getHabitEntry(habitId, date);

      if (existingEntry == null) {
        // Only mark as missed if no entry exists
        final missedEntry = HabitEntry(
          id: '${habitId}_${date.millisecondsSinceEpoch}',
          habitId: habitId,
          date: date,
          status: HabitStatus.missed,
          createdAt: DateTime.now(),
        );

        await repository.addHabitEntry(missedEntry);
      }
    }
  }
}
