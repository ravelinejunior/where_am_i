part of 'settings_bloc.dart';

final class SettingsState extends Equatable {
  final Locale locale;

  const SettingsState({this.locale = const Locale('en')});

  bool get isPortuguese => locale.languageCode == 'pt';

  SettingsState copyWith({Locale? locale}) =>
      SettingsState(locale: locale ?? this.locale);

  @override
  List<Object?> get props => [locale];
}
