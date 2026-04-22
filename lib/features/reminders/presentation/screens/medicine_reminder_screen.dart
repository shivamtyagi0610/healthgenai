import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/reminder_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_colors.dart';

class MedicineReminderScreen extends ConsumerWidget {
  const MedicineReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Medicine Reminders',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add_rounded, color: Color(0xFF3BBD70)),
            onPressed: () => NotificationService().showTestNotification(),
            tooltip: 'Send Test Alert',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reminders.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(context, ref, reminder);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderSheet(context, ref),
        backgroundColor: const Color(0xFF3BBD70),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Reminder',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medication_liquid_rounded, size: 64, color: const Color(0xFF3BBD70)),
          ),
          const SizedBox(height: 24),
          Text(
            'No reminders set',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Schedule your medications and we will notify you on time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, MedicineReminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.medication_rounded, color: Color(0xFF3BBD70), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${reminder.dosage} · ${reminder.time.format(context)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: reminder.isEnabled,
            activeTrackColor: const Color(0xFF3BBD70),
            onChanged: (_) => ref.read(reminderProvider.notifier).toggleReminder(reminder.id),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => ref.read(reminderProvider.notifier).deleteReminder(reminder.id),
          ),
        ],
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24, left: 24, right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Medication Reminder',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g. Aspirin',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medication_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g. 1 Tablet after meal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Time:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                    icon: const Icon(Icons.access_time_rounded, color: Color(0xFF3BBD70)),
                    label: Text(
                      selectedTime.format(context),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3BBD70),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      ref.read(reminderProvider.notifier).addReminder(
                        MedicineReminder(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          dosage: dosageController.text,
                          time: selectedTime,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3BBD70),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Set Reminder',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
