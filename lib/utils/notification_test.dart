// lib/utils/notification_test.dart (optionnel pour tester)
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationTest {
  static Future<void> testNotification() async {
    final service = NotificationService();
    await service.initialize();

    // Tester une notification dans 10 secondes
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    await service.scheduleTaskReminder(
      0, // ID test
      'Test de notification',
      'Ceci est une notification de test',
      testTime,
    );
    debugPrint('Notification de test planifiée pour ${testTime.toLocal()}');
  }
}
