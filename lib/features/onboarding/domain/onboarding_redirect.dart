import 'package:kegel_master/features/onboarding/domain/onboarding_snapshot.dart';

String? resolveOnboardingRedirect({
  required String path,
  required OnboardingSnapshot snapshot,
}) {
  if (path == '/') {
    if (!snapshot.onboardingComplete) {
      return '/onboarding';
    }
    if (snapshot.catheterActive) {
      return '/learn';
    }
    return '/home';
  }

  if (!snapshot.onboardingComplete) {
    if (path == '/onboarding') {
      return null;
    }
    return '/onboarding';
  }

  if (snapshot.catheterActive) {
    const allowed = <String>{'/learn', '/settings', '/onboarding'};
    if (allowed.contains(path)) {
      return null;
    }
    if (path == '/home' || path == '/progress' || path == '/session') {
      return '/learn';
    }
    return '/learn';
  }

  return null;
}
