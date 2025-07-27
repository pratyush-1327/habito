import 'package:hive/hive.dart';

part 'habit_entry.g.dart';

@HiveType(typeId: 1)
class HabitEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final HabitStatus status;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    HabitStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitEntry &&
        other.id == id &&
        other.habitId == habitId &&
        other.date.day == date.day &&
        other.date.month == date.month &&
        other.date.year == date.year;
  }

  @override
  int get hashCode => Object.hash(id, habitId, date.day, date.month, date.year);

  @override
  String toString() {
    return 'HabitEntry(id: $id, habitId: $habitId, date: $date, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

@HiveType(typeId: 2)
enum HabitStatus {
  @HiveField(0)
  completed,

  @HiveField(1)
  missed,

  @HiveField(2)
  pending,
}
