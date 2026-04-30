import 'package:flutter/widgets.dart';
import 'package:kegel_master/features/onboarding/application/onboarding_gate.dart';

class OnboardingScope extends InheritedNotifier<OnboardingGate> {
  const OnboardingScope({
    super.key,
    required OnboardingGate gate,
    required super.child,
  }) : super(notifier: gate);

  static OnboardingGate of(BuildContext context) {
    final OnboardingScope? scope =
        context.dependOnInheritedWidgetOfExactType<OnboardingScope>();
    assert(scope != null, 'OnboardingScope not found');
    return scope!.notifier!;
  }
}
