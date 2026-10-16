import 'package:flutter/material.dart';
import '../photos.dart';
import '../store.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _createAccount = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    // The signed-in email is stored on this device only. Connect Firebase
    // Authentication for real accounts that work across devices.
    await StoreScope.of(context).signIn(_email.text.trim());
    if (mounted) setState(() => _busy = false);
  }

  void _googleInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Google sign-in'),
        content: const Text(
          'Google sign-in needs Firebase Authentication to be set up in this app. '
          'Until then, use your email to continue.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            photoGym(1400),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: kSurface),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x990B0D10), Color(0xEB0B0D10), kBg],
                stops: [0, 0.45, 0.8],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.fitness_center_rounded,
                          color: kOnAccent, size: 26),
                    ),
                    const SizedBox(height: 120),
                    Text('GYM TRACKER',
                        style: Txt.label.copyWith(color: kAccent, letterSpacing: 3)),
                    const SizedBox(height: 10),
                    Text(
                      _createAccount ? 'Create your\naccount.' : 'Welcome\nback.',
                      style: Txt.h1.copyWith(fontSize: 38, height: 1.1, letterSpacing: -1),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _createAccount
                          ? 'Start building better habits, one workout at a time.'
                          : 'Sign in to continue your training.',
                      style: Txt.caption.copyWith(fontSize: 14, color: kMuted),
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _form,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (v) {
                              final x = (v ?? '').trim();
                              if (!x.contains('@') || !x.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _hidePassword,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _hidePassword = !_hidePassword),
                                icon: Icon(_hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                              ),
                            ),
                            validator: (v) => (v ?? '').length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _busy ? null : _continue,
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_createAccount ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text('OR', style: Txt.label),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: _googleInfo,
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _createAccount
                                ? 'Already have an account? '
                                : 'New here? ',
                            style: Txt.caption.copyWith(fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _createAccount = !_createAccount),
                            child: Text(_createAccount ? 'Sign in' : 'Create account'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
