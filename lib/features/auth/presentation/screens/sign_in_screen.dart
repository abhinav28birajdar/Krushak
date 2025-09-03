import 'package:flutter/material.dart';

/// Sign In Screen
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E523A), Color(0xFF35906A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Header
                _buildHeader(),
                const SizedBox(height: 48),
                // Sign In Form
                _buildSignInForm(),
                const SizedBox(height: 32),
                // Sign In Button
                _buildSignInButton(),
                const SizedBox(height: 24),
                // Alternative Sign In
                _buildAlternativeSignIn(),
                const SizedBox(height: 32),
                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue farming with Krushak',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email or Phone',
              hintText: 'Enter your email or phone number',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or phone';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to forgot password
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E523A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildAlternativeSignIn() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
          ],
        ),
        const SizedBox(height: 24),
        // Phone Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Handle phone sign in
            },
            icon: const Icon(Icons.phone),
            label: const Text('Continue with Phone'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/sign-up');
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate sign in
        await Future.delayed(const Duration(seconds: 2));

        // Navigate to home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign in failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
