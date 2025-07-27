// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitEntryAdapter extends TypeAdapter<HabitEntry> {
  @override
  final int typeId = 1;

  @override
  HabitEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitEntry(
      id: fields[0] as String,
      habitId: fields[1] as String,
      date: fields[2] as DateTime,
      status: fields[3] as HabitStatus,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitStatusAdapter extends TypeAdapter<HabitStatus> {
  @override
  final int typeId = 2;

  @override
  HabitStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitStatus.completed;
      case 1:
        return HabitStatus.missed;
      case 2:
        return HabitStatus.pending;
      default:
        return HabitStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, HabitStatus obj) {
    switch (obj) {
      case HabitStatus.completed:
        writer.writeByte(0);
        break;
      case HabitStatus.missed:
        writer.writeByte(1);
        break;
      case HabitStatus.pending:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
