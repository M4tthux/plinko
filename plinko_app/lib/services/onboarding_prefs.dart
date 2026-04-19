import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _kHasSeenTour = 'plinko_has_seen_tour';

  static Future<bool> hasSeenTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasSeenTour) ?? false;
  }

  static Future<void> markTourSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasSeenTour, true);
  }
}
