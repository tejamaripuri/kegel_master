// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get learnAppBarTitle => 'Learn';

  @override
  String get learnShellDisclaimer =>
      'This area is educational wellness information. It is not medical advice and not a substitute for care from a qualified clinician.';

  @override
  String get learnCatheterBannerBody =>
      'Pelvic floor exercises are suspended while you use a catheter. Educational content only — follow your care team.';

  @override
  String get learnFoundationSectionTitle => 'Foundation';

  @override
  String get learnFoundationWhatPelvicFloorTitle =>
      'What the pelvic floor does';

  @override
  String get learnFoundationWhatPelvicFloorBody =>
      'These muscles help support your organs and play a role in bladder and bowel control. People notice them most when coughing, laughing, lifting, or rushing to the bathroom.';

  @override
  String get learnFoundationCoordinationTitle =>
      'Coordination matters as much as strength';

  @override
  String get learnFoundationCoordinationBody =>
      'Healthy control is often about timing and relaxation, not only squeezing harder. If everything feels tight or braced all day, gentle down-training and pacing can be more helpful than adding more force.';

  @override
  String get learnFoundationProgressTitle =>
      'Progress is uneven for most people';

  @override
  String get learnFoundationProgressBody =>
      'Some weeks feel easier and some feel messy. That pattern is common. Use how you feel as a guide, and pause or simplify when symptoms flare rather than pushing through.';

  @override
  String get learnFoundationCareTeamTitle => 'Stay aligned with your care team';

  @override
  String get learnFoundationCareTeamBody =>
      'Bring questions about pain, new symptoms, or catheter changes to the clinician who knows your situation. This app supports habit building; it does not replace individualized guidance.';

  @override
  String get learnAnatomySectionTitle => 'Anatomy track';

  @override
  String get learnAnatomySectionIntro =>
      'Choose the pelvic cues that fit your body. This is about structure and typical clinical patterns — not who you are.';

  @override
  String get learnAnatomyTrackMaleTypicalLabel => 'Male-typical pelvic cues';

  @override
  String get learnAnatomyTrackFemaleTypicalLabel =>
      'Female-typical pelvic cues';

  @override
  String get learnAnatomyPromptSelectTrack =>
      'Pick the anatomy track that matches the pelvic cues you want to work with.';

  @override
  String get learnAnatomyMaleTypicalBody =>
      'For male-typical pelvic anatomy, focus on lifting around the base of the penis and the area between the scrotum and anus. A gentle squeeze should feel like you are drawing upward without gripping the belly or thighs. Release fully between reps so the muscles do not stay braced.';

  @override
  String get learnAnatomyFemaleTypicalBody =>
      'For female-typical pelvic anatomy, focus on a lift around the vaginal opening and the area toward the anus. Imagine picking up a marble without squeezing the buttocks or inner thighs. Let the muscles soften completely between reps.';

  @override
  String get learnAnatomyPrivacyExpansionTitle => 'Optional: tactile check';

  @override
  String get learnAnatomyMaleTypicalPrivacyBody =>
      'With clean hands, you can lightly press the perineum (between scrotum and anus) while you contract. You should feel a subtle lift, not a hard brace. Stop if you feel pain.';

  @override
  String get learnAnatomyFemaleTypicalPrivacyBody =>
      'With clean hands, you can place one finger at the vaginal opening while you contract. You should feel a gentle inward lift, not a painful squeeze. Stop if you feel pain.';
}
