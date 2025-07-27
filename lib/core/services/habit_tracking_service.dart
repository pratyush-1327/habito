import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/habit_usecases.dart';
import '../../domain/usecases/habit_entry_usecases.dart';

class HabitTrackingService {
  final GetAllHabitsUseCase getAllHabitsUseCase;
  final MarkMissedHabitsUseCase markMissedHabitsUseCase;

  Timer? _dailyTimer;

  HabitTrackingService({
    required this.getAllHabitsUseCase,
    required this.markMissedHabitsUseCase,
  });

  void startDailyTracking() {
    // Check every hour if it's a new day
    _dailyTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndMarkMissedHabits();
    });
  }

  void stopDailyTracking() {
    _dailyTimer?.cancel();
    _dailyTimer = null;
  }

  Future<void> _checkAndMarkMissedHabits() async {
    try {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      // Only mark missed habits if it's after midnight
      if (now.hour >= 0 && now.hour < 1) {
        final habits = await getAllHabitsUseCase();
        final habitIds = habits.map((habit) => habit.id).toList();

        if (habitIds.isNotEmpty) {
          await markMissedHabitsUseCase(habitIds, yesterday);
        }
      }
    } catch (e) {
      // Log error but don't crash the app
      // print('Error marking missed habits: $e');
      debugPrint('Error marking missed habits: $e');
    }
  }

  void dispose() {
    stopDailyTracking();
  }
}
