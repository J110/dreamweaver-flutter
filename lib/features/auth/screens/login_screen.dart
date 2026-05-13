import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/auth_provider.dart';
import 'package:dreamweaver/features/auth/widgets/dream_text_field.dart';
import 'package:dreamweaver/features/auth/widgets/magic_button.dart';
import 'package:dreamweaver/routing/route_constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (mounted) {
      result.fold(
        (error) => setState(() => _errorMessage = error),
        (user) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${user.username}!'),
              backgroundColor: DreamTheme.primaryPurple,
              duration: const Duration(milliseconds: 1500),
            ),
          );
          context.go(Routes.home);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DreamTheme.deepNight,
              const Color(0xFF1a0f2e),
              const Color(0xFF2d1b4e),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Title
                Text(
                  'Welcome Back,\nDreamer',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: DreamTheme.moonGlow,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to continue your journey',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DreamTheme.starYellow.withOpacity(0.6),
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 48),
                // Username field
                DreamTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  prefixIcon: Icon(
                    Icons.star,
                    color: DreamTheme.starYellow,
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 20),
                // Password field
                DreamTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: !_passwordVisible,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: DreamTheme.primaryPurple,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    child: Icon(
                      _passwordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: DreamTheme.primaryPurple,
                    ),
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 8),
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade300,
                          ),
                    ),
                  ),
                const SizedBox(height: 40),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: MagicButton(
                    onPressed: _handleLogin,
                    text: 'Enter the Dream World',
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(height: 24),
                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: isLoading
                        ? null
                        : () => context.push(Routes.signup),
                    child: RichText(
                      text: TextSpan(
                        text: 'New here? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: DreamTheme.starYellow.withOpacity(0.7),
                            ),
                        children: [
                          TextSpan(
                            text: 'Create an account',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: DreamTheme.primaryPink,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
