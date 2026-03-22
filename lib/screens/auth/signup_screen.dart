import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/industrial_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: MonoLabel('CIPHER_MISMATCH', color: Colors.white),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    FocusScope.of(context).unfocus();

    final success = await auth.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pop(context); // Go back to login or it will auto-navigate via wrapper
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: MonoLabel(auth.error ?? 'SIGNUP FAILED', color: Colors.white),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSignupForm(auth),
                const SizedBox(height: 32),
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
      children: [
        Text(
          'REGISTER',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const MonoLabel('NEW_IDENTITY_CREATION // SECURE_PORT'),
      ],
    );
  }

  Widget _buildSignupForm(AuthProvider auth) {
    return HardShadowCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonoLabel('GLOBAL_IDENTITY_EMAIL'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'USER@DOMAIN.COM',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v!.isEmpty ? 'IDENTITY REQUIRED' : null,
          ),
          const SizedBox(height: 20),
          const MonoLabel('ACCESS_CIPHER'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 14),
            obscureText: _obscurePassword,
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline, size: 18),
            ),
            validator: (v) => v!.length < 6 ? 'CIPHER_TOO_SHORT' : null,
          ),
          const SizedBox(height: 20),
          const MonoLabel('CONFIRM_CIPHER'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmController,
            style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 14),
            obscureText: _obscurePassword,
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.security, size: 18),
            ),
            validator: (v) => v!.isEmpty ? 'CONFIRMATION REQUIRED' : null,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'GENERATE_IDENTITY',
            isLoading: auth.isLoading,
            onPressed: _handleSignup,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'BY_REGISTERING_YOU_AGREE_TO_OUR',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'TERMS_OF_SERVICE // PRIVACY_PROTOCOL',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
