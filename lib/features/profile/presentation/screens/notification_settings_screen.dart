import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/app_colors.dart';

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, Map<String, bool>>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<Map<String, bool>> {
  NotificationSettingsNotifier() : super({
    'medicine_alerts': true,
    'health_tips': true,
    'order_updates': true,
    'email_notify': false,
  }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = {
      'medicine_alerts': prefs.getBool('medicine_alerts') ?? true,
      'health_tips': prefs.getBool('health_tips') ?? true,
      'order_updates': prefs.getBool('order_updates') ?? true,
      'email_notify': prefs.getBool('email_notify') ?? false,
    };
  }

  Future<void> toggleSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !(state[key] ?? false);
    await prefs.setBool(key, newValue);
    state = {...state, key: newValue};
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notification Settings',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader('Alert Preferences', 'Control how you receive health updates'),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildToggleItem(
              context,
              ref,
              'Medicine Alerts',
              'Reminders for your scheduled medications',
              Icons.medication_outlined,
              'medicine_alerts',
              settings['medicine_alerts']!,
            ),
            _buildDivider(),
            _buildToggleItem(
              context,
              ref,
              'Daily AI Health Tips',
              'Personalized wellness insights from Gemini',
              Icons.auto_awesome_outlined,
              'health_tips',
              settings['health_tips']!,
            ),
            _buildDivider(),
            _buildToggleItem(
              context,
              ref,
              'Order Updates',
              'Stay notified about your medicine deliveries',
              Icons.local_shipping_outlined,
              'order_updates',
              settings['order_updates']!,
            ),
          ]),
          const SizedBox(height: 32),
          _buildHeader('Channel Preferences', 'Choose your preferred contact methods'),
          const SizedBox(height: 16),
          _buildSettingsCard([
             _buildToggleItem(
              context,
              ref,
              'Email Notifications',
              'Weekly health summaries and reports',
              Icons.mail_outline_rounded,
              'email_notify',
              settings['email_notify']!,
            ),
          ]),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Manage and view your health notifications in real-time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    IconData icon,
    String key,
    bool value,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3BBD70), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF3BBD70),
            onChanged: (_) => ref.read(notificationSettingsProvider.notifier).toggleSetting(key),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFFF3F4F6),
      indent: 60,
      endIndent: 16,
    );
  }
}
