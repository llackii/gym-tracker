import 'dart:math' as math;
import 'models.dart';
import 'util.dart';

/// One concrete target for the next session, e.g. "100 kg × 5".
class TargetOption {
  final String label;
  final double weight;
  final int reps;
  const TargetOption(this.label, this.weight, this.reps);

  String get text => weight == 0 ? '$reps reps' : '${fmtNum(weight)} kg × $reps';
}

class Progression {
  final String last;
  final String reason;
  final List<TargetOption> options;
  final int recommended;
  const Progression({
    required this.last,
    required this.reason,
    required this.options,
    this.recommended = 0,
  });

  TargetOption get primary => options[recommended];
}

double _increment(double weight, bool compound) {
  if (weight < 10) return 1;
  if (compound && weight >= 60) return 5;
  return 2.5;
}

/// The most recent time [name] was logged.
LoggedExercise? lastLogged(String name, List<WorkoutSession> newestFirst) {
  for (final s in newestFirst) {
    for (final e in s.exercises) {
      if (e.name == name && e.sets.any((x) => x.reps > 0)) return e;
    }
  }
  return null;
}

/// Double progression: first add reps inside the rep range, then add weight
/// once every set reaches the top of the range.
///
/// Example (range 6-10): 100 kg x 4 -> 100 kg x 5 (below range: build reps first).
/// 100 kg x 8 -> 100 kg x 9, or 105 kg x 8 if it felt easy.
/// 100 kg x 10 on every set -> 105 kg x 8.
Progression? progressionFor(
  String exercise,
  List<WorkoutSession> newestFirst, {
  required int repMin,
  required int repMax,
  required bool compound,
}) {
  final e = lastLogged(exercise, newestFirst);
  if (e == null) return null;

  final sets = e.sets.where((x) => x.reps > 0).toList();
  final last = sets
      .map((x) => x.weight == 0 ? '${x.reps}' : '${fmtNum(x.weight)}×${x.reps}')
      .join('  ·  ');

  final top = e.best;
  final atTop = sets.where((x) => x.weight == top).toList();
  final minReps = atTop.map((x) => x.reps).reduce(math.min);
  final hard = atTop.any((x) => x.rir == 0 || (x.rpe != null && x.rpe! >= 10));

  // Bodyweight: only reps can progress.
  if (top == 0) {
    return Progression(
      last: last,
      reason: minReps >= repMax
          ? 'You reached the top of the range. Add weight (belt or vest) or slow the tempo.'
          : 'Beat last time by one rep on each set.',
      options: [TargetOption('More reps', 0, minReps + 1)],
    );
  }

  final inc = _increment(top, compound);
  final midReps = repMin + (repMax - repMin) ~/ 2;

  if (minReps >= repMax) {
    final up = TargetOption('More weight', top + inc, midReps);
    final same = TargetOption('Same again', top, repMax);
    if (hard) {
      return Progression(
        last: last,
        reason:
            'You hit $repMax reps but it was max effort. Repeat once with cleaner reps, then add weight.',
        options: [same, up],
      );
    }
    return Progression(
      last: last,
      reason:
          'Every set reached $repMax reps. Add ${fmtNum(inc)} kg and work back up from $midReps.',
      options: [up, same],
    );
  }

  final moreReps = TargetOption('More reps', top, minReps + 1);

  if (minReps < repMin) {
    return Progression(
      last: last,
      reason:
          '${fmtNum(top)} kg is heavy for $repMin–$repMax reps. Build reps at this weight before adding load.',
      options: [moreReps],
    );
  }

  if (hard) {
    return Progression(
      last: last,
      reason: 'Last time was max effort. Add a rep only if your form stays clean.',
      options: [moreReps],
    );
  }

  return Progression(
    last: last,
    reason: 'Add one rep on each set. If it felt easy, add weight instead.',
    options: [moreReps, TargetOption('More weight', top + inc, minReps)],
  );
}

/// Muscle groups trained least in the last [days] days.
List<String> neglectedMuscles(List<WorkoutSession> sessions, {int days = 14}) {
  final cutoff = DateTime.now().subtract(Duration(days: days));
  final counts = <String, int>{
    'Chest': 0, 'Back': 0, 'Legs': 0, 'Shoulders': 0, 'Arms': 0, 'Core': 0,
  };
  for (final s in sessions.where((s) => s.date.isAfter(cutoff))) {
    for (final e in s.exercises) {
      if (counts.containsKey(e.muscle)) {
        counts[e.muscle] = counts[e.muscle]! + e.sets.length;
      }
    }
  }
  final list = counts.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  return list.where((e) => e.value == 0).map((e) => e.key).toList();
}

DateTime _prevWeek(DateTime d) => DateTime(d.year, d.month, d.day - 7);

/// Consecutive weeks (ending this week or last week) with at least one workout.
int weekStreak(List<WorkoutSession> sessions) {
  if (sessions.isEmpty) return 0;
  final weeks = <DateTime>{for (final s in sessions) startOfWeek(s.date)};
  var cursor = startOfWeek(DateTime.now());
  if (!weeks.contains(cursor)) cursor = _prevWeek(cursor);
  var n = 0;
  while (weeks.contains(cursor)) {
    n++;
    cursor = _prevWeek(cursor);
  }
  return n;
}
