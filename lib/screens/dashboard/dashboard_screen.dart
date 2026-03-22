import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import 'widgets/owner_dashboard.dart';
import 'widgets/kitchen_dashboard.dart';
import 'widgets/delivery_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserRole? _overrideRole; // For developer testing

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = _overrideRole ?? authProvider.userData?.role ?? UserRole.customer;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(role, authProvider.userData?.isDeveloper ?? false),
      body: _buildDashboard(role),
    );
  }

  PreferredSizeWidget _buildAppBar(UserRole role, bool isDev) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: Text(
        '${role.value.toUpperCase()}_CONSOLE',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
      actions: [
        if (isDev)
          IconButton(
            icon: const Icon(Icons.bug_report, color: AppTheme.primary),
            onPressed: _showRoleSwitcher,
          ),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(color: AppTheme.borderDark, height: 1),
      ),
    );
  }

  Widget _buildDashboard(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const OwnerDashboard();
      case UserRole.kitchen:
        return const KitchenDashboard();
      case UserRole.delivery:
        return const DeliveryDashboard();
      case UserRole.developer:
        return const OwnerDashboard(); // Developer sees all, defaults to owner
      case UserRole.customer:
      default:
        return const Center(
          child: MonoLabel('ACCESS_DENIED // CUSTOMER_ROLE'),
        );
    }
  }

  void _showRoleSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoLabel('DEV_TOOLS // SWITCH_ROLE'),
            const SizedBox(height: 16),
            ...UserRole.values.map((role) => ListTile(
              title: Text(role.value.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: Colors.white)),
              onTap: () {
                setState(() => _overrideRole = role);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
