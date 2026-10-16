import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../store.dart';
import '../suggest.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';
import 'exercise_picker.dart';

/// Opens the workout logger. [items] pre-fills exercises (from a plan day).
void openWorkout(
  BuildContext context, {
  required String title,
  List<PlanExercise> items = const [],
  String? planId,
  int? dayIndex,
  String? planName,
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => WorkoutScreen(
      title: title,
      items: items,
      planId: planId,
      dayIndex: dayIndex,
      planName: planName,
    ),
  ));
}

class _ExState {
  final LoggedExercise log;
  final Progression? prog;
  final LoggedExercise? prev;
  final int repMin;
  final int repMax;
  int applied;
  int targetReps;
  int? effort;
  _ExState({
    required this.log,
    required this.prog,
    required this.prev,
    required this.repMin,
    required this.repMax,
    required this.applied,
    required this.targetReps,
  });
}

const _effortLabels = ['Easy', 'Good', 'Hard', 'Max'];
const _effortRir = [3, 2, 1, 0];

class WorkoutScreen extends StatefulWidget {
  final String title;
  final List<PlanExercise> items;
  final String? planId;
  final int? dayIndex;
  final String? planName;
  const WorkoutScreen({
    super.key,
    required this.title,
    this.items = const [],
    this.planId,
    this.dayIndex,
    this.planName,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final DateTime _start = DateTime.now();
  final List<_ExState> exercises = [];
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final store = StoreScope.of(context);
    final history = store.sessionsNewestFirst;
    for (final it in widget.items) {
      _add(store, history, it.name,
          sets: it.sets, repMin: it.repMin, repMax: it.repMax);
    }
  }

  void _add(AppStore store, List<WorkoutSession> history, String name,
      {int? sets, int? repMin, int? repMax}) {
    if (exercises.any((e) => e.log.name == name)) return;
    final range = store.repRange(name);
    final lo = repMin ?? range.$1;
    final hi = repMax ?? range.$2;
    final prev = lastLogged(name, history);
    final prog = progressionFor(name, history,
        repMin: lo, repMax: hi, compound: store.isCompound(name));
    final count =
        sets ?? (prev != null ? math.max(1, math.min(6, prev.sets.length)) : 3);
    final weight = prog?.primary.weight ?? 0.0;
    exercises.add(_ExState(
      log: LoggedExercise(
        name: name,
        muscle: store.muscleOf(name),
        sets: List.generate(count, (_) => SetEntry(weight: weight)),
      ),
      prog: prog,
      prev: prev,
      repMin: lo,
      repMax: hi,
      applied: prog?.recommended ?? -1,
      targetReps: prog?.primary.reps ?? 0,
    ));
  }

  bool get _hasData =>
      exercises.any((e) => e.log.sets.any((s) => s.reps > 0));

  Future<void> _addExercise() async {
    final name = await showExercisePicker(context);
    if (name == null || !mounted) return;
    final store = StoreScope.of(context);
    setState(() => _add(store, store.sessionsNewestFirst, name));
  }

  void _apply(_ExState ex, int i) {
    final o = ex.prog!.options[i];
    setState(() {
      ex.applied = i;
      ex.targetReps = o.reps;
      final replaced = [
        for (final s in ex.log.sets)
          SetEntry(weight: o.weight, reps: s.reps, rpe: s.rpe, rir: s.rir)
      ];
      ex.log.sets
        ..clear()
        ..addAll(replaced);
    });
  }

  Future<void> _requestExit() async {
    if (!_hasData) {
      Navigator.pop(context);
      return;
    }
    final ok = await confirm(
      context,
      'Discard workout?',
      'Your logged sets will be lost.',
      confirmLabel: 'Discard',
      danger: true,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  void _finish() {
    final store = StoreScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final history = store.sessionsNewestFirst;

    final cleaned = <LoggedExercise>[];
    var prs = 0;
    for (final ex in exercises) {
      final sets = ex.log.sets.where((s) => s.reps > 0).toList();
      if (sets.isEmpty) continue;
      if (ex.effort != null) {
        for (final s in sets) {
          s.rir = _effortRir[ex.effort!];
        }
      }
      final entry =
          LoggedExercise(name: ex.log.name, muscle: ex.log.muscle, sets: sets);
      var prevBest = 0.0;
      for (final h in history) {
        for (final e in h.exercises) {
          if (e.name == entry.name && e.best > prevBest) prevBest = e.best;
        }
      }
      if (prevBest > 0 && entry.best > prevBest) prs++;
      cleaned.add(entry);
    }

    if (cleaned.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Log at least one set with reps.')));
      return;
    }

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      title: widget.title,
      planName: widget.planName,
      durationSec: DateTime.now().difference(_start).inSeconds,
      exercises: cleaned,
    );
    store.completeWorkout(session, planId: widget.planId, dayIndex: widget.dayIndex);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
      content: Text(prs > 0
          ? 'Workout saved · $prs new PR${prs > 1 ? 's' : ''}'
          : 'Workout saved'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _requestExit,
            icon: const Icon(Icons.close_rounded),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: Txt.titleBold),
              _ElapsedTimer(start: _start),
            ],
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: exercises.isEmpty
                ? EmptyState(
                    icon: Icons.fitness_center_rounded,
                    title: 'Empty workout',
                    message: 'Add your first exercise to start logging.',
                    action: ElevatedButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add exercise'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      for (var i = 0; i < exercises.length; i++) ...[
                        _exerciseCard(exercises[i]),
                        const SizedBox(height: 14),
                      ],
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Exercise'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _finish,
                    child: const Text('Finish workout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exerciseCard(_ExState ex) {
    final prog = ex.prog;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex.log.name, style: Txt.titleBold),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Tag(ex.log.muscle, color: muscleColor(ex.log.muscle)),
                        const SizedBox(width: 8),
                        Text('${ex.repMin}–${ex.repMax} reps', style: Txt.caption),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove exercise',
                onPressed: () => setState(() => exercises.remove(ex)),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (prog != null) _targetBox(ex, prog) else _firstTimeNote(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const SizedBox(width: 26, child: Text('SET', style: Txt.label)),
                    const SizedBox(width: 74, child: Text('PREVIOUS', style: Txt.label)),
                    const Expanded(
                        child: Center(child: Text('KG', style: Txt.label))),
                    const SizedBox(width: 8),
                    const Expanded(
                        child: Center(child: Text('REPS', style: Txt.label))),
                    const SizedBox(width: 36),
                  ],
                ),
                for (var i = 0; i < ex.log.sets.length; i++) _setRow(ex, i),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => setState(() => ex.log.sets.add(SetEntry(
                      weight: ex.log.sets.isNotEmpty ? ex.log.sets.last.weight : 0))),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add set'),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('EFFORT', style: Txt.label),
                    const SizedBox(width: 12),
                    for (var i = 0; i < _effortLabels.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _EffortChip(
                          _effortLabels[i],
                          selected: ex.effort == i,
                          onTap: () =>
                              setState(() => ex.effort = ex.effort == i ? null : i),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _firstTimeNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: kMuted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'First time logging this. Next session you will get a weight and rep target here.',
              style: Txt.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _targetBox(_ExState ex, Progression prog) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, size: 16, color: kAccent),
              const SizedBox(width: 6),
              const Text('TARGET FOR TODAY', style: Txt.label),
            ],
          ),
          const SizedBox(height: 4),
          Text('Last time: ${prog.last}', style: Txt.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < prog.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _optionTile(ex, prog, i)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(prog.reason, style: Txt.caption),
        ],
      ),
    );
  }

  Widget _optionTile(_ExState ex, Progression prog, int i) {
    final o = prog.options[i];
    final on = ex.applied == i;
    return GestureDetector(
      onTap: () => _apply(ex, i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: on ? kAccent.withValues(alpha: 0.12) : kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: on ? kAccent : kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i == prog.recommended ? '${o.label} · best' : o.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Txt.caption.copyWith(fontSize: 11, color: on ? kAccent : kMuted),
            ),
            const SizedBox(height: 2),
            Text(o.text,
                style: Txt.titleBold.copyWith(fontSize: 14, color: on ? kAccent : kText)),
          ],
        ),
      ),
    );
  }

  Widget _setRow(_ExState ex, int i) {
    final s = ex.log.sets[i];
    final p = (ex.prev != null && i < ex.prev!.sets.length) ? ex.prev!.sets[i] : null;
    final prevText = (p == null || p.reps == 0)
        ? '—'
        : (p.weight == 0 ? '${p.reps} reps' : '${fmtNum(p.weight)} × ${p.reps}');
    final repHint =
        ex.prog != null ? '${ex.targetReps}' : '${ex.repMin}-${ex.repMax}';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text('${i + 1}', style: Txt.caption)),
          SizedBox(
            width: 74,
            child: Text(prevText,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: Txt.caption),
          ),
          Expanded(
            child: _numField(
              key: ValueKey('w${s.uid}'),
              initial: s.weight == 0 ? '' : fmtNum(s.weight),
              hint: '0',
              decimal: true,
              onChanged: (v) => s.weight = double.tryParse(v.replaceAll(',', '.')) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(
              key: ValueKey('r${s.uid}'),
              initial: s.reps == 0 ? '' : '${s.reps}',
              hint: repHint,
              decimal: false,
              onChanged: (v) => s.reps = int.tryParse(v) ?? 0,
            ),
          ),
          SizedBox(
            width: 36,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              iconSize: 18,
              onPressed: ex.log.sets.length > 1
                  ? () => setState(() => ex.log.sets.removeAt(i))
                  : null,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField({
    required Key key,
    required String initial,
    required String hint,
    required bool decimal,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      key: key,
      initialValue: initial,
      textAlign: TextAlign.center,
      style: Txt.titleBold,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]')),
      ],
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
      ),
      onChanged: onChanged,
    );
  }
}

class _EffortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _EffortChip(this.label, {required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? kAccent.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? kAccent : kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFont,
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected ? kAccent : kMuted,
          ),
        ),
      ),
    );
  }
}

class _ElapsedTimer extends StatefulWidget {
  final DateTime start;
  const _ElapsedTimer({required this.start});
  @override
  State<_ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<_ElapsedTimer> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      fmtClock(DateTime.now().difference(widget.start)),
      style: Txt.caption.copyWith(color: kAccent, fontSize: 12),
    );
  }
}
