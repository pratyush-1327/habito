import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/usecases/habit_usecases.dart';

part 'habits_event.dart';
part 'habits_state.dart';

class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  final CreateHabitUseCase createHabitUseCase;
  final GetAllHabitsUseCase getAllHabitsUseCase;
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final WatchHabitsUseCase watchHabitsUseCase;

  StreamSubscription? _habitsSubscription;

  HabitsBloc({
    required this.createHabitUseCase,
    required this.getAllHabitsUseCase,
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.watchHabitsUseCase,
  }) : super(const HabitsInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<WatchHabits>(_onWatchHabits);
  }

  Future<void> _onLoadHabits(
      LoadHabits event, Emitter<HabitsState> emit) async {
    try {
      emit(const HabitsLoading());
      final habits = await getAllHabitsUseCase();
      emit(HabitsLoaded(habits));
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> _onAddHabit(AddHabit event, Emitter<HabitsState> emit) async {
    try {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        description: event.description,
        color: event.color,
        icon: event.icon,
        createdAt: DateTime.now(),
      );

      await createHabitUseCase(habit);

      // Reload habits
      final habits = await getAllHabitsUseCase();
      emit(HabitsLoaded(habits));
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> _onUpdateHabit(
      UpdateHabit event, Emitter<HabitsState> emit) async {
    try {
      if (state is HabitsLoaded) {
        final currentState = state as HabitsLoaded;
        final habitToUpdate = currentState.habits.firstWhere(
          (habit) => habit.id == event.id,
        );

        final updatedHabit = habitToUpdate.copyWith(
          name: event.name,
          description: event.description,
          color: event.color,
          icon: event.icon,
        );

        await updateHabitUseCase(updatedHabit);

        // Reload habits
        final habits = await getAllHabitsUseCase();
        emit(HabitsLoaded(habits));
      }
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> _onDeleteHabit(
      DeleteHabit event, Emitter<HabitsState> emit) async {
    try {
      await deleteHabitUseCase(event.id);

      // Reload habits
      final habits = await getAllHabitsUseCase();
      emit(HabitsLoaded(habits));
    } catch (e) {
      emit(HabitsError(e.toString()));
    }
  }

  Future<void> _onWatchHabits(
      WatchHabits event, Emitter<HabitsState> emit) async {
    await _habitsSubscription?.cancel();

    _habitsSubscription = watchHabitsUseCase().listen(
      (habits) => emit(HabitsLoaded(habits)),
      onError: (error) => emit(HabitsError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _habitsSubscription?.cancel();
    return super.close();
  }
}
