import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'exercise_picker.dart';

class _DayDraft {
  final TextEditingController name;
  final List<PlanExercise> exercises;
  _DayDraft(String n, [List<PlanExercise>? ex])
      : name = TextEditingController(text: n),
        exercises = ex ?? [];
}

/// Create or edit your own plan. Pops with the plan id when saved.
class PlanEditorScreen extends StatefulWidget {
  final TrainingPlan? existing;
  const PlanEditorScreen({super.key, this.existing});
  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  late final TextEditingController name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final List<_DayDraft> days = widget.existing == null
      ? [_DayDraft('Day 1')]
      : [for (final d in widget.existing!.days) _DayDraft(d.name, [...d.exercises])];

  // Controllers of removed days are disposed together with the screen,
  // not immediately, because their text fields are still mounted this frame.
  final List<TextEditingController> _removed = [];

  @override
  void dispose() {
    name.dispose();
    for (final d in days) {
      d.name.dispose();
    }
    for (final c in _removed) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addExercise(_DayDraft day) async {
    final n = await showExercisePicker(context);
    if (n == null || !mounted) return;
    if (day.exercises.any((e) => e.name == n)) return;
    final r = StoreScope.of(context).repRange(n);
    setState(() => day.exercises.add(PlanExercise(n, 3, r.$1, r.$2)));
  }

  Future<void> _editExercise(_DayDraft day, int i) async {
    final res = await showDialog<PlanExercise>(
      context: context,
      builder: (_) => _ExerciseDialog(day.exercises[i]),
    );
    if (res != null && mounted) setState(() => day.exercises[i] = res);
  }

  void _save() {
    final store = StoreScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = name.text.trim();
    if (title.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Give your plan a name.')));
      return;
    }
    final built = <PlanDay>[];
    for (final d in days) {
      if (d.exercises.isEmpty) continue;
      final n = d.name.text.trim();
      built.add(PlanDay(n.isEmpty ? 'Day ${built.length + 1}' : n, [...d.exercises]));
    }
    if (built.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Add at least one exercise.')));
      return;
    }
    final plan = TrainingPlan(
      id: widget.existing?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: title,
      tagline: '${built.length} day${built.length == 1 ? '' : 's'} · your plan',
      level: 'Custom',
      days: built,
      custom: true,
    );
    store.saveCustomPlan(plan);
    Navigator.pop(context, plan.id);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'New plan' : 'Edit plan')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Plan name',
                  hintText: 'e.g. My upper / lower',
                ),
              ),
              const SectionHeader('Workout days'),
              for (var di = 0; di < days.length; di++) ...[
                _dayCard(store, days[di], di),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => setState(
                    () => days.add(_DayDraft('Day ${days.length + 1}'))),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add day'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kBg,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: SafeArea(
          top: false,
          child: ElevatedButton(onPressed: _save, child: const Text('Save plan')),
        ),
      ),
    );
  }

  Widget _dayCard(AppStore store, _DayDraft day, int di) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: day.name,
                  textCapitalization: TextCapitalization.words,
                  style: Txt.titleBold,
                  decoration: const InputDecoration(
                    hintText: 'Day name, e.g. Chest & Triceps',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (days.length > 1)
                IconButton(
                  tooltip: 'Remove day',
                  onPressed: () => setState(() {
                    _removed.add(days.removeAt(di).name);
                  }),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                ),
            ],
          ),
          for (var i = 0; i < day.exercises.length; i++) ...[
            const Divider(),
            InkWell(
              onTap: () => _editExercise(day, i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: muscleColor(store.muscleOf(day.exercises[i].name)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(day.exercises[i].name, style: Txt.title)),
                    Text('${day.exercises[i].sets} × ${day.exercises[i].repsLabel}',
                        style: Txt.caption.copyWith(color: kMuted, fontSize: 13)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => day.exercises.removeAt(i)),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => _addExercise(day),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add exercise'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDialog extends StatefulWidget {
  final PlanExercise ex;
  const _ExerciseDialog(this.ex);
  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  late int sets = widget.ex.sets;
  late int repMin = widget.ex.repMin;
  late int repMax = widget.ex.repMax;

  Widget _stepper(String label, int value, int min, int max, ValueChanged<int> on) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Txt.title)),
        IconButton(
          onPressed: value > min ? () => on(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        SizedBox(
          width: 30,
          child: Text('$value', textAlign: TextAlign.center, style: Txt.titleBold),
        ),
        IconButton(
          onPressed: value < max ? () => on(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ex.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepper('Sets', sets, 1, 10, (v) => setState(() => sets = v)),
          _stepper('Min reps', repMin, 1, 30, (v) => setState(() {
                repMin = v;
                if (repMax < repMin) repMax = repMin;
              })),
          _stepper('Max reps', repMax, 1, 40, (v) => setState(() {
                repMax = v;
                if (repMin > repMax) repMin = repMax;
              })),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: kMuted),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
              context, widget.ex.copyWith(sets: sets, repMin: repMin, repMax: repMax)),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
