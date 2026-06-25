import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';

/// Resolves which [AnatomyTrack] content to show in Learn.
///
/// Explicit user choice wins over [suggestedAnatomyTrack] from **Gender identity**.
/// When both are null (e.g. non-binary with no saved preference), returns null so
/// the UI shows a chooser without silently defaulting.
AnatomyTrack? resolveEffectiveAnatomyTrack({
  required AnatomyTrack? suggestedAnatomyTrack,
  required AnatomyTrack? explicitAnatomyTrack,
}) {
  if (explicitAnatomyTrack != null) {
    return explicitAnatomyTrack;
  }
  return suggestedAnatomyTrack;
}
