import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamweaver/config/theme.dart';
import 'package:dreamweaver/providers/auth_provider.dart';
import 'package:dreamweaver/features/auth/widgets/dream_text_field.dart';
import 'package:dreamweaver/features/auth/widgets/magic_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() => _errorMessage = null);

    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return false;
    }

    if (_usernameController.text.length < 3 ||
        _usernameController.text.length > 20) {
      setState(() =>
          _errorMessage = 'Username must be between 3 and 20 characters');
      return false;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return false;
    }

    return true;
  }

  Future<void> _handleSignup() async {
    if (!_validateInputs()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.signup(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (mounted) {
      result.fold(
        (error) => setState(() => _errorMessage = error),
        (user) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account created! Now tell us about your little one.'),
              backgroundColor: DreamTheme.primaryPurple,
              duration: const Duration(milliseconds: 1500),
            ),
          );
          Navigator.of(context).pushNamed('/age-setup');
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
                // Back button
                GestureDetector(
                  onTap: isLoading ? null : () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: DreamTheme.moonGlow,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'Begin Your\nDream Journey',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: DreamTheme.moonGlow,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to start your adventure',
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
                    Icons.person_outline,
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
                const SizedBox(height: 20),
                // Confirm password field
                DreamTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: !_confirmPasswordVisible,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: DreamTheme.primaryPink,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                        () => _confirmPasswordVisible = !_confirmPasswordVisible),
                    child: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: DreamTheme.primaryPink,
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
                // Signup button
                SizedBox(
                  width: double.infinity,
                  child: MagicButton(
                    onPressed: _handleSignup,
                    text: 'Next: Tell us about your little one',
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(height: 24),
                // Login link
                Center(
                  child: GestureDetector(
                    onTap: isLoading
                        ? null
                        : () => Navigator.of(context).pushReplacementNamed('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: DreamTheme.starYellow.withOpacity(0.7),
                            ),
                        children: [
                          TextSpan(
                            text: 'Login',
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
