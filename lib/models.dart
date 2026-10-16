class Profile {
  String name;
  double heightCm;
  double weightKg;
  String goal;
  int daysPerWeek;

  Profile({
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.daysPerWeek,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'goal': goal,
        'daysPerWeek': daysPerWeek,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name'] as String,
        heightCm: (j['heightCm'] as num).toDouble(),
        weightKg: (j['weightKg'] as num).toDouble(),
        goal: j['goal'] as String,
        daysPerWeek: (j['daysPerWeek'] as num).toInt(),
      );
}

class SetEntry {
  static int _counter = 0;
  final int uid = _counter++;
  double weight;
  int reps;
  double? rpe;
  int? rir;

  SetEntry({this.weight = 0, this.reps = 0, this.rpe, this.rir});

  Map<String, dynamic> toJson() => {'w': weight, 'r': reps, 'rpe': rpe, 'rir': rir};

  factory SetEntry.fromJson(Map<String, dynamic> j) => SetEntry(
        weight: (j['w'] as num).toDouble(),
        reps: (j['r'] as num).toInt(),
        rpe: (j['rpe'] as num?)?.toDouble(),
        rir: (j['rir'] as num?)?.toInt(),
      );
}

class LoggedExercise {
  final String name;
  final String muscle;
  final List<SetEntry> sets;

  LoggedExercise({required this.name, required this.muscle, required this.sets});

  /// Heaviest weight lifted for at least one rep.
  double get best {
    var m = 0.0;
    for (final s in sets) {
      if (s.reps > 0 && s.weight > m) m = s.weight;
    }
    return m;
  }

  /// Most reps done at the heaviest weight.
  int get bestReps {
    final b = best;
    var r = 0;
    for (final s in sets) {
      if (s.weight == b && s.reps > r) r = s.reps;
    }
    return r;
  }

  /// Estimated one-rep max (Epley formula) from the best set.
  double get est1rm {
    var m = 0.0;
    for (final s in sets) {
      if (s.reps > 0 && s.weight > 0) {
        final v = s.weight * (1 + s.reps / 30);
        if (v > m) m = v;
      }
    }
    return m;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'muscle': muscle,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory LoggedExercise.fromJson(Map<String, dynamic> j) => LoggedExercise(
        name: j['name'] as String,
        muscle: j['muscle'] as String,
        sets: (j['sets'] as List)
            .map((s) => SetEntry.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutSession {
  final String id;
  final DateTime date;
  final String title;
  final String? planName;
  final int? durationSec;
  final List<LoggedExercise> exercises;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.title,
    this.planName,
    this.durationSec,
    required this.exercises,
  });

  int get totalSets => exercises.fold<int>(0, (a, e) => a + e.sets.length);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'plan': planName,
        'dur': durationSec,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> j) => WorkoutSession(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        title: j['title'] as String,
        planName: j['plan'] as String?,
        durationSec: (j['dur'] as num?)?.toInt(),
        exercises: (j['exercises'] as List)
            .map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WeightEntry {
  final DateTime date;
  final double kg;
  WeightEntry({required this.date, required this.kg});

  Map<String, dynamic> toJson() => {'d': date.toIso8601String(), 'kg': kg};

  factory WeightEntry.fromJson(Map<String, dynamic> j) => WeightEntry(
        date: DateTime.parse(j['d'] as String),
        kg: (j['kg'] as num).toDouble(),
      );
}

/// An exercise the user created themselves.
class CustomExercise {
  final String name;
  final String muscle;
  final bool compound;
  const CustomExercise(this.name, this.muscle, {this.compound = false});

  Map<String, dynamic> toJson() => {'n': name, 'm': muscle, 'c': compound};

  factory CustomExercise.fromJson(Map<String, dynamic> j) => CustomExercise(
        j['n'] as String,
        (j['m'] as String?) ?? 'Other',
        compound: (j['c'] as bool?) ?? false,
      );
}

/// One exercise inside a plan day: sets and a rep range.
class PlanExercise {
  final String name;
  final int sets;
  final int repMin;
  final int repMax;
  const PlanExercise(this.name, this.sets, this.repMin, this.repMax);

  String get repsLabel => repMin == repMax ? '$repMin' : '$repMin–$repMax';

  PlanExercise copyWith({int? sets, int? repMin, int? repMax}) => PlanExercise(
        name,
        sets ?? this.sets,
        repMin ?? this.repMin,
        repMax ?? this.repMax,
      );

  Map<String, dynamic> toJson() =>
      {'n': name, 's': sets, 'a': repMin, 'b': repMax};

  factory PlanExercise.fromJson(Map<String, dynamic> j) => PlanExercise(
        j['n'] as String,
        (j['s'] as num).toInt(),
        (j['a'] as num).toInt(),
        (j['b'] as num).toInt(),
      );
}

class PlanDay {
  final String name;
  final List<PlanExercise> exercises;
  PlanDay(this.name, this.exercises);

  Map<String, dynamic> toJson() =>
      {'name': name, 'ex': exercises.map((e) => e.toJson()).toList()};

  factory PlanDay.fromJson(Map<String, dynamic> j) => PlanDay(
        j['name'] as String,
        (j['ex'] as List)
            .map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TrainingPlan {
  final String id;
  final String name;
  final String tagline;
  final String level;
  final String about;
  final List<PlanDay> days;
  final bool custom;
  final String? photo;

  TrainingPlan({
    required this.id,
    required this.name,
    this.tagline = '',
    this.level = '',
    this.about = '',
    required this.days,
    this.custom = false,
    this.photo,
  });

  int get exerciseCount => days.fold<int>(0, (a, d) => a + d.exercises.length);

  /// Initials for the round badge, e.g. "Chris Bumstead" -> "CB".
  String get monogram {
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && RegExp(r'[A-Za-z0-9]').hasMatch(w[0]))
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'level': level,
        'about': about,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory TrainingPlan.fromJson(Map<String, dynamic> j) => TrainingPlan(
        id: j['id'] as String,
        name: j['name'] as String,
        tagline: (j['tagline'] as String?) ?? '',
        level: (j['level'] as String?) ?? 'Custom',
        about: (j['about'] as String?) ?? '',
        days: (j['days'] as List)
            .map((d) => PlanDay.fromJson(d as Map<String, dynamic>))
            .toList(),
        custom: true,
      );
}
