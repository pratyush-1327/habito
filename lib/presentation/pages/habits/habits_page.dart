import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/habits/habits_bloc.dart';
import '../../widgets/habit_list_widget.dart';
import '../add_habit_page.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  void initState() {
    super.initState();
    context.read<HabitsBloc>().add(const LoadHabits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddHabitPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {
          if (state is HabitsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HabitsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading habits',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<HabitsBloc>().add(const LoadHabits());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HabitsLoaded) {
            return HabitListWidget(
              habits: state.habits,
              onAddHabit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddHabitPage(),
                  ),
                );
              },
              onEditHabit: (habit) {
                // TODO: Implement edit habit
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit habit - Coming soon!')),
                );
              },
              onDeleteHabit: (habitId) {
                context.read<HabitsBloc>().add(DeleteHabit(habitId));
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
