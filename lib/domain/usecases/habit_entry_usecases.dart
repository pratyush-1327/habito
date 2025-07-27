import '../entities/habit_entry.dart';
import '../repositories/habit_entry_repository.dart';

class ToggleHabitUseCase {
  final HabitEntryRepository repository;

  ToggleHabitUseCase(this.repository);

  Future<void> call(String habitId, DateTime date) async {
    print('🔄 ToggleHabitUseCase: Starting for habitId: $habitId, date: $date');

    final existingEntry = await repository.getHabitEntry(habitId, date);
    print(
        '📊 ToggleHabitUseCase: Existing entry status: ${existingEntry?.status}');

    if (existingEntry != null) {
      // If entry exists, toggle between completed and missed
      final newStatus = existingEntry.status == HabitStatus.completed
          ? HabitStatus.missed
          : HabitStatus.completed;

      print(
          '🔄 ToggleHabitUseCase: Changing status from ${existingEntry.status} to $newStatus');

      final updatedEntry = existingEntry.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      print(
          '💾 ToggleHabitUseCase: Saving updated entry with status: ${updatedEntry.status}');
      await repository.updateHabitEntry(updatedEntry);

      // Verify the entry was saved
      final verifyEntry = await repository.getHabitEntry(habitId, date);
      print(
          '✅ ToggleHabitUseCase: Verification - saved entry status: ${verifyEntry?.status}');
    } else {
      // Create new entry as completed
      print('➕ ToggleHabitUseCase: Creating new entry as completed');

      final newEntry = HabitEntry(
        id: '${habitId}_${date.millisecondsSinceEpoch}',
        habitId: habitId,
        date: date,
        status: HabitStatus.completed,
        createdAt: DateTime.now(),
      );

      print(
          '💾 ToggleHabitUseCase: Saving new entry with status: ${newEntry.status}');
      await repository.addHabitEntry(newEntry);

      // Verify the entry was saved
      final verifyEntry = await repository.getHabitEntry(habitId, date);
      print(
          '✅ ToggleHabitUseCase: Verification - new entry status: ${verifyEntry?.status}');
    }
  }
}

class GetHabitEntriesForMonthUseCase {
  final HabitEntryRepository repository;

  GetHabitEntriesForMonthUseCase(this.repository);

  Future<List<HabitEntry>> call(int year, int month) async {
    print('📅 GetHabitEntriesForMonth: Fetching entries for $year/$month');
    final entries = await repository.getHabitEntriesForMonth(year, month);
    print('📊 GetHabitEntriesForMonth: Found ${entries.length} entries');
    for (final entry in entries) {
      print(
          '  📝 Entry: ${entry.habitId} on ${entry.date.day}/${entry.date.month} - ${entry.status}');
    }
    return entries;
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
