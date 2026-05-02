import 'package:flutter/widgets.dart';
import 'package:kegel_master/features/progress/application/session_history_store.dart';
import 'package:kegel_master/features/progress/application/user_preferences_store.dart';

class ProgressScope extends InheritedWidget {
  const ProgressScope({
    super.key,
    required this.sessionHistory,
    required this.userPreferences,
    required super.child,
  });

  final SessionHistoryStore sessionHistory;
  final UserPreferencesStore userPreferences;

  static ProgressScope of(BuildContext context) {
    final ProgressScope? scope =
        context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(ProgressScope oldWidget) {
    return sessionHistory != oldWidget.sessionHistory ||
        userPreferences != oldWidget.userPreferences;
  }
}
