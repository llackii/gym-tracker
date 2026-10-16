import 'models.dart';
import 'photos.dart';

/// Exercise name -> muscle group. Names from earlier versions are kept so
/// old workout history still matches.
const exerciseLibrary = <String, String>{
  // Chest
  'Bench Press': 'Chest',
  'Incline Bench Press': 'Chest',
  'Decline Bench Press': 'Chest',
  'Dumbbell Press': 'Chest',
  'Incline Dumbbell Press': 'Chest',
  'Chest Press Machine': 'Chest',
  'Dumbbell Fly': 'Chest',
  'Chest Fly': 'Chest',
  'Cable Fly': 'Chest',
  'Pec Deck Fly': 'Chest',
  'Pull Over': 'Chest',
  'Push Up': 'Chest',
  'Dips': 'Chest',
  // Back
  'Pull Up': 'Back',
  'Chin Up': 'Back',
  'Lat Pulldown': 'Back',
  'Straight Arm Pulldown': 'Back',
  'Barbell Row': 'Back',
  'T-Bar Row': 'Back',
  'Seated Cable Row': 'Back',
  'Chest Supported Row': 'Back',
  'Dumbbell Row': 'Back',
  'Machine Row': 'Back',
  'Deadlift': 'Back',
  'Rack Pull': 'Back',
  'Back Extension': 'Back',
  'Lower Back': 'Back',
  'Lats Focused': 'Back',
  // Legs
  'Squat': 'Legs',
  'Front Squat': 'Legs',
  'Hack Squat': 'Legs',
  'Leg Press': 'Legs',
  'Romanian Deadlift': 'Legs',
  'Dumbbell RDL': 'Legs',
  'Stiff-Leg Deadlift': 'Legs',
  'Leg Curl': 'Legs',
  'Hamstring curl': 'Legs',
  'Leg Extension': 'Legs',
  'Walking Lunge': 'Legs',
  'Lunges': 'Legs',
  'Bulgarian Split Squat': 'Legs',
  'Hip Thrust': 'Legs',
  'Good Morning': 'Legs',
  'Calf Raise': 'Legs',
  'Seated Calf Raise': 'Legs',
  // Shoulders
  'Overhead Press': 'Shoulders',
  'Military Press': 'Shoulders',
  'Seated Dumbbell Press': 'Shoulders',
  'Machine Shoulder Press': 'Shoulders',
  'Arnold Press': 'Shoulders',
  'Lateral Raise': 'Shoulders',
  'Cable Lateral Raise': 'Shoulders',
  'Front Raise': 'Shoulders',
  'Rear Delt Fly': 'Shoulders',
  'Face Pull': 'Shoulders',
  'Upright Row': 'Shoulders',
  'Shrug': 'Shoulders',
  // Arms
  'Barbell Curl': 'Arms',
  'Dumbbell Curl': 'Arms',
  'Incline Dumbbell Curl': 'Arms',
  'Hammer Curl': 'Arms',
  'Preacher Curl': 'Arms',
  'Cable Curl': 'Arms',
  'Triceps Pushdown': 'Arms',
  'Overhead Triceps Extension': 'Arms',
  'Skull Crusher': 'Arms',
  'Close-Grip Bench Press': 'Arms',
  'Triceps Dips': 'Arms',
  // Core
  'Plank': 'Core',
  'Cable Crunch': 'Core',
  'Hanging Leg Raise': 'Core',
  'Ab Wheel': 'Core',
  'Crunch': 'Core',
};

/// Big multi-joint lifts: heavier weight jumps, lower rep range.
const compoundLifts = <String>{
  'Bench Press', 'Incline Bench Press', 'Decline Bench Press', 'Dumbbell Press',
  'Incline Dumbbell Press', 'Dips', 'Pull Up', 'Chin Up', 'Barbell Row',
  'T-Bar Row', 'Chest Supported Row', 'Seated Cable Row', 'Dumbbell Row',
  'Lat Pulldown', 'Deadlift', 'Rack Pull', 'Squat', 'Front Squat', 'Hack Squat',
  'Leg Press', 'Romanian Deadlift', 'Dumbbell RDL', 'Stiff-Leg Deadlift',
  'Walking Lunge', 'Lunges', 'Bulgarian Split Squat', 'Hip Thrust',
  'Good Morning', 'Overhead Press', 'Military Press', 'Seated Dumbbell Press',
  'Arnold Press', 'Close-Grip Bench Press',
};

