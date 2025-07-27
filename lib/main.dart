import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/dependency_injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/bloc/habits/habits_bloc.dart';
import 'presentation/bloc/habit_calendar/habit_calendar_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupDependencies();

  runApp(const HabitoApp());
}

class HabitoApp extends StatelessWidget {
  const HabitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HabitsBloc>(
          create: (context) => getIt<HabitsBloc>(),
        ),
        BlocProvider<HabitCalendarBloc>(
          create: (context) => getIt<HabitCalendarBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Habito',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
