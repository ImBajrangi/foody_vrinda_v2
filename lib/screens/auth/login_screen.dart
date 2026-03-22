import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../../config/app_theme.dart';
import '../../config/lottie_assets.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/industrial_widgets.dart';
import '../../config/app_config.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    
    // Hide keyboard
    FocusScope.of(context).unfocus();

    bool success = await auth.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Smart Dev Login: Auto-create if it's the master dev email but account doesn't exist
    if (!success &&
        (auth.lastErrorCode == 'user-not-found' ||
            auth.lastErrorCode == 'invalid-credential') &&
        _emailController.text.trim() == AppConfig.developerEmail &&
        _passwordController.text == AppConfig.developerPassword) {
      debugPrint('LoginScreen: Developer account missing. Auto-creating...');
      success = await auth.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: MonoLabel(auth.error ?? 'LOGIN FAILED', color: Colors.white),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 48),
                _buildLoginForm(auth),
                const SizedBox(height: 24),
                _buildSocialLogin(auth),
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
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primary, width: 2),
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CachedNetworkImage(
              imageUrl: 'https://imbajrangi.github.io/Company/Vrindopnishad%20Web/class/logo/foodyVrinda-logo.png',
              fit: BoxFit.contain,
              errorWidget: (context, url, e) => const Icon(Icons.restaurant, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AUTHENTICATE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const MonoLabel('ACCESS_PORT // SECURE_GATEWAY'),
      ],
    );
  }

  Widget _buildLoginForm(AuthProvider auth) {
    return HardShadowCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonoLabel('EMAIL_IDENTITY'),
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
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => v!.length < 6 ? 'CIPHER_TOO_SHORT' : null,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'INITIALIZE_SESSION',
            isLoading: auth.isLoading,
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin(AuthProvider auth) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppTheme.borderDark)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'SYSTEM_OVERRIDE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppTheme.borderDark)),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: auth.isLoading ? null : () => auth.signInWithGoogle(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.borderDark),
              boxShadow: const [AppTheme.hardShadow],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.g_mobiledata, color: AppTheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'CONTINUE_WITH_GOOGLE',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => auth.signInAnonymously(),
          child: const MonoLabel('BYPASS_CORE // GUEST_ACCESS'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'NEW_OPERATOR?',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignupScreen()),
          ),
          child: Text(
            'REGISTER_IDENTITY',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
