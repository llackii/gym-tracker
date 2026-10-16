import 'package:flutter/material.dart';
import '../theme.dart';
import 'history.dart';
import 'home.dart';
import 'plan.dart';
import 'profile.dart';
import 'progress.dart';

/// Lets any screen switch tabs, e.g. `tabIndex.value = 1` opens Plans.
final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

class Shell extends StatelessWidget {
  const Shell({super.key});

  static const _pages = <Widget>[
    HomeScreen(),
    PlanScreen(),
    ProgressScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  static const _items = <(String, IconData, IconData)>[
    ('Home', Icons.home_outlined, Icons.home_rounded),
    ('Plans', Icons.assignment_outlined, Icons.assignment_rounded),
    ('Progress', Icons.insights_outlined, Icons.insights_rounded),
    ('History', Icons.history_rounded, Icons.history_rounded),
    ('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, index, _) {
        final wide = MediaQuery.of(context).size.width >= 820;
        final body = IndexedStack(index: index, children: _pages);

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 92,
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: kBorder)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fitness_center_rounded,
                            color: kOnAccent, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: NavigationRail(
                          selectedIndex: index,
                          onDestinationSelected: (i) => tabIndex.value = i,
                          labelType: NavigationRailLabelType.all,
                          destinations: [
                            for (final it in _items)
                              NavigationRailDestination(
                                icon: Icon(it.$2),
                                selectedIcon: Icon(it.$3),
                                label: Text(it.$1),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kBorder)),
            ),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => tabIndex.value = i,
              destinations: [
                for (final it in _items)
                  NavigationDestination(
                    icon: Icon(it.$2),
                    selectedIcon: Icon(it.$3),
                    label: it.$1,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
