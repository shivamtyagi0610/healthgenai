import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';

class MedicineReminder {
  final String id;
  final String name;
  final String dosage;
  final TimeOfDay time;
  final bool isEnabled;

  MedicineReminder({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'hour': time.hour,
    'minute': time.minute,
    'isEnabled': isEnabled,
  };

  factory MedicineReminder.fromJson(Map<String, dynamic> json) => MedicineReminder(
    id: json['id'],
    name: json['name'],
    dosage: json['dosage'],
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    isEnabled: json['isEnabled'],
  );

  MedicineReminder copyWith({bool? isEnabled}) {
    return MedicineReminder(
      id: id,
      name: name,
      dosage: dosage,
      time: time,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, List<MedicineReminder>>((ref) {
  return ReminderNotifier();
});

class ReminderNotifier extends StateNotifier<List<MedicineReminder>> {
  ReminderNotifier() : super([]) {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('medicine_reminders');
    if (data != null) {
      final List decoded = jsonDecode(data);
      state = decoded.map((e) => MedicineReminder.fromJson(e)).toList();
    }
  }

  Future<void> addReminder(MedicineReminder reminder) async {
    state = [...state, reminder];
    await _saveAndSchedule();
  }

  Future<void> toggleReminder(String id) async {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isEnabled: !r.isEnabled) else r
    ];
    await _saveAndSchedule();
  }

  Future<void> deleteReminder(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _saveAndSchedule();
  }

  Future<void> _saveAndSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medicine_reminders', jsonEncode(state.map((r) => r.toJson()).toList()));
    
    // Clear all and reschedule enabled ones
    final service = NotificationService();
    await service.cancelAll();
    
    for (final r in state) {
      if (r.isEnabled) {
        await service.scheduleDailyReminder(
          id: r.id.hashCode,
          title: 'Time for your medicine: ${r.name}',
          body: 'Dosage: ${r.dosage}',
          hour: r.time.hour,
          minute: r.time.minute,
        );
      }
    }
  }
}
