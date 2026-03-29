// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Where Am I?';

  @override
  String get missingPersons => 'Missing Persons';

  @override
  String get searchHint => 'Search by name or location...';

  @override
  String casesFound(int count) {
    return '$count cases found';
  }

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterSex => 'Sex';

  @override
  String get filterAge => 'Age range';

  @override
  String get filterNationality => 'Nationality';

  @override
  String get filterLastSeen => 'Last seen after';

  @override
  String get filterSource => 'Source';

  @override
  String get filterApply => 'Apply filters';

  @override
  String get filterClear => 'Clear all';

  @override
  String get filterAll => 'All';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortNameAZ => 'Name A–Z';

  @override
  String get sortNameZA => 'Name Z–A';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexUnknown => 'Unknown';

  @override
  String get lastSeenLabel => 'Last seen';

  @override
  String get disappearedLabel => 'Disappeared';

  @override
  String get ageLabel => 'Age';

  @override
  String yearsOld(int age) {
    return '$age years old';
  }

  @override
  String whenYearsOld(int age) {
    return 'When $age years old';
  }

  @override
  String get heightLabel => 'Height';

  @override
  String cmHeight(int cm) {
    return '$cm cm';
  }

  @override
  String get weightLabel => 'Weight';

  @override
  String kgWeight(int kg) {
    return '$kg kg';
  }

  @override
  String get nationalityLabel => 'Nationality';

  @override
  String get sexLabel => 'Sex';

  @override
  String get genderLabel => 'Gender';

  @override
  String get caseIdLabel => 'Case ID';

  @override
  String get sourceLabel => 'Source';

  @override
  String get locationUnknown => 'Location unknown';

  @override
  String get detailFamilyName => 'Family name';

  @override
  String get detailForename => 'Forename';

  @override
  String get detailGender => 'Gender';

  @override
  String get detailDOB => 'Date of birth';

  @override
  String get detailNationality => 'Nationality';

  @override
  String get detailPlaceDisapp => 'Place of disappearance';

  @override
  String get detailDateDisapp => 'Date of disappearance';

  @override
  String get detailHeight => 'Height';

  @override
  String get detailWeight => 'Weight';

  @override
  String get detailEyeColour => 'Eye colour';

  @override
  String get detailHairColour => 'Hair colour';

  @override
  String get detailFamilyNameAtBirth => 'Family name at birth';

  @override
  String get detailFacts => 'Case details';

  @override
  String get detailContacts => 'Contacts';

  @override
  String get detailPhotos => 'Photos';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get couldNotOpenLink => 'Could not open link.';

  @override
  String get viewOnInterpol => 'View on INTERPOL';

  @override
  String get shareCase => 'Share this case';

  @override
  String get reportCase => 'Report a missing person';

  @override
  String missingPersonShareText(String name, String location) {
    return '🔴 MISSING PERSON\n\n$name\nPlace of disappearance: $location\n\nIf you have any information, contact the authorities.';
  }

  @override
  String get sosTitle => 'Emergency';

  @override
  String get sosCallEurope => 'SOS — Call 112 (Europe)';

  @override
  String get sosDescription =>
      'If you have information about a missing person or are in danger, call emergency services immediately.';

  @override
  String get sosCancel => 'Cancel';

  @override
  String get loginTitle => 'Sign in to report';

  @override
  String get loginSubtitle =>
      'An account is required to report a missing person.';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginEmail => 'Continue with Email';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginPasswordResetSent => 'Password reset email sent.';

  @override
  String get loginEmailConfirmation =>
      'Account created! Check your email to confirm before signing in.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginNameLabel => 'Full name';

  @override
  String get loginNameHint => 'Maria Silva';

  @override
  String get loginEmailHint => 'your@email.com';

  @override
  String get loginPasswordHint => 'Minimum 6 characters';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginHasAccount => 'Already have an account?';

  @override
  String get loginSignUp => 'Sign up';

  @override
  String get reportTitle => 'Report a missing person';

  @override
  String get reportPendingBadge => 'Pending review';

  @override
  String get reportPendingNotice =>
      'Your report will be reviewed before it appears publicly. Only share verified information.';

  @override
  String get reportName => 'Full name *';

  @override
  String get reportNameHint => 'e.g. Maria da Silva';

  @override
  String get reportNameError => 'Name must be at least 2 characters';

  @override
  String get reportNationality => 'Nationality';

  @override
  String get reportNationalitySubtitle => 'ISO code, e.g. BR, PT, AO';

  @override
  String get reportNationalityHint => 'BR';

  @override
  String get reportSex => 'Sex';

  @override
  String get reportDOB => 'Date of birth';

  @override
  String get reportLastSeen => 'Date of disappearance *';

  @override
  String get reportLastSeenError => 'Please select the disappearance date';

  @override
  String get reportLastLocation => 'Place of disappearance *';

  @override
  String get reportLastLocationHint => 'e.g. Lisbon, Portugal';

  @override
  String get reportLastLocationError => 'Please enter a location';

  @override
  String get reportHeight => 'Height (cm)';

  @override
  String get reportHeightHint => '170';

  @override
  String get reportEyeColor => 'Eye colour';

  @override
  String get reportEyeColorHint => 'e.g. Brown, Blue, Green';

  @override
  String get reportHairColor => 'Hair colour';

  @override
  String get reportHairColorHint => 'e.g. Black, Blonde, Brown';

  @override
  String get reportFacts => 'Additional details';

  @override
  String get reportFactsHint => 'One detail per line';

  @override
  String get reportPhotos => 'Photos';

  @override
  String get reportPhotosSubtitle => 'Up to 5 photos (tap to add)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSubmitting => 'Submitting...';

  @override
  String get reportSuccess => 'Report submitted';

  @override
  String get reportSuccessBody =>
      'Thank you. Your report is under review and will appear publicly once approved.';

  @override
  String get reportBackToCases => 'Back to cases';

  @override
  String get statusPending => 'Pending review';

  @override
  String get statusApproved => 'Active case';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get sourceInterpol => 'INTERPOL';

  @override
  String get sourceCommunity => 'Community';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguagePT => 'Portuguese';

  @override
  String get settingsLanguageEN => 'English';

  @override
  String get settingsEmergency => 'Emergency';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsDataSources => 'Data sources';

  @override
  String get settingsSignIn => 'Sign in';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNewCases => 'New cases';

  @override
  String get settingsVerifiedAccount => 'Verified account';

  @override
  String get settingsNotSignedIn => 'Not signed in';

  @override
  String get adminTitle => 'Admin — Pending cases';

  @override
  String get adminAllCaughtUp => 'All caught up';

  @override
  String get adminNoPending => 'No pending cases to review.';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminRejectConfirmTitle => 'Reject case?';

  @override
  String get adminApproved => 'Case approved and published.';

  @override
  String get adminRejected => 'Case rejected.';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorServer => 'Server error. Try again later.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get retryButton => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get emptyListTitle => 'No cases found';

  @override
  String get emptyListSubtitle => 'Try adjusting your filters.';

  @override
  String get caseUnavailable => 'Case unavailable';

  @override
  String get caseUnavailableSubtitle =>
      'This case could not be loaded right now.';

  @override
  String get goBack => 'Go back';
}
