import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'screens/shell.dart';
import 'store.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GymApp());
}

class GymApp extends StatefulWidget {
  const GymApp({super.key});
  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  final AppStore store = AppStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: MaterialApp(
        title: 'Gym Tracker',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    if (!store.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (store.authEmail == null) return const LoginScreen();
    if (store.profile == null) return const OnboardingScreen();
    return const Shell();
  }
}
