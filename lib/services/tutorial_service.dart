import 'package:shared_preferences/shared_preferences.dart';

const String chronosTutorialSeenKey = 'chronos_tutorial_seen';

class TutorialService {
  const TutorialService._();

  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(chronosTutorialSeenKey);
    return seen == null || seen == false;
  }

  static Future<void> markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(chronosTutorialSeenKey, true);
  }

  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chronosTutorialSeenKey);
  }
}
