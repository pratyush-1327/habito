import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/habits/habits_bloc.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedColor = '0xFF6750A4';
  String _selectedIcon = '💪';

  final List<String> _colorOptions = [
    '0xFF6750A4', // Purple
    '0xFFD32F2F', // Red
    '0xFF1976D2', // Blue
    '0xFF388E3C', // Green
    '0xFFFF5722', // Deep Orange
    '0xFF7B1FA2', // Purple Dark
    '0xFF0288D1', // Light Blue
    '0xFF00695C', // Teal
    '0xFFF57C00', // Orange
    '0xFF5D4037', // Brown
  ];

  final List<String> _iconOptions = [
    '💪',
    '🏃',
    '📚',
    '💧',
    '🧘',
    '🎯',
    '✍️',
    '🍎',
    '😴',
    '🎵',
    '🚶',
    '🏋️',
    '📱',
    '🔥',
    '⭐',
    '🌟',
    '❤️',
    '🎨',
    '💡',
    '🎮',
    '🍽️',
    '🏠',
    '🌱',
    '📖'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<HabitsBloc, HabitsState>(
        listener: (context, state) {
          if (state is HabitsLoaded) {
            Navigator.of(context).pop();
          } else if (state is HabitsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Habit name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    hintText: 'e.g., Drink 8 glasses of water',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a habit name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add more details about your habit',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                // Icon selection
                Text(
                  'Choose an Icon',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildIconSelector(),

                const SizedBox(height: 24),

                // Color selection
                Text(
                  'Choose a Color',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildColorSelector(),

                const SizedBox(height: 32),

                // Preview
                _buildPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _iconOptions.map((icon) {
        final isSelected = icon == _selectedIcon;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = icon;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _colorOptions.map((colorHex) {
        final color = Color(int.parse(colorHex));
        final isSelected = colorHex == _selectedColor;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = colorHex;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 3,
                    )
                  : Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Color(int.parse(_selectedColor)),
                radius: 24,
                child: Text(
                  _selectedIcon,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(
                _nameController.text.isEmpty
                    ? 'Habit Name'
                    : _nameController.text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: _descriptionController.text.isNotEmpty
                  ? Text(_descriptionController.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      context.read<HabitsBloc>().add(
            AddHabit(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              color: _selectedColor,
              icon: _selectedIcon,
            ),
          );
    }
  }
}
