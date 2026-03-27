import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Where Am I?'**
  String get appName;

  /// No description provided for @missingPersons.
  ///
  /// In en, this message translates to:
  /// **'Missing Persons'**
  String get missingPersons;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or location...'**
  String get searchHint;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterTitle;

  /// No description provided for @filterSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get filterSex;

  /// No description provided for @filterAge.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get filterAge;

  /// No description provided for @filterNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get filterNationality;

  /// No description provided for @filterLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen after'**
  String get filterLastSeen;

  /// No description provided for @filterSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get filterSource;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filterApply;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filterClear;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sexUnknown;

  /// No description provided for @lastSeenLabel.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeenLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @nationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationalityLabel;

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexLabel;

  /// No description provided for @caseIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Case ID'**
  String get caseIdLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @detailFacts.
  ///
  /// In en, this message translates to:
  /// **'Case details'**
  String get detailFacts;

  /// No description provided for @detailContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get detailContacts;

  /// No description provided for @detailPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get detailPhotos;

  /// No description provided for @shareCase.
  ///
  /// In en, this message translates to:
  /// **'Share this case'**
  String get shareCase;

  /// No description provided for @reportCase.
  ///
  /// In en, this message translates to:
  /// **'Report a missing person'**
  String get reportCase;

  /// No description provided for @sosTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get sosTitle;

  /// No description provided for @sosCallEurope.
  ///
  /// In en, this message translates to:
  /// **'Call 112 (Europe)'**
  String get sosCallEurope;

  /// No description provided for @sosDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have information about a missing person or are in danger, call emergency services immediately.'**
  String get sosDescription;

  /// No description provided for @sosCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sosCancel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to report'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An account is required to report a missing person.'**
  String get loginSubtitle;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get loginEmail;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginCreateAccount;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get loginPasswordResetSent;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a missing person'**
  String get reportTitle;

  /// No description provided for @reportName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get reportName;

  /// No description provided for @reportDOB.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get reportDOB;

  /// No description provided for @reportLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen date'**
  String get reportLastSeen;

  /// No description provided for @reportLastLocation.
  ///
  /// In en, this message translates to:
  /// **'Last known location'**
  String get reportLastLocation;

  /// No description provided for @reportSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get reportSex;

  /// No description provided for @reportHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get reportHeight;

  /// No description provided for @reportNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get reportNationality;

  /// No description provided for @reportFacts.
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get reportFacts;

  /// No description provided for @reportFactsHint.
  ///
  /// In en, this message translates to:
  /// **'One detail per line'**
  String get reportFactsHint;

  /// No description provided for @reportPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get reportPhotos;

  /// No description provided for @reportPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 photos (tap to add)'**
  String get reportPhotosSubtitle;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @reportPendingNotice.
  ///
  /// In en, this message translates to:
  /// **'Your report will be reviewed before publication. Only share verified information.'**
  String get reportPendingNotice;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSuccess;

  /// No description provided for @reportSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your report is under review and will appear publicly once approved.'**
  String get reportSuccessBody;

  /// No description provided for @reportBackToCases.
  ///
  /// In en, this message translates to:
  /// **'Back to cases'**
  String get reportBackToCases;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Active case'**
  String get statusApproved;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @sourceInterpol.
  ///
  /// In en, this message translates to:
  /// **'INTERPOL'**
  String get sourceInterpol;

  /// No description provided for @sourceCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get sourceCommunity;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get settingsEmergency;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsDataSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get settingsDataSources;

  /// No description provided for @settingsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get settingsSignIn;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin — Pending cases'**
  String get adminTitle;

  /// No description provided for @adminAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get adminAllCaughtUp;

  /// No description provided for @adminNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending cases to review.'**
  String get adminNoPending;

  /// No description provided for @adminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve & publish'**
  String get adminApprove;

  /// No description provided for @adminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminReject;

  /// No description provided for @adminRejectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject case?'**
  String get adminRejectConfirmTitle;

  /// No description provided for @adminApproved.
  ///
  /// In en, this message translates to:
  /// **'Case approved and published.'**
  String get adminApproved;

  /// No description provided for @adminRejected.
  ///
  /// In en, this message translates to:
  /// **'Case rejected.'**
  String get adminRejected;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Try again later.'**
  String get errorServer;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @emptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'No cases found'**
  String get emptyListTitle;

  /// No description provided for @emptyListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters.'**
  String get emptyListSubtitle;

  /// No description provided for @caseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Case unavailable'**
  String get caseUnavailable;

  /// No description provided for @caseUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This case could not be loaded right now.'**
  String get caseUnavailableSubtitle;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(int age);

  /// No description provided for @cmHeight.
  ///
  /// In en, this message translates to:
  /// **'{cm} cm'**
  String cmHeight(int cm);

  /// No description provided for @casesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} cases found'**
  String casesFound(int count);
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
