import '../entities/habit_entry.dart';

abstract class HabitEntryRepository {
  Future<List<HabitEntry>> getHabitEntriesForHabit(String habitId);
  Future<List<HabitEntry>> getHabitEntriesForDate(DateTime date);
  Future<List<HabitEntry>> getHabitEntriesForMonth(int year, int month);
  Future<HabitEntry?> getHabitEntry(String habitId, DateTime date);
  Future<void> addHabitEntry(HabitEntry entry);
  Future<void> updateHabitEntry(HabitEntry entry);
  Future<void> deleteHabitEntry(String id);
  Stream<List<HabitEntry>> watchHabitEntries();
}
