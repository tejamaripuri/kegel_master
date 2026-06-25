import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegel_master/core/services/shared_preferences_provider.dart';
import 'package:kegel_master/features/learn/domain/learn_profile_signals.dart';

const String learnAnatomyTrackPreferenceKey = 'learn_anatomy_track';

class LearnAnatomyTrackController extends Notifier<AnatomyTrack?> {
  @override
  AnatomyTrack? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final String? stored = prefs.getString(learnAnatomyTrackPreferenceKey);
    if (stored == null) {
      return null;
    }
    return AnatomyTrack.values.byName(stored);
  }

  void setTrack(AnatomyTrack track) {
    state = track;
    ref.read(sharedPreferencesProvider).setString(
          learnAnatomyTrackPreferenceKey,
          track.name,
        );
  }
}

final learnAnatomyTrackControllerProvider =
    NotifierProvider<LearnAnatomyTrackController, AnatomyTrack?>(() {
  return LearnAnatomyTrackController();
});
