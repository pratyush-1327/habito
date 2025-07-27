import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/habit_list_widget.dart';
import '../add_habit_page.dart';

class HabitsPage extends ConsumerStatefulWidget {
  const HabitsPage({super.key});

  @override
  ConsumerState<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends ConsumerState<HabitsPage> {
  @override
  void initState() {
    super.initState();
    // Habits are automatically loaded when the provider is first accessed
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);

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
      body: habitsAsync.when(
        data: (habits) => HabitListWidget(
          habits: habits,
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
            ref.read(habitsProvider.notifier).deleteHabit(habitId);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
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
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.read(habitsProvider.notifier).loadHabits();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
