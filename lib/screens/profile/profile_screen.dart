import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderDark),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primary, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'MR. BAJRANGI',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const MonoLabel('BAJRANGI_DEV // MODE_ACTIVE'),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatRow(),
                const SizedBox(height: 24),
                _profileOption(Icons.terminal, 'MY_ACCOUNT'),
                _profileOption(Icons.history, 'ORDER_HISTORY'),
                _profileOption(Icons.wallet, 'WALLET_BALANCE'),
                _profileOption(Icons.settings, 'SYSTEM_CONFIG'),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'DISCONNECT_SESSION',
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return HardShadowCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('ORDERS', '128'),
          Container(width: 1, height: 30, color: AppTheme.borderDark),
          _stat('XP', '4.2k'),
          Container(width: 1, height: 30, color: AppTheme.borderDark),
          _stat('RANK', '#04'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
        MonoLabel(label),
      ],
    );
  }

  Widget _profileOption(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 20),
        title: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.borderDark),
        onTap: () {},
      ),
    );
  }
}
