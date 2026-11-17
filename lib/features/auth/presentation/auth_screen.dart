import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/brand.dart';
import '../data/models/auth_models.dart';
import 'auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.login});
  final bool login;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool login = widget.login;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final dob = TextEditingController();
  final gender = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    dob.dispose();
    gender.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (previous?.isLoading != true) return;
      if (next.hasError) {
        _showMessage(next.error.toString(), Colors.red);
        return;
      }
      if (!next.hasValue) return;
      if (login) {
        _showMessage('Login successful', Colors.green);
        context.go('/home');
      } else {
        setState(() => login = true);
        _showMessage('Welcome Onboard. Please sign in.', Colors.green);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Brand(),
                    const SizedBox(height: 42),
                    Text(
                      login ? 'Welcome back' : 'Create your account',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      login
                          ? 'Sign in to pick up where you left off.'
                          : 'Start managing your clouds in one place.',
                    ),
                    const SizedBox(height: 28),
                    if (!login) ...[
                      _field(firstName, 'First name', Icons.person_outline),
                      _gap,
                      _field(lastName, 'Last name', Icons.person_outline),
                      _gap,
                      _field(
                        phone,
                        'Phone',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _gap,
                      TextFormField(
                        controller: dob,
                        readOnly: true,
                        onTap: _selectDob,
                        validator: (value) => _required(value, 'Date of birth'),
                        decoration: const InputDecoration(
                          labelText: 'Date of birth (YYYY-MM-DD)',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      _gap,
                      _field(gender, 'Gender', Icons.wc_outlined),
                      _gap,
                    ],
                    TextFormField(
                      controller: username,
                      keyboardType: login
                          ? TextInputType.text
                          : TextInputType.emailAddress,
                      validator: login
                          ? (value) => _required(value, 'Username')
                          : _emailValidator,
                      decoration: InputDecoration(
                        labelText: login
                            ? 'Email or phone number'
                            : 'Email address',
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                    ),
                    if (!login) ...[
                      _gap,
                      TextFormField(
                        controller: confirmPassword,
                        obscureText: !confirmPasswordVisible,
                        validator: (value) {
                          final error = _required(value, 'Confirm password');
                          if (error != null) return error;
                          return value == password.text
                              ? null
                              : 'Passwords do not match';
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            tooltip: confirmPasswordVisible
                                ? 'Hide password'
                                : 'Show password',
                            icon: Icon(
                              confirmPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => confirmPasswordVisible =
                                  !confirmPasswordVisible,
                            ),
                          ),
                        ),
                      ),
                    ],
                    _gap,
                    TextFormField(
                      controller: password,
                      obscureText: !passwordVisible,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) => _required(value, 'Password'),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: passwordVisible
                              ? 'Hide password'
                              : 'Show password',
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => passwordVisible = !passwordVisible,
                          ),
                        ),
                      ),
                    ),
                    if (login)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: authState.isLoading ? null : _submit,
                        child: Text(login ? 'Sign in' : 'Create account'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => login = !login),
                        child: Text(
                          login
                              ? 'New to My Drive? Create an account'
                              : 'Already have an account? Sign in',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _gap = SizedBox(height: 14);

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => _required(value, label),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Future<void> _submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (login) {
      await ref
          .read(authControllerProvider.notifier)
          .login(username.text.trim(), password.text);
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .register(
          RegisterRequest(
            firstName: firstName.text.trim(),
            lastName: lastName.text.trim(),
            password: password.text,
            dob: dob.text.trim(),
            gender: gender.text.trim(),
            email: username.text.trim(),
            phone: phone.text.trim(),
            confirmPassword: confirmPassword.text,
          ),
        );
  }

  Future<void> _selectDob() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Select your date of birth',
    );
    if (selected == null) return;
    dob.text =
        '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    setState(() {});
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;

  String? _emailValidator(String? value) {
    final error = _required(value, 'Email');
    if (error != null) return error;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address';
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
