import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'models.dart';
import 'util.dart';

class AppStore extends ChangeNotifier {
  static const _key = 'gym_data_v1';

  bool loaded = false;
  String? authEmail;
  Profile? profile;
  List<WorkoutSession> sessions = [];
  List<WeightEntry> weights = [];
  List<CustomExercise> customExercises = [];
  List<TrainingPlan> customPlans = [];
  String? activePlanId;
  int planCursor = 0;

  // ---------- derived ----------

  List<WorkoutSession> get sessionsNewestFirst =>
      ([...sessions]..sort((a, b) => b.date.compareTo(a.date)));

  List<TrainingPlan> get allPlans => [...builtInPlans, ...customPlans];

  TrainingPlan? planById(String? id) {
    if (id == null) return null;
    for (final p in allPlans) {
      if (p.id == id) return p;
    }
    return null;
  }

  TrainingPlan? get activePlan => planById(activePlanId);

  /// Index of the plan day that is up next.
  int get nextDayIndex {
    final p = activePlan;
    if (p == null || p.days.isEmpty) return 0;
    return planCursor % p.days.length;
  }

  Set<String> get customNames => {for (final c in customExercises) c.name};

  List<String> get allExerciseNames =>
      {...exerciseLibrary.keys, ...customNames}.toList()..sort();

  String muscleOf(String name) {
    for (final c in customExercises) {
      if (c.name == name) return c.muscle;
    }
    return exerciseLibrary[name] ?? 'Other';
  }

  bool isCompound(String name) {
    for (final c in customExercises) {
      if (c.name == name) return c.compound;
    }
    return compoundLifts.contains(name);
  }

  /// Default rep range: heavy compounds 6-10, everything else 10-15.
  (int, int) repRange(String name) => isCompound(name) ? (6, 10) : (10, 15);

  // ---------- load / save ----------

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        profile = m['profile'] == null
            ? null
            : Profile.fromJson(m['profile'] as Map<String, dynamic>);
        sessions = ((m['sessions'] as List?) ?? [])
            .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
            .toList();
        weights = ((m['weights'] as List?) ?? [])
            .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        customExercises = [];
        for (final e in (m['customExercises'] as List?) ?? []) {
          if (e is String) {
            customExercises.add(CustomExercise(e, 'Other'));
          } else if (e is Map<String, dynamic>) {
            customExercises.add(CustomExercise.fromJson(e));
          }
        }
        customPlans = ((m['customPlans'] as List?) ?? [])
            .map((e) => TrainingPlan.fromJson(e as Map<String, dynamic>))
            .toList();
        activePlanId = m['activePlanId'] as String?;
        planCursor = (m['planCursor'] as num?)?.toInt() ?? 0;
      }
      authEmail = prefs.getString('gym_auth_email');
    } catch (_) {
      // Corrupt or missing data: start fresh.
    }
    loaded = true;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'profile': profile?.toJson(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'weights': weights.map((w) => w.toJson()).toList(),
        'customExercises': customExercises.map((c) => c.toJson()).toList(),
        'customPlans': customPlans.map((p) => p.toJson()).toList(),
        'activePlanId': activePlanId,
        'planCursor': planCursor,
      };

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(toJson()));
  }

  void _commit() {
    notifyListeners();
    _save();
  }

  // ---------- account (stored on this device only) ----------

  Future<void> signIn(String email) async {
    authEmail = email.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gym_auth_email', authEmail!);
  }

  Future<void> signOut() async {
    authEmail = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gym_auth_email');
  }

  // ---------- profile ----------

  void setProfile(Profile p) {
    profile = p;
    weights = [WeightEntry(date: DateTime.now(), kg: p.weightKg)];
    _commit();
  }

  void updateProfile(Profile p) {
    final oldWeight = profile?.weightKg;
    profile = p;
    if (oldWeight != null && oldWeight != p.weightKg) {
      final now = DateTime.now();
      weights.removeWhere((w) => sameDay(w.date, now));
      weights.add(WeightEntry(date: now, kg: p.weightKg));
    }
    _commit();
  }

  void setDaysPerWeek(int d) {
    profile?.daysPerWeek = d;
    _commit();
  }

  void addWeight(double kg) {
    final now = DateTime.now();
    weights.removeWhere((w) => sameDay(w.date, now));
    weights.add(WeightEntry(date: now, kg: kg));
    profile?.weightKg = kg;
    _commit();
  }

  // ---------- exercises ----------

  /// Adds a custom exercise and returns the name to use. If an exercise with
  /// the same name already exists, nothing is added and its name is returned.
  String addCustomExercise(CustomExercise c) {
    final clean = c.name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return c.name;
    for (final n in allExerciseNames) {
      if (n.toLowerCase() == clean.toLowerCase()) return n;
    }
    customExercises.add(CustomExercise(clean, c.muscle, compound: c.compound));
    _commit();
    return clean;
  }

  // ---------- plans ----------

  void setActivePlan(String id) {
    activePlanId = id;
    planCursor = 0;
    _commit();
  }

  void clearActivePlan() {
    activePlanId = null;
    planCursor = 0;
    _commit();
  }

  void saveCustomPlan(TrainingPlan p) {
    final i = customPlans.indexWhere((x) => x.id == p.id);
    if (i >= 0) {
      customPlans[i] = p;
    } else {
      customPlans.add(p);
    }
    _commit();
  }

  void deleteCustomPlan(String id) {
    customPlans.removeWhere((p) => p.id == id);
    if (activePlanId == id) {
      activePlanId = null;
      planCursor = 0;
    }
    _commit();
  }

  // ---------- workouts ----------

  /// Saves a finished workout. If it came from the active plan, the plan
  /// moves on to the day after the one just done.
  void completeWorkout(WorkoutSession s, {String? planId, int? dayIndex}) {
    sessions.add(s);
    final plan = activePlan;
    if (plan != null && planId == plan.id && dayIndex != null && plan.days.isNotEmpty) {
      planCursor = (dayIndex + 1) % plan.days.length;
    }
    _commit();
  }

  void deleteSession(String id) {
    sessions.removeWhere((s) => s.id == id);
    _commit();
  }

  Future<void> resetAll() async {
    profile = null;
    sessions = [];
    weights = [];
    customExercises = [];
    customPlans = [];
    activePlanId = null;
    planCursor = 0;
    authEmail = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove('gym_auth_email');
  }
}

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child})
      : super(notifier: store);

  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