const mainMuscles = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

PlanExercise _e(String n, int sets, int a, int b) => PlanExercise(n, sets, a, b);

const kPlanDisclaimer =
    'Inspired by publicly discussed training styles and simplified into a template. '
    'These are not official programs from the athletes.';

/// Suggested programs shown on the Plans screen.
final List<TrainingPlan> builtInPlans = [
  TrainingPlan(
    id: 'cbum',
    photo: photoGym(800),
    name: 'Chris Bumstead',
    tagline: 'CBum-style classic physique · 5 days',
    level: 'Intermediate',
    about:
        'Aesthetics first: wide shoulders, full chest, thick back and a small waist. '
        'Controlled reps, plenty of machine and cable work, and one dedicated day for hamstrings and glutes.',
    days: [
      PlanDay('Chest & Triceps', [
        _e('Incline Dumbbell Press', 4, 8, 10),
        _e('Bench Press', 3, 8, 10),
        _e('Pec Deck Fly', 3, 10, 12),
        _e('Triceps Pushdown', 3, 10, 12),
        _e('Overhead Triceps Extension', 3, 10, 12),
      ]),
      PlanDay('Back & Biceps', [
        _e('Lat Pulldown', 4, 8, 10),
        _e('Chest Supported Row', 3, 8, 10),
        _e('Seated Cable Row', 3, 10, 12),
        _e('Straight Arm Pulldown', 3, 12, 15),
        _e('Incline Dumbbell Curl', 3, 10, 12),
        _e('Hammer Curl', 3, 10, 12),
      ]),
      PlanDay('Quads & Calves', [
        _e('Hack Squat', 4, 8, 10),
        _e('Leg Press', 3, 10, 12),
        _e('Leg Extension', 3, 12, 15),
        _e('Walking Lunge', 3, 10, 12),
        _e('Calf Raise', 4, 12, 15),
      ]),
      PlanDay('Shoulders', [
        _e('Machine Shoulder Press', 3, 8, 10),
        _e('Lateral Raise', 4, 12, 15),
        _e('Cable Lateral Raise', 3, 12, 15),
        _e('Rear Delt Fly', 3, 12, 15),
        _e('Shrug', 3, 10, 12),
      ]),
      PlanDay('Hamstrings & Glutes', [
        _e('Romanian Deadlift', 4, 8, 10),
        _e('Leg Curl', 4, 10, 12),
        _e('Hip Thrust', 3, 8, 10),
        _e('Seated Calf Raise', 3, 12, 15),
      ]),
    ],
  ),
  TrainingPlan(
    id: 'arnold',
    photo: photoBarbell(800),
    name: 'Arnold Schwarzenegger',
    tagline: 'Golden-era volume · 3-day rotation',
    level: 'Advanced',
    about:
        'Classic high-volume bodybuilding with big compound lifts. Rotate the three days; '
        'the original style ran this split twice a week, so only follow it if you can recover.',
    days: [
      PlanDay('Chest & Back', [
        _e('Bench Press', 4, 8, 10),
        _e('Incline Bench Press', 4, 8, 10),
        _e('Dumbbell Fly', 3, 10, 12),
        _e('Pull Up', 4, 8, 12),
        _e('Barbell Row', 4, 8, 10),
        _e('Deadlift', 3, 6, 8),
      ]),
      PlanDay('Shoulders & Arms', [
        _e('Military Press', 4, 8, 10),
        _e('Lateral Raise', 4, 10, 12),
        _e('Rear Delt Fly', 3, 10, 12),
        _e('Barbell Curl', 4, 8, 10),
        _e('Skull Crusher', 4, 8, 10),
        _e('Hammer Curl', 3, 10, 12),
      ]),
      PlanDay('Legs & Abs', [
        _e('Squat', 5, 8, 10),
        _e('Lunges', 3, 10, 12),
        _e('Leg Curl', 4, 10, 12),
        _e('Leg Extension', 3, 10, 12),
        _e('Calf Raise', 5, 12, 15),
        _e('Hanging Leg Raise', 3, 10, 15),
      ]),
    ],
  ),
  TrainingPlan(
    id: 'ronnie',
    photo: photoRack(800),
    name: 'Ronnie Coleman',
    tagline: 'Heavy, high-volume bodybuilding · 4 days',
    level: 'Advanced',
    about:
        'Heavy basics (rows, squats, deadlifts) followed by lots of volume. Very demanding: '
        'start with fewer sets than listed and build up.',
    days: [
      PlanDay('Back & Biceps', [
        _e('Barbell Row', 4, 8, 10),
        _e('Deadlift', 3, 5, 8),
        _e('T-Bar Row', 3, 8, 10),
        _e('Lat Pulldown', 3, 10, 12),
        _e('Seated Cable Row', 3, 10, 12),
        _e('Barbell Curl', 3, 8, 10),
        _e('Preacher Curl', 3, 10, 12),
      ]),
      PlanDay('Chest, Shoulders & Triceps', [
        _e('Bench Press', 4, 8, 10),
        _e('Incline Dumbbell Press', 3, 8, 10),
        _e('Dumbbell Fly', 3, 10, 12),
        _e('Military Press', 4, 8, 10),
        _e('Lateral Raise', 3, 12, 15),
        _e('Skull Crusher', 3, 8, 10),
        _e('Triceps Pushdown', 3, 10, 12),
      ]),
      PlanDay('Quads', [
        _e('Squat', 4, 8, 10),
        _e('Leg Press', 4, 10, 12),
        _e('Walking Lunge', 3, 10, 12),
        _e('Leg Extension', 3, 12, 15),
      ]),
      PlanDay('Hamstrings & Calves', [
        _e('Stiff-Leg Deadlift', 4, 8, 10),
        _e('Leg Curl', 4, 10, 12),
        _e('Calf Raise', 4, 12, 15),
        _e('Seated Calf Raise', 3, 12, 15),
      ]),
    ],
  ),
  TrainingPlan(
    id: 'nippard',
    photo: photoLift(800),
    name: 'Jeff Nippard',
    tagline: 'Evidence-based upper / lower · 4 days',
    level: 'Intermediate',
    about:
        'Each muscle trained twice a week with a mix of heavier and lighter work. '
        'Moderate volume, hard sets close to failure, and steady progression.',
    days: [
      PlanDay('Upper A', [
        _e('Bench Press', 3, 6, 8),
        _e('Chest Supported Row', 3, 8, 10),
        _e('Overhead Press', 3, 6, 8),
        _e('Lat Pulldown', 3, 8, 10),
        _e('Lateral Raise', 3, 12, 15),
        _e('Dumbbell Curl', 2, 10, 12),
        _e('Triceps Pushdown', 2, 10, 12),
      ]),
      PlanDay('Lower A', [
        _e('Squat', 3, 6, 8),
        _e('Romanian Deadlift', 3, 8, 10),
        _e('Leg Press', 2, 10, 12),
        _e('Leg Curl', 3, 10, 12),
        _e('Calf Raise', 3, 10, 15),
      ]),
      PlanDay('Upper B', [
        _e('Incline Dumbbell Press', 3, 8, 10),
        _e('Seated Cable Row', 3, 8, 10),
        _e('Seated Dumbbell Press', 3, 8, 10),
        _e('Pull Up', 3, 6, 10),
        _e('Cable Fly', 2, 12, 15),
        _e('Incline Dumbbell Curl', 2, 10, 12),
        _e('Overhead Triceps Extension', 2, 10, 12),
      ]),
      PlanDay('Lower B', [
        _e('Hack Squat', 3, 8, 10),
        _e('Hip Thrust', 3, 8, 10),
        _e('Leg Extension', 3, 12, 15),
        _e('Leg Curl', 3, 10, 12),
        _e('Seated Calf Raise', 3, 12, 15),
      ]),
    ],
  ),
  TrainingPlan(
    id: 'mentzer',
    photo: photoGym(800),
    name: 'Mike Mentzer',
    tagline: 'Heavy Duty · low volume, high intensity',
    level: 'Advanced',
    about:
        'Very few sets, each taken to true failure, with long rest between workouts. '
        'Warm up well and only count the hard working sets.',
    days: [
      PlanDay('Chest & Back', [
        _e('Dumbbell Fly', 2, 6, 10),
        _e('Dips', 2, 6, 10),
        _e('Pull Over', 2, 6, 10),
        _e('Chin Up', 2, 6, 10),
        _e('Barbell Row', 2, 6, 10),
      ]),
      PlanDay('Legs', [
        _e('Leg Extension', 2, 6, 10),
        _e('Squat', 2, 6, 10),
        _e('Leg Curl', 2, 6, 10),
        _e('Calf Raise', 2, 8, 12),
      ]),
      PlanDay('Shoulders & Arms', [
        _e('Lateral Raise', 2, 6, 10),
        _e('Overhead Press', 2, 6, 10),
        _e('Barbell Curl', 2, 6, 10),
        _e('Triceps Dips', 2, 6, 10),
      ]),
    ],
  ),
  TrainingPlan(
    id: 'yates',
    photo: photoBarbell(800),
    name: 'Dorian Yates',
    tagline: 'Blood & Guts HIT · 4 days',
    level: 'Advanced',
    about:
        'One or two all-out working sets per exercise after warm-ups, with strict form and big weights. '
        'Short workouts, lots of recovery.',
    days: [
      PlanDay('Chest & Triceps', [
        _e('Incline Dumbbell Press', 2, 6, 10),
        _e('Pec Deck Fly', 1, 8, 12),
        _e('Dips', 2, 6, 10),
        _e('Skull Crusher', 2, 6, 10),
        _e('Triceps Pushdown', 1, 8, 12),
      ]),
      PlanDay('Back & Rear Delts', [
        _e('Pull Up', 2, 6, 10),
        _e('Barbell Row', 2, 6, 10),
        _e('T-Bar Row', 2, 6, 10),
        _e('Deadlift', 2, 5, 8),
        _e('Rear Delt Fly', 2, 8, 12),
      ]),
      PlanDay('Shoulders & Biceps', [
        _e('Seated Dumbbell Press', 2, 6, 10),
        _e('Lateral Raise', 2, 8, 12),
        _e('Shrug', 2, 8, 12),
        _e('Barbell Curl', 2, 6, 10),
        _e('Preacher Curl', 2, 8, 12),
      ]),
      PlanDay('Legs', [
        _e('Leg Extension', 2, 8, 12),
        _e('Squat', 2, 6, 10),
        _e('Leg Press', 2, 8, 12),
        _e('Leg Curl', 2, 8, 12),
        _e('Calf Raise', 2, 8, 12),
      ]),
    ],
  ),
  TrainingPlan(
    id: 'beginner',
    photo: photoLift(800),
    name: 'Beginner Full Body',
    tagline: 'Simple full-body starter · 3 days',
    level: 'Beginner',
    about:
        'Three full-body sessions a week built on basic lifts. Learn the movements, '
        'add a little weight or a rep every session, and rest a day between workouts.',
    days: [
      PlanDay('Full Body A', [
        _e('Squat', 3, 8, 10),
        _e('Bench Press', 3, 8, 10),
        _e('Seated Cable Row', 3, 8, 12),
        _e('Overhead Press', 2, 8, 10),
        _e('Cable Crunch', 3, 10, 15),
      ]),
      PlanDay('Full Body B', [
        _e('Romanian Deadlift', 3, 8, 10),
        _e('Incline Dumbbell Press', 3, 8, 12),
        _e('Lat Pulldown', 3, 8, 12),
        _e('Leg Press', 3, 10, 12),
        _e('Dumbbell Curl', 2, 10, 12),
        _e('Triceps Pushdown', 2, 10, 12),
      ]),
      PlanDay('Full Body C', [
        _e('Lunges', 3, 10, 12),
        _e('Dumbbell Press', 3, 8, 12),
        _e('Dumbbell Row', 3, 8, 12),
        _e('Lateral Raise', 3, 12, 15),
        _e('Leg Curl', 3, 10, 12),
        _e('Hanging Leg Raise', 3, 8, 12),
      ]),
    ],
  ),
];
