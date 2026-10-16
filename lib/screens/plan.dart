import 'package:flutter/material.dart';
import '../data.dart';
import '../models.dart';
import '../photos.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'plan_editor.dart';
import 'workout.dart';

/// Plans tab. On wide screens: suggestions on the left, details on the right.
/// On phones: a list that opens the details as a page.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String? selectedId;

  Future<void> _create() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const PlanEditorScreen()),
    );
    if (id != null && mounted) setState(() => selectedId = id);
  }

  void _open(TrainingPlan p, bool wide) {
    if (wide) {
      setState(() => selectedId = p.id);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlanDetailPage(planId: p.id)),
      );
    }
  }

  Widget _list(AppStore store, bool wide, TrainingPlan selected) {
    Widget tile(TrainingPlan p) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _PlanTile(
            plan: p,
            active: store.activePlanId == p.id,
            selected: wide && selected.id == p.id,
            onTap: () => _open(p, wide),
          ),
        );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text('Plans', style: Txt.h1),
          const SizedBox(height: 2),
          Text('Pick a program or build your own.',
              style: Txt.caption.copyWith(fontSize: 13)),
          const SectionHeader('Suggested programs'),
          for (final p in builtInPlans) tile(p),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _create,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create your own plan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kAccent,
              side: BorderSide(color: kAccent.withValues(alpha: 0.5)),
            ),
          ),
          if (store.customPlans.isNotEmpty) ...[
            const SectionHeader('My plans'),
            for (final p in store.customPlans) tile(p),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 820;
      final selected = store.planById(selectedId) ?? builtInPlans.first;
      if (!wide) return _list(store, false, selected);
      return Row(
        children: [
          SizedBox(width: 380, child: _list(store, true, selected)),
          const VerticalDivider(width: 1),
          Expanded(
            child: SafeArea(
              child: PlanDetailView(key: ValueKey(selected.id), plan: selected),
            ),
          ),
        ],
      );
    });
  }
}

class _PlanTile extends StatelessWidget {
  final TrainingPlan plan;
  final bool active;
  final bool selected;
  final VoidCallback onTap;
  const _PlanTile({
    required this.plan,
    required this.active,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: selected ? kAccent : null,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoBanner(
            url: plan.photo ?? photoRack(800),
            height: 120,
            radius: 0,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(plan.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: Txt.h2),
                ),
                if (active) const Tag('ACTIVE', color: kAccent),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(plan.tagline,
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: Txt.caption),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: kFaint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlanDetailPage extends StatelessWidget {
  final String planId;
  const PlanDetailPage({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final plan = store.planById(planId);
    return Scaffold(
      appBar: AppBar(),
      body: plan == null
          ? const Center(child: Text('This plan no longer exists.', style: Txt.caption))
          : PlanDetailView(plan: plan, onDeleted: () => Navigator.pop(context)),
    );
  }
}

class PlanDetailView extends StatelessWidget {
  final TrainingPlan plan;
  final VoidCallback? onDeleted;
  const PlanDetailView({super.key, required this.plan, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final active = store.activePlanId == plan.id;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            PhotoBanner(
              url: plan.photo ?? photoRack(800),
              height: 190,
              radius: 18,
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: Txt.h1),
                  const SizedBox(height: 2),
                  Text(plan.tagline, style: Txt.caption.copyWith(color: kText)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (plan.level.isNotEmpty) Tag(plan.level, color: kAccent),
                Tag('${plan.days.length} day${plan.days.length == 1 ? '' : 's'}'),
                Tag('${plan.exerciseCount} exercises'),
              ],
            ),
            if (plan.about.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(plan.about, style: Txt.body.copyWith(color: kMuted)),
            ],
            const SizedBox(height: 18),
            if (active)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: kAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Active plan',
                              style: TextStyle(
                                  fontFamily: kFont,
                                  fontWeight: FontWeight.w500,
                                  color: kAccent)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: store.clearActivePlan,
                    style: TextButton.styleFrom(foregroundColor: kMuted),
                    child: const Text('Stop'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () {
                  store.setActivePlan(plan.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${plan.name} is now your active plan.')),
                  );
                },
                child: const Text('Use this plan'),
              ),
            if (plan.custom) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PlanEditorScreen(existing: plan))),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await confirm(
                          context,
                          'Delete plan?',
                          '"${plan.name}" will be removed. Your workout history stays.',
                          confirmLabel: 'Delete',
                          danger: true,
                        );
                        if (!ok) return;
                        store.deleteCustomPlan(plan.id);
                        onDeleted?.call();
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: kDanger),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
            if (!plan.custom) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: kFaint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(kPlanDisclaimer,
                        style: Txt.caption.copyWith(fontSize: 11.5, color: kFaint)),
                  ),
                ],
              ),
            ],
            const SectionHeader('Workout days'),
            for (var i = 0; i < plan.days.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DayCard(plan: plan, index: i),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final TrainingPlan plan;
  final int index;
  const _DayCard({required this.plan, required this.index});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final day = plan.days[index];
    final isNext = store.activePlanId == plan.id && store.nextDayIndex == index;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      borderColor: isNext ? kAccent.withValues(alpha: 0.5) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kSurface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${index + 1}',
                    style: Txt.caption.copyWith(color: kText, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.name, style: Txt.titleBold),
                    if (isNext) const Text('Up next', style: Txt.caption),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => openWorkout(
                  context,
                  title: day.name,
                  items: day.exercises,
                  planId: plan.id,
                  dayIndex: index,
                  planName: plan.name,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Start'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < day.exercises.length; i++) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 9, right: 8),
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
