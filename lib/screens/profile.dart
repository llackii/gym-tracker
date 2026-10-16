import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../store.dart';
import '../suggest.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final p = store.profile;
    if (p == null) return const SizedBox.shrink();

    final sets = store.sessions.fold<int>(0, (a, s) => a + s.totalSets);
    final bmi = p.heightCm > 0 ? p.weightKg / ((p.heightCm / 100) * (p.heightCm / 100)) : 0.0;

    return AppPage(
      title: 'Profile',
      children: [
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Monogram(p.name.isEmpty ? '?' : p.name[0].toUpperCase(), size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: Txt.h2),
                        const SizedBox(height: 2),
                        Text(p.goal, style: Txt.caption.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit profile',
                    onPressed: () => _editProfile(context, store, p),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _Info('Height', '${fmtNum(p.heightCm)} cm')),
                  Expanded(child: _Info('Weight', '${fmtNum(p.weightKg)} kg')),
                  Expanded(child: _Info('BMI', bmi.toStringAsFixed(1))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: StatTile('Workouts', '${store.sessions.length}')),
            const SizedBox(width: 10),
            Expanded(child: StatTile('Total sets', '$sets')),
            const SizedBox(width: 10),
            Expanded(child: StatTile('Streak', '${weekStreak(store.sessions)} wk')),
          ],
        ),
        const SectionHeader('Settings'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.flag_outlined,
                title: 'Goal',
                value: p.goal,
                onTap: () => _pickGoal(context, store, p),
              ),
              const Divider(),
              _SettingTile(
                icon: Icons.calendar_today_outlined,
                title: 'Weekly target',
                value: '${p.daysPerWeek} workouts',
                onTap: () => _pickDays(context, store, p),
              ),
              const Divider(),
              _SettingTile(
                icon: Icons.assignment_outlined,
                title: 'Active plan',
                value: store.activePlan?.name ?? 'None',
              ),
            ],
          ),
        ),
        const SectionHeader('Data'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.ios_share_rounded,
                title: 'Export data',
                value: 'Copy as JSON',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(
                      text: const JsonEncoder.withIndent('  ').convert(store.toJson())));
                  messenger.showSnackBar(
                      const SnackBar(content: Text('Data copied to clipboard.')));
                },
              ),
              const Divider(),
              _SettingTile(
                icon: Icons.logout_rounded,
                title: 'Sign out',
                value: store.authEmail,
                onTap: () => store.signOut(),
              ),
              const Divider(),
              _SettingTile(
                icon: Icons.delete_outline_rounded,
                title: 'Reset all data',
                danger: true,
                onTap: () async {
                  final ok = await confirm(
                    context,
                    'Reset everything?',
                    'Your profile, workouts, plans and weight history will be deleted. This cannot be undone.',
                    confirmLabel: 'Reset',
                    danger: true,
                  );
                  if (ok) await store.resetAll();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Center(child: Text('Gym Tracker', style: Txt.caption)),
      ],
    );
  }

  Future<void> _pickGoal(BuildContext context, AppStore store, Profile p) async {
    final g = await _pickOne<String>(
      context,
      'Goal',
      const ['Build muscle', 'Lose fat', 'Get stronger'],
      p.goal,
      (v) => v,
    );
    if (g == null) return;
    store.updateProfile(Profile(
      name: p.name,
      heightCm: p.heightCm,
      weightKg: p.weightKg,
      goal: g,
      daysPerWeek: p.daysPerWeek,
    ));
  }

  Future<void> _pickDays(BuildContext context, AppStore store, Profile p) async {
    final d = await _pickOne<int>(
      context,
      'Workouts per week',
      const [2, 3, 4, 5, 6],
      p.daysPerWeek,
      (v) => '$v workouts',
    );
    if (d != null) store.setDaysPerWeek(d);
  }

  Future<T?> _pickOne<T>(BuildContext context, String title, List<T> options,
      T current, String Function(T) label) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title, style: Txt.h2),
                ),
              ),
              for (final o in options)
                ListTile(
                  onTap: () => Navigator.pop(ctx, o),
                  title: Text(label(o), style: Txt.title),
                  trailing: o == current
                      ? const Icon(Icons.check_rounded, color: kAccent)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, AppStore store, Profile p) async {
    final name = TextEditingController(text: p.name);
    final height = TextEditingController(text: fmtNum(p.heightCm));
    final weight = TextEditingController(text: fmtNum(p.weightKg));
    final result = await showDialog<Profile>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: height,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Height', suffixText: 'cm'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Weight', suffixText: 'kg'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: kMuted),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final h = double.tryParse(height.text.trim().replaceAll(',', '.'));
              final w = double.tryParse(weight.text.trim().replaceAll(',', '.'));
              if (name.text.trim().isEmpty ||
                  h == null || w == null ||
                  h < 80 || h > 250 || w < 20 || w > 350) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Check the values you entered.')));
                return;
              }
              Navigator.pop(
                ctx,
                Profile(
                  name: name.text.trim(),
                  heightCm: h,
                  weightKg: w,
                  goal: p.goal,
                  daysPerWeek: p.daysPerWeek,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    name.dispose();
    height.dispose();
    weight.dispose();
    if (result != null) store.updateProfile(result);
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: Txt.label.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: Txt.titleBold),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool danger;
  final VoidCallback? onTap;
  const _SettingTile({
    required this.icon,
    required this.title,
    this.value,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? kDanger : kText;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? kDanger : kMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: Txt.title.copyWith(color: color)),
            ),
            if (value != null)
              Flexible(
                child: Text(value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Txt.caption.copyWith(fontSize: 13)),
              ),
            if (onTap != null && !danger) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 20, color: kFaint),
            ],
          ],
        ),
      ),
    );
  }
}
