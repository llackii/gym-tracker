import 'package:flutter/material.dart';
import '../models.dart';
import '../photos.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final name = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  String goal = 'Build muscle';
  int days = 4;

  @override
  void dispose() {
    name.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  void submit() {
    final n = name.text.trim();
    final h = double.tryParse(height.text.trim().replaceAll(',', '.'));
    final w = double.tryParse(weight.text.trim().replaceAll(',', '.'));
    if (n.isEmpty || h == null || w == null || h < 80 || h > 250 || w < 20 || w > 350) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter a name, height (80–250 cm) and weight (20–350 kg).'),
      ));
      return;
    }
    StoreScope.of(context).setProfile(
      Profile(name: n, heightCm: h, weightKg: w, goal: goal, daysPerWeek: days),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              children: [
                PhotoBanner(
                  url: photoLift(1000),
                  height: 170,
                  radius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.fitness_center_rounded,
                        color: kOnAccent, size: 22),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Set up your profile', style: Txt.h1),
                const SizedBox(height: 6),
                const Text(
                  'Gym Tracker works offline and keeps everything on this device.',
                  style: Txt.caption,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: height,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Height', suffixText: 'cm'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: weight,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Weight', suffixText: 'kg'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('GOAL', style: Txt.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in ['Build muscle', 'Lose fat', 'Get stronger'])
                      OptionChip(g,
                          selected: goal == g, onTap: () => setState(() => goal = g)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('WORKOUTS PER WEEK', style: Txt.label),
                const SizedBox(height: 10),
                Segmented<int>(
                  options: const {2: '2', 3: '3', 4: '4', 5: '5', 6: '6'},
                  value: days,
                  onChanged: (v) => setState(() => days = v),
                ),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: submit, child: const Text('Continue')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
