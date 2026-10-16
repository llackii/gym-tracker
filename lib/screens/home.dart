import 'package:flutter/material.dart';
import '../models.dart';
import '../photos.dart';
import '../store.dart';
import '../suggest.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';
import 'shell.dart';
import 'workout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final p = store.profile;
    if (p == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final sessions = store.sessionsNewestFirst;
    final plan = store.activePlan;
    final dayIdx = store.nextDayIndex;
    final day = (plan != null && plan.days.isNotEmpty) ? plan.days[dayIdx] : null;
    final thisWeek =
        sessions.where((s) => !s.date.isBefore(startOfWeek(now))).length;

    // Targets for the next session
    final String targetsTitle;
    final List<PlanExercise> source;
    if (day != null) {
      targetsTitle = 'Targets for next session';
      source = day.exercises;
    } else if (sessions.isNotEmpty) {
      targetsTitle = 'Targets from your last workout';
      source = [
        for (final e in sessions.first.exercises)
          PlanExercise(e.name, e.sets.length, store.repRange(e.name).$1,
              store.repRange(e.name).$2)
      ];
    } else {
      targetsTitle = '';
      source = const [];
    }
    final targets = <(String, Progression)>[];
    for (final ex in source) {
      final prog = progressionFor(ex.name, sessions,
          repMin: ex.repMin, repMax: ex.repMax, compound: store.isCompound(ex.name));
      if (prog != null) targets.add((ex.name, prog));
    }

    final first = p.name.trim().split(' ').first;

    return AppPage(
      children: [
        PhotoBanner(
          url: photoGym(1200),
          height: 200,
          radius: 20,
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dayDate(now).toUpperCase(),
                        style: Txt.label.copyWith(color: kText)),
                    const SizedBox(height: 6),
                    Text('${_greeting()},',
                        style: Txt.caption.copyWith(fontSize: 14, color: kText)),
                    Text(first, style: Txt.h1.copyWith(fontSize: 30)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => tabIndex.value = 4,
                child: Monogram(
                  first.isEmpty ? '?' : first[0].toUpperCase(),
                  size: 46,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _todayCard(context, store, plan, day, dayIdx),
        const SizedBox(height: 12),
        _weekStrip(sessions, now),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatTile('This week', '$thisWeek / ${p.daysPerWeek}')),
            const SizedBox(width: 10),
            Expanded(child: StatTile('Streak', '${weekStreak(sessions)} wk')),
            const SizedBox(width: 10),
            Expanded(child: StatTile('Workouts', '${sessions.length}')),
          ],
        ),
        if (targets.isNotEmpty) ...[
          SectionHeader(targetsTitle),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < targets.length && i < 6; i++) ...[
                  if (i > 0) const Divider(),
                  _TargetRow(name: targets[i].$1, prog: targets[i].$2),
                ],
              ],
            ),
          ),
        ] else if (day != null) ...[
          const SectionHeader('Targets for next session'),
          const AppCard(
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: kFaint),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Log your first workout and the app will calculate the weight and reps to aim for next time.',
                    style: Txt.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _todayCard(BuildContext context, AppStore store, TrainingPlan? plan,
      PlanDay? day, int dayIdx) {
    if (plan == null || day == null) {
      return AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(Icons.assignment_outlined, size: 44),
            const SizedBox(height: 16),
            const Text('Choose a training plan', style: Txt.h2),
            const SizedBox(height: 4),
            const Text(
              'Follow a proven program or build your own. Your next workout will show up here.',
              style: Txt.caption,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => tabIndex.value = 1,
              child: const Text('Browse plans'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => openWorkout(context, title: 'Workout'),
              child: const Text('Start empty workout'),
            ),
          ],
        ),
      );
    }

    final exs = day.exercises;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Tag('NEXT WORKOUT', color: kAccent),
              const Spacer(),
              Text('Day ${dayIdx + 1} of ${plan.days.length}', style: Txt.caption),
            ],
          ),
          const SizedBox(height: 14),
          Text(day.name, style: Txt.h2),
          const SizedBox(height: 2),
          Text('${plan.name} · ${exs.length} exercises', style: Txt.caption),
          const SizedBox(height: 14),
          for (var i = 0; i < exs.length && i < 4; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: muscleColor(store.muscleOf(exs[i].name)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(exs[i].name, style: Txt.title)),
                  Text('${exs[i].sets} × ${exs[i].repsLabel}',
                      style: Txt.caption.copyWith(fontSize: 13)),
                ],
              ),
            ),
          if (exs.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 18),
              child: Text('+${exs.length - 4} more', style: Txt.caption),
            ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => openWorkout(
              context,
              title: day.name,
              items: day.exercises,
              planId: plan.id,
              dayIndex: dayIdx,
              planName: plan.name,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start workout'),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => openWorkout(context, title: 'Workout'),
              style: TextButton.styleFrom(foregroundColor: kMuted),
              child: const Text('Start empty workout instead'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekStrip(List<WorkoutSession> sessions, DateTime now) {
    final ws = startOfWeek(now);
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Builder(builder: (context) {
                final d = DateTime(ws.year, ws.month, ws.day + i);
                final done = sessions.any((s) => sameDay(s.date, d));
                final today = sameDay(d, now);
                return Column(
                  children: [
                    Text(letters[i], style: Txt.label),
                    const SizedBox(height: 8),
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? kAccent : Colors.transparent,
                        border: done
                            ? null
                            : Border.all(color: today ? kAccent : kBorder),
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded, size: 18, color: kOnAccent)
                          : Text('${d.day}',
                              style: Txt.caption.copyWith(
                                  color: today ? kText : kMuted, fontSize: 12.5)),
                    ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String name;
  final Progression prog;
  const _TargetRow({required this.name, required this.prog});

  @override
  Widget build(BuildContext context) {
    final o = prog.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Txt.title),
                const SizedBox(height: 2),
                Text('Last: ${prog.last}',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: Txt.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(o.text,
                  style: Txt.titleBold.copyWith(color: kAccent, fontSize: 14)),
              Text(o.label, style: Txt.caption.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
