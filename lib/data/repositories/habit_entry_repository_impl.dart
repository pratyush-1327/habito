import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/repositories/habit_entry_repository.dart';

class HabitEntryRepositoryImpl implements HabitEntryRepository {
  static const String _boxName = 'habit_entries';

  Box<HabitEntry>? _box;

  Future<Box<HabitEntry>> get _habitEntryBox async {
    return _box ??= await Hive.openBox<HabitEntry>(_boxName);
  }

  @override
  Future<List<HabitEntry>> getHabitEntriesForHabit(String habitId) async {
    final box = await _habitEntryBox;
    return box.values.where((entry) => entry.habitId == habitId).toList();
  }

  @override
  Future<List<HabitEntry>> getHabitEntriesForDate(DateTime date) async {
    final box = await _habitEntryBox;
    return box.values
        .where((entry) =>
            entry.date.day == date.day &&
            entry.date.month == date.month &&
            entry.date.year == date.year)
        .toList();
  }

  @override
  Future<List<HabitEntry>> getHabitEntriesForMonth(int year, int month) async {
    final box = await _habitEntryBox;
    return box.values
        .where((entry) => entry.date.year == year && entry.date.month == month)
        .toList();
  }

  @override
  Future<HabitEntry?> getHabitEntry(String habitId, DateTime date) async {
    final box = await _habitEntryBox;
    try {
      return box.values.firstWhere((entry) =>
          entry.habitId == habitId &&
          entry.date.day == date.day &&
          entry.date.month == date.month &&
          entry.date.year == date.year);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addHabitEntry(HabitEntry entry) async {
    final box = await _habitEntryBox;
    await box.put(entry.id, entry);
  }

  @override
  Future<void> updateHabitEntry(HabitEntry entry) async {
    final box = await _habitEntryBox;
    await box.put(entry.id, entry);
  }

  @override
  Future<void> deleteHabitEntry(String id) async {
    final box = await _habitEntryBox;
    await box.delete(id);
  }

  @override
  Stream<List<HabitEntry>> watchHabitEntries() async* {
    final box = await _habitEntryBox;
    yield* box.watch().map((_) => box.values.toList());
  }
}
