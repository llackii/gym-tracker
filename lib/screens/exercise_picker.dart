import 'package:flutter/material.dart';
import '../data.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Bottom sheet to pick an exercise. Returns the chosen name, or null.
/// Always shows a "Create custom exercise" button at the top.
Future<String?> showExercisePicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _ExercisePicker(),
  );
}

class _ExercisePicker extends StatefulWidget {
  const _ExercisePicker();
  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  String query = '';
  String? muscle;

  Future<void> _create() async {
    final created = await showDialog<CustomExercise>(
      context: context,
      builder: (_) => _CreateExerciseDialog(initialName: query.trim()),
    );
    if (created == null || !mounted) return;
    final name = StoreScope.of(context).addCustomExercise(created);
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final q = query.trim().toLowerCase();
    final custom = store.customNames;
    final names = store.allExerciseNames.where((n) {
      if (muscle != null && store.muscleOf(n) != muscle) return false;
      return q.isEmpty || n.toLowerCase().contains(q);
    }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  const Expanded(child: Text('Add exercise', style: Txt.h2)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  hintText: 'Search exercises',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  OptionChip('All',
                      selected: muscle == null,
                      onTap: () => setState(() => muscle = null)),
                  for (final m in mainMuscles) ...[
                    const SizedBox(width: 8),
                    OptionChip(m,
                        selected: muscle == m,
                        onTap: () => setState(() => muscle = m)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: AppCard(
                onTap: _create,
                borderColor: kAccent.withValues(alpha: 0.5),
                color: kAccent.withValues(alpha: 0.06),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    const IconBadge(Icons.add_rounded, size: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Create custom exercise', style: Txt.titleBold),
                          Text(
                            q.isEmpty
                                ? 'Not in the list? Add your own'
                                : 'Add "${query.trim()}" as a new exercise',
                            style: Txt.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: kAccent),
                  ],
                ),
              ),
            ),
            Expanded(
              child: names.isEmpty
                  ? const Center(
                      child: Text('No matches. Create it above.', style: Txt.caption))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      itemCount: names.length,
                      itemBuilder: (context, i) {
                        final n = names[i];
                        final m = store.muscleOf(n);
                        return ListTile(
                          onTap: () => Navigator.pop(context, n),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          title: Text(n, style: Txt.title),
                          subtitle: Text(m,
                              style: Txt.caption.copyWith(color: muscleColor(m))),
                          trailing: custom.contains(n) ? const Tag('Custom') : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateExerciseDialog extends StatefulWidget {
  final String initialName;
  const _CreateExerciseDialog({required this.initialName});
  @override
  State<_CreateExerciseDialog> createState() => _CreateExerciseDialogState();
}

class _CreateExerciseDialogState extends State<_CreateExerciseDialog> {
  late final TextEditingController name =
      TextEditingController(text: widget.initialName);
  String muscle = 'Chest';
  bool compound = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void _submit() {
    final n = name.text.trim();
    if (n.isEmpty) {
      setState(() => error = 'Enter a name');
      return;
    }
    Navigator.pop(context, CustomExercise(n, muscle, compound: compound));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (error != null) setState(() => error = null);
              },
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Exercise name',
                errorText: error,
              ),
            ),
            const SizedBox(height: 18),
            const Text('MUSCLE GROUP', style: Txt.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in mainMuscles)
                  OptionChip(m,
                      selected: muscle == m,
                      onTap: () => setState(() => muscle = m)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Heavy compound lift', style: Txt.title),
                      Text('Bigger weight jumps, lower reps', style: Txt.caption),
                    ],
                  ),
                ),
                Switch(value: compound, onChanged: (v) => setState(() => compound = v)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: kMuted),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}
