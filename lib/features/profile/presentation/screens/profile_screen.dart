import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthgenai/features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9), // Very light mint/gray background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header & Identity Card Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(context),
                Positioned(
                  bottom: -60,
                  left: 20,
                  right: 20,
                  child: _buildIdentityCard(),
                ),
              ],
            ),
            const SizedBox(height: 80), // Space for overlapping card

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsRow(),
            ),
            const SizedBox(height: 32),

            // Account Section
            _buildSectionTitle('ACCOUNT'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenuCard([
                _ProfileMenuItem(
                  icon: Icons.assignment_outlined,
                  iconBgColor: const Color(0xFFF0FDF4),
                  iconColor: const Color(0xFF10B981),
                  label: 'My Orders',
                  subtitle: 'Track & manage orders',
                  onTap: () => context.go('/orders'),
                ),
                _buildDivider(),
                _ProfileMenuItem(
                  icon: Icons.notifications_none_outlined,
                  iconBgColor: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Notifications',
                  subtitle: 'Alerts & preferences',
                  onTap: () => context.go('/profile/notifications'),
                ),
                _buildDivider(),
                _ProfileMenuItem(
                  icon: Icons.medication_liquid_rounded,
                  iconBgColor: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF059669),
                  label: 'Medicine Reminders',
                  subtitle: 'Schedule your doses',
                  onTap: () => context.go('/profile/reminders'),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // Security Section
            _buildSectionTitle('SECURITY'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenuCard([
                _ProfileMenuItem(
                  icon: Icons.shield_outlined,
                  iconBgColor: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF3B82F6),
                  label: 'Privacy & Security',
                  subtitle: 'Data & permissions',
                  onTap: () => _showComingSoon(context),
                ),
                _buildDivider(),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  iconBgColor: const Color(0xFFFEF2F2),
                  iconColor: const Color(0xFFEF4444),
                  label: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () => _showComingSoon(context),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle('SUPPORT'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMenuCard([
                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  iconBgColor: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'Help & Support',
                  subtitle: 'FAQs & contact us',
                  onTap: () => _showComingSoon(context),
                ),
              ]),
            ),

            const SizedBox(height: 32),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showLogoutDialog(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider, width: 0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Log Out',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Footer Version
            Text(
              'HealthGen AI v1.0',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF2EAA58),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Profile',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF2EAA58),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'ST',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shivam Tyagi',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'shivamtyagi8179@gmail.com',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                      const SizedBox(width: 6),
                      Text(
                        'Premium Member',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('12', 'ORDERS'),
        const SizedBox(width: 12),
        _buildStatItem('86%', 'HEALTH\nSCORE'),
        const SizedBox(width: 12),
        _buildStatItem('4', 'SAVED PLANS'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    // Check if it's the health score for special formatting
    final isHealthScore = label.contains('HEALTH');
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: Column(
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.baseline,
               textBaseline: TextBaseline.alphabetic,
               children: [
                 Text(
                   value.replaceAll('%', ''),
                   style: GoogleFonts.inter(
                     fontSize: 24,
                     fontWeight: FontWeight.w800,
                     color: AppColors.textPrimary,
                   ),
                 ),
                 if(isHealthScore) 
                  Text(
                    '%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
               ],
             ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textTertiary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.divider, indent: 70, endIndent: 20);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to log out from HealthGen AI?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(firebaseAuthProvider).signOut();
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'This feature is coming soon!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2EAA58),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD1D5DB),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
