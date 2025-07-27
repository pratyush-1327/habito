import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/habit_usecases.dart';
import '../../core/di/dependency_injection.dart';

// Providers for individual use cases
final createHabitUseCaseProvider = Provider<CreateHabitUseCase>((ref) {
  return getIt<CreateHabitUseCase>();
});

final getAllHabitsUseCaseProvider = Provider<GetAllHabitsUseCase>((ref) {
  return getIt<GetAllHabitsUseCase>();
});

final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>((ref) {
  return getIt<UpdateHabitUseCase>();
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  return getIt<DeleteHabitUseCase>();
});

// Provider for habits list
final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  return HabitsNotifier(
    ref.read(createHabitUseCaseProvider),
    ref.read(getAllHabitsUseCaseProvider),
    ref.read(updateHabitUseCaseProvider),
    ref.read(deleteHabitUseCaseProvider),
  );
});

class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final CreateHabitUseCase _createHabitUseCase;
  final GetAllHabitsUseCase _getAllHabitsUseCase;
  final UpdateHabitUseCase _updateHabitUseCase;
  final DeleteHabitUseCase _deleteHabitUseCase;

  HabitsNotifier(
    this._createHabitUseCase,
    this._getAllHabitsUseCase,
    this._updateHabitUseCase,
    this._deleteHabitUseCase,
  ) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    try {
      state = const AsyncValue.loading();
      final habits = await _getAllHabitsUseCase();
      state = AsyncValue.data(habits);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _createHabitUseCase(habit);
      await loadHabits(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _updateHabitUseCase(habit);
      await loadHabits(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _deleteHabitUseCase(habitId);
      await loadHabits(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
