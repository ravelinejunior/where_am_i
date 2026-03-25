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
  String get filterBirthYear => 'Birth year range';

  @override
  String get filterSource => 'Source';

  @override
  String get filterApply => 'Apply filters';

  @override
  String get filterClear => 'Clear';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexUnknown => 'Unknown';

  @override
  String get lastSeenLabel => 'Last seen';

  @override
  String get ageLabel => 'Age';

  @override
  String get heightLabel => 'Height';

  @override
  String get nationalityLabel => 'Nationality';

  @override
  String get sexLabel => 'Sex';

  @override
  String get caseIdLabel => 'Case ID';

  @override
  String get sourceLabel => 'Source';

  @override
  String get detailFacts => 'Case details';

  @override
  String get detailContacts => 'Contacts';

  @override
  String get detailPhotos => 'Photos';

  @override
  String get shareCase => 'Share this case';

  @override
  String get reportCase => 'Report a missing person';

  @override
  String get sosTitle => 'Emergency';

  @override
  String get sosCallEurope => 'Call 112 (Europe)';

  @override
  String get sosDescription =>
      'If you have information about a missing person or are in danger, call emergency services immediately.';

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
  String get reportTitle => 'Report a missing person';

  @override
  String get reportName => 'Full name';

  @override
  String get reportDOB => 'Date of birth';

  @override
  String get reportLastSeen => 'Last seen date';

  @override
  String get reportLastLocation => 'Last known location';

  @override
  String get reportSex => 'Sex';

  @override
  String get reportHeight => 'Height (cm)';

  @override
  String get reportNationality => 'Nationality';

  @override
  String get reportFacts => 'Additional details';

  @override
  String get reportPhotos => 'Add photos';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportPendingNotice =>
      'Your report will be reviewed before publication.';

  @override
  String get statusPending => 'Pending review';

  @override
  String get statusApproved => 'Active case';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get sourceInterpol => 'INTERPOL';

  @override
  String get sourceCommunity => 'Community';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get errorServer => 'Server error. Try again later.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get retryButton => 'Retry';

  @override
  String get emptyListTitle => 'No cases found';

  @override
  String get emptyListSubtitle => 'Try adjusting your filters.';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String yearsOld(int age) {
    return '$age years old';
  }

  @override
  String cmHeight(int cm) {
    return '$cm cm';
  }
}
