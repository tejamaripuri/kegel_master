import 'package:flutter_test/flutter_test.dart';
import 'package:kegel_master/features/learn/domain/learn_effective_anatomy_track.dart';
import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';

void main() {
  group('resolveEffectiveAnatomyTrack', () {
    test('uses suggested track when no explicit preference', () {
      expect(
        resolveEffectiveAnatomyTrack(
          suggestedAnatomyTrack: AnatomyTrack.maleTypical,
          explicitAnatomyTrack: null,
        ),
        AnatomyTrack.maleTypical,
      );
      expect(
        resolveEffectiveAnatomyTrack(
          suggestedAnatomyTrack: AnatomyTrack.femaleTypical,
          explicitAnatomyTrack: null,
        ),
        AnatomyTrack.femaleTypical,
      );
    });

    test('explicit preference overrides suggested track', () {
      expect(
        resolveEffectiveAnatomyTrack(
          suggestedAnatomyTrack: AnatomyTrack.maleTypical,
          explicitAnatomyTrack: AnatomyTrack.femaleTypical,
        ),
        AnatomyTrack.femaleTypical,
      );
      expect(
        resolveEffectiveAnatomyTrack(
          suggestedAnatomyTrack: AnatomyTrack.femaleTypical,
          explicitAnatomyTrack: AnatomyTrack.maleTypical,
        ),
        AnatomyTrack.maleTypical,
      );
    });

    test('non-binary with no explicit preference stays unset', () {
      expect(
        resolveEffectiveAnatomyTrack(
          suggestedAnatomyTrack: null,
          explicitAnatomyTrack: null,
        ),
        isNull,
      );
    });

    test('non-binary with explicit preference uses saved track', () {
      expect(
        resolveEffectiveAnatomyTrack(
          suggestedAnatomyTrack: null,
          explicitAnatomyTrack: AnatomyTrack.femaleTypical,
        ),
        AnatomyTrack.femaleTypical,
      );
    });
  });
}
