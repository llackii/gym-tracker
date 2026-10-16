import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../suggest.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _Pr {
  final String name;
  final double weight;
  final int reps;
  final DateTime date;
  _Pr(this.name, this.weight, this.reps, this.date);
}

class _ProgressScreenState extends State<ProgressScreen> {
  int rangeDays = 90; // 0 = all time
  String? selected;
  bool est1rm = false;

  static const _hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final p = store.profile;
    if (p == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final cutoff = rangeDays == 0 ? null : now.subtract(Duration(days: rangeDays));
    bool inRange(DateTime d) => cutoff == null || !d.isBefore(cutoff);

    final chrono = [...store.sessions]..sort((a, b) => a.date.compareTo(b.date));
    final inSessions = chrono.where((s) => inRange(s.date)).toList();

    if (store.sessions.isEmpty && store.weights.length < 2) {
      return AppPage(
        title: 'Progress',
        children: const [
          SizedBox(height: 16),
          EmptyState(
            icon: Icons.insights_rounded,
            title: 'Nothing to show yet',
            message: 'Finish a workout and your strength, consistency and muscle balance will appear here.',
          ),
        ],
      );
    }

    final totalSets = inSessions.fold<int>(0, (a, s) => a + s.totalSets);
    final distinct = <String>{
      for (final s in inSessions) for (final e in s.exercises) e.name
    }.length;

    return AppPage(
      title: 'Progress',
      children: [
        const SizedBox(height: 16),
        Segmented<int>(
          options: const {28: '4 weeks', 90: '3 months', 0: 'All time'},
          value: rangeDays,
          onChanged: (v) => setState(() => rangeDays = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: StatTile('Workouts', '${inSessions.length}')),
            const SizedBox(width: 10),
            Expanded(child: StatTile('Sets', '$totalSets')),
            const SizedBox(width: 10),
            Expanded(child: StatTile('Exercises', '$distinct')),
          ],
        ),
        const SectionHeader('Consistency'),
        _consistency(store, p.daysPerWeek),
        const SectionHeader('Strength'),
        _strength(store, chrono, inSessions),
        const SectionHeader('Body weight'),
        _bodyWeight(store, inRange),
        const SectionHeader('Muscle balance'),
        _balance(inSessions),
        const SectionHeader('Personal records'),
        _records(chrono),
      ],
    );
  }

  // ---------- consistency ----------

  Widget _consistency(AppStore store, int goal) {
    final thisWeek = startOfWeek(DateTime.now());
    final weeks = [
      for (var i = 7; i >= 0; i--)
        DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7 * i)
    ];
    final counts = [
      for (final w in weeks)
        store.sessions.where((s) => startOfWeek(s.date) == w).length
    ];
    final maxCount = counts.reduce(math.max);
    final maxY = math.max(goal, maxCount).toDouble() + 1;
    final interval = math.max(1, (maxY / 5).ceil()).toDouble();
    final streak = weekStreak(store.sessions);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$streak', style: Txt.statLg),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('week streak', style: Txt.caption.copyWith(fontSize: 13)),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('Goal: $goal / week',
                    style: Txt.caption.copyWith(color: kAccent)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: kBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: _hidden,
                  rightTitles: _hidden,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: interval,
                      getTitlesWidget: (v, meta) => v == v.roundToDouble()
                          ? Text(v.toInt().toString(), style: Txt.axis)
                          : const SizedBox.shrink(),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= weeks.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            i == weeks.length - 1 ? 'Now' : shortDate(weeks[i]),
                            style: Txt.axis.copyWith(fontSize: 9.5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < counts.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: counts[i].toDouble(),
                          width: 16,
                          color: counts[i] >= goal ? kAccent : kBlue.withValues(alpha: 0.55),
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(5)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Goal reached', style: Txt.caption.copyWith(fontSize: 11)),
              const SizedBox(width: 14),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: kBlue.withValues(alpha: 0.55), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Below goal', style: Txt.caption.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- strength ----------

  Widget _strength(
      AppStore store, List<WorkoutSession> chrono, List<WorkoutSession> inSessions) {
    final names = <String>[];
    final seen = <String>{};
    for (final s in store.sessionsNewestFirst) {
      for (final e in s.exercises) {
        if (e.best > 0 && seen.add(e.name)) names.add(e.name);
      }
    }
    if (names.isEmpty) {
      return const AppCard(
        child: Text('Log a weighted exercise to see your strength curve here.',
            style: Txt.caption),
      );
    }
    final sel = (selected != null && names.contains(selected)) ? selected! : names.first;

    final pts = <(DateTime, double)>[];
    for (final s in inSessions) {
      for (final e in s.exercises) {
        if (e.name == sel && e.best > 0) {
          pts.add((s.date, est1rm ? e.est1rm : e.best));
        }
      }
    }

    double allTimeBest = 0;
    for (final s in chrono) {
      for (final e in s.exercises) {
        if (e.name == sel) {
          final v = est1rm ? e.est1rm : e.best;
          if (v > allTimeBest) allTimeBest = v;
        }
      }
    }

    final current = pts.isEmpty ? 0.0 : pts.last.$2;
    final delta = pts.length >= 2 ? pts.last.$2 - pts.first.$2 : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: names.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => OptionChip(names[i],
                  selected: names[i] == sel,
                  onTap: () => setState(() => selected = names[i])),
            ),
          ),
          const SizedBox(height: 16),
          Segmented<bool>(
            options: const {false: 'Top weight', true: 'Est. 1RM'},
            value: est1rm,
            onChanged: (v) => setState(() => est1rm = v),
          ),
          const SizedBox(height: 18),
          if (pts.isEmpty)
            const Text('No sessions of this exercise in the selected period.',
                style: Txt.caption)
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(fmtNum(current), style: Txt.statLg),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text('kg', style: Txt.caption),
                ),
                const Spacer(),
                if (pts.length >= 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Tag(
                      '${delta >= 0 ? '+' : ''}${fmtNum(delta)} kg',
                      color: delta >= 0 ? kAccent : kDanger,
                    ),
                  ),
              ],
            ),
            Text('All-time best: ${fmtNum(allTimeBest)} kg', style: Txt.caption),
            const SizedBox(height: 16),
            if (pts.length >= 2)
              _lineChart([for (final p in pts) p.$2], [for (final p in pts) p.$1], 'kg')
            else
              const Text('Log this exercise once more to see a trend line.',
                  style: Txt.caption),
          ],
        ],
      ),
    );
  }

  // ---------- body weight ----------

  Widget _bodyWeight(AppStore store, bool Function(DateTime) inRange) {
    final all = [...store.weights]..sort((a, b) => a.date.compareTo(b.date));
    final pts = all.where((w) => inRange(w.date)).toList();
    final current = all.isEmpty ? store.profile!.weightKg : all.last.kg;
    final delta = pts.length >= 2 ? pts.last.kg - pts.first.kg : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmtNum(current), style: Txt.statLg),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('kg', style: Txt.caption),
              ),
              const SizedBox(width: 10),
              if (pts.length >= 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Tag('${delta >= 0 ? '+' : ''}${fmtNum(delta)} kg'),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _logWeight(store),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Log'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pts.length >= 2)
            _lineChart([for (final w in pts) w.kg], [for (final w in pts) w.date], 'kg',
                color: kBlue)
          else
            const Text('Log your weight on a few different days to see the trend.',
                style: Txt.caption),
        ],
      ),
    );
  }

  Future<void> _logWeight(AppStore store) async {
    final c = TextEditingController(text: fmtNum(store.profile!.weightKg));
    final kg = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log body weight'),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight', suffixText: 'kg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: kMuted),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, double.tryParse(c.text.trim().replaceAll(',', '.'))),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    c.dispose();
    if (kg != null && kg > 0) store.addWeight(kg);
  }

  // ---------- muscle balance ----------

  Widget _balance(List<WorkoutSession> inSessions) {
    final sets = <String, int>{};
    for (final s in inSessions) {
      for (final e in s.exercises) {
        sets[e.muscle] = (sets[e.muscle] ?? 0) + e.sets.length;
      }
    }
    if (sets.isEmpty) {
      return const AppCard(
        child: Text('Sets per muscle group will appear after your first workout.',
            style: Txt.caption),
      );
    }
    final total = sets.values.fold<int>(0, (a, b) => a + b);
    final entries = sets.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final missing = neglectedMuscles(inSessions, days: rangeDays == 0 ? 3650 : rangeDays);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 44,
                        startDegreeOffset: -90,
                        borderData: FlBorderData(show: false),
                        sections: [
                          for (final e in entries)
                            PieChartSectionData(
                              value: e.value.toDouble(),
                              color: muscleColor(e.key),
                              radius: 16,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$total', style: Txt.stat),
                        const Text('sets', style: Txt.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: muscleColor(e.key), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(e.key, style: Txt.body)),
                            Text('${(e.value * 100 / total).round()}%',
                                style: Txt.caption.copyWith(color: kText)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: kFaint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Not trained in this period: ${missing.join(', ')}.',
                      style: Txt.caption),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------- records ----------

  Widget _records(List<WorkoutSession> chrono) {
    final map = <String, _Pr>{};
    for (final s in chrono) {
      for (final e in s.exercises) {
        if (e.best <= 0) continue;
        final cur = map[e.name];
        if (cur == null || e.best >= cur.weight) {
          map[e.name] = _Pr(e.name, e.best, e.bestReps, s.date);
        }
      }
    }
    if (map.isEmpty) {
      return const AppCard(
        child: Text('Your best lifts will be listed here.', style: Txt.caption),
      );
    }
    final list = map.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    final shown = list.take(8).toList();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 18, color: kAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shown[i].name, style: Txt.title),
                        Text(shortDate(shown[i].date), style: Txt.caption),
                      ],
                    ),
                  ),
                  Text('${fmtNum(shown[i].weight)} kg × ${shown[i].reps}',
                      style: Txt.titleBold.copyWith(fontSize: 14)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------- shared line chart ----------

  Widget _lineChart(List<double> ys, List<DateTime> dates, String unit,
      {Color color = kAccent}) {
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);
    final span = maxY - minY;
    final pad = span == 0 ? math.max(1.0, maxY * 0.05) : span * 0.3;
    final lo = math.max(0.0, minY - pad).floorToDouble();
    final hi = (maxY + pad).ceilToDouble();
    final n = ys.length;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (n - 1).toDouble(),
          minY: lo,
          maxY: hi,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: kBorder, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: _hidden,
            rightTitles: _hidden,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(fmtNum(v), textAlign: TextAlign.right, style: Txt.axis),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  final i = v.round();
                  if ((v - i).abs() > 0.01 || i < 0 || i >= n) {
                    return const SizedBox.shrink();
                  }
                  final show = i == 0 || i == n - 1 || (n > 4 && i == n ~/ 2);
                  if (!show) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(shortDate(dates[i]), style: Txt.axis),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => kSelected,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${fmtNum(s.y)} $unit\n${shortDate(dates[s.x.toInt()])}',
                    Txt.tooltip,
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < n; i++) FlSpot(i.toDouble(), ys[i])],
              isCurved: true,
              curveSmoothness: 0.2,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(show: n <= 20),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
