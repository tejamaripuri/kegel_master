import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @learnAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnAppBarTitle;

  /// No description provided for @learnShellDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This area is educational wellness information. It is not medical advice and not a substitute for care from a qualified clinician.'**
  String get learnShellDisclaimer;

  /// No description provided for @learnCatheterBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Pelvic floor exercises are suspended while you use a catheter. Educational content only — follow your care team.'**
  String get learnCatheterBannerBody;

  /// No description provided for @learnFoundationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation'**
  String get learnFoundationSectionTitle;

  /// No description provided for @learnFoundationWhatPelvicFloorTitle.
  ///
  /// In en, this message translates to:
  /// **'What the pelvic floor does'**
  String get learnFoundationWhatPelvicFloorTitle;

  /// No description provided for @learnFoundationWhatPelvicFloorBody.
  ///
  /// In en, this message translates to:
  /// **'These muscles help support your organs and play a role in bladder and bowel control. People notice them most when coughing, laughing, lifting, or rushing to the bathroom.'**
  String get learnFoundationWhatPelvicFloorBody;

  /// No description provided for @learnFoundationCoordinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Coordination matters as much as strength'**
  String get learnFoundationCoordinationTitle;

  /// No description provided for @learnFoundationCoordinationBody.
  ///
  /// In en, this message translates to:
  /// **'Healthy control is often about timing and relaxation, not only squeezing harder. If everything feels tight or braced all day, gentle down-training and pacing can be more helpful than adding more force.'**
  String get learnFoundationCoordinationBody;

  /// No description provided for @learnFoundationProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress is uneven for most people'**
  String get learnFoundationProgressTitle;

  /// No description provided for @learnFoundationProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Some weeks feel easier and some feel messy. That pattern is common. Use how you feel as a guide, and pause or simplify when symptoms flare rather than pushing through.'**
  String get learnFoundationProgressBody;

  /// No description provided for @learnFoundationCareTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay aligned with your care team'**
  String get learnFoundationCareTeamTitle;

  /// No description provided for @learnFoundationCareTeamBody.
  ///
  /// In en, this message translates to:
  /// **'Bring questions about pain, new symptoms, or catheter changes to the clinician who knows your situation. This app supports habit building; it does not replace individualized guidance.'**
  String get learnFoundationCareTeamBody;

  /// No description provided for @learnAnatomySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Anatomy track'**
  String get learnAnatomySectionTitle;

  /// No description provided for @learnAnatomySectionIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose the pelvic cues that fit your body. This is about structure and typical clinical patterns — not who you are.'**
  String get learnAnatomySectionIntro;

  /// No description provided for @learnAnatomyTrackMaleTypicalLabel.
  ///
  /// In en, this message translates to:
  /// **'Male-typical pelvic cues'**
  String get learnAnatomyTrackMaleTypicalLabel;

  /// No description provided for @learnAnatomyTrackFemaleTypicalLabel.
  ///
  /// In en, this message translates to:
  /// **'Female-typical pelvic cues'**
  String get learnAnatomyTrackFemaleTypicalLabel;

  /// No description provided for @learnAnatomyPromptSelectTrack.
  ///
  /// In en, this message translates to:
  /// **'Pick the anatomy track that matches the pelvic cues you want to work with.'**
  String get learnAnatomyPromptSelectTrack;

  /// No description provided for @learnAnatomyMaleTypicalBody.
  ///
  /// In en, this message translates to:
  /// **'For male-typical pelvic anatomy, focus on lifting around the base of the penis and the area between the scrotum and anus. A gentle squeeze should feel like you are drawing upward without gripping the belly or thighs. Release fully between reps so the muscles do not stay braced.'**
  String get learnAnatomyMaleTypicalBody;

  /// No description provided for @learnAnatomyFemaleTypicalBody.
  ///
  /// In en, this message translates to:
  /// **'For female-typical pelvic anatomy, focus on a lift around the vaginal opening and the area toward the anus. Imagine picking up a marble without squeezing the buttocks or inner thighs. Let the muscles soften completely between reps.'**
  String get learnAnatomyFemaleTypicalBody;

  /// No description provided for @learnAnatomyPrivacyExpansionTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional: tactile check'**
  String get learnAnatomyPrivacyExpansionTitle;

  /// No description provided for @learnAnatomyMaleTypicalPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'With clean hands, you can lightly press the perineum (between scrotum and anus) while you contract. You should feel a subtle lift, not a hard brace. Stop if you feel pain.'**
  String get learnAnatomyMaleTypicalPrivacyBody;

  /// No description provided for @learnAnatomyFemaleTypicalPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'With clean hands, you can place one finger at the vaginal opening while you contract. You should feel a gentle inward lift, not a painful squeeze. Stop if you feel pain.'**
  String get learnAnatomyFemaleTypicalPrivacyBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
