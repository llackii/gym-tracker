import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final sessions = store.sessionsNewestFirst;

    return AppPage(
      title: 'History',
      subtitle: sessions.isEmpty
          ? null
          : '${sessions.length} workout${sessions.length == 1 ? '' : 's'} logged',
      children: [
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          const EmptyState(
            icon: Icons.history_rounded,
            title: 'No workouts yet',
            message: 'Finished workouts will show up here.',
          )
        else
          for (final s in sessions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SessionCard(session: s),
            ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;
    final meta = <String>[
      '${s.exercises.length} exercises',
      '${s.totalSets} sets',
      if (s.durationSec != null && s.durationSec! >= 60) fmtMinutes(s.durationSec!),
    ].join('  ·  ');

    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: kMuted,
          collapsedIconColor: kFaint,
          leading: Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: kSurface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${s.date.day}', style: Txt.titleBold.copyWith(height: 1.1)),
                Text(monthShort(s.date).toUpperCase(),
                    style: Txt.label.copyWith(fontSize: 9.5, letterSpacing: 0.6)),
              ],
            ),
          ),
          title: Text(s.title, style: Txt.titleBold),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(meta, style: Txt.caption),
          ),
          children: [
            const Divider(),
            const SizedBox(height: 10),
            for (final e in s.exercises) ...[
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: muscleColor(e.muscle),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.name, style: Txt.title)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final set in e.sets)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        set.weight == 0
                            ? '${set.reps} reps'
                            : '${fmtNum(set.weight)} kg × ${set.reps}',
                        style: Txt.caption.copyWith(color: kText, fontSize: 12.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final store = StoreScope.of(context);
                  final ok = await confirm(
                    context,
                    'Delete workout?',
                    'This workout will be removed from your history.',
                    confirmLabel: 'Delete',
                    danger: true,
                  );
                  if (ok) store.deleteSession(s.id);
                },
                style: TextButton.styleFrom(foregroundColor: kDanger),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
