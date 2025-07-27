import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/habit_entry_repository_impl.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/habit_entry_repository.dart';
import '../../domain/usecases/habit_usecases.dart';
import '../../domain/usecases/habit_entry_usecases.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../services/habit_tracking_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HabitEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HabitStatusAdapter());
  }

  // Repositories
  getIt.registerLazySingleton<HabitRepository>(() => HabitRepositoryImpl());
  getIt.registerLazySingleton<HabitEntryRepository>(
      () => HabitEntryRepositoryImpl());

  // Use Cases
  getIt.registerLazySingleton(() => CreateHabitUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAllHabitsUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateHabitUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteHabitUseCase(getIt()));
  getIt.registerLazySingleton(() => WatchHabitsUseCase(getIt()));

  getIt.registerLazySingleton(() => ToggleHabitUseCase(getIt()));
  getIt.registerLazySingleton(() => GetHabitEntriesForMonthUseCase(getIt()));
  getIt.registerLazySingleton(() => GetHabitEntryUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkMissedHabitsUseCase(getIt()));

  // Services
  getIt.registerLazySingleton(() => HabitTrackingService(
        getAllHabitsUseCase: getIt(),
        markMissedHabitsUseCase: getIt(),
      ));
}
