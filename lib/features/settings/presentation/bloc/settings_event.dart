part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

final class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

final class SettingsLocaleChanged extends SettingsEvent {
  final Locale locale;
  const SettingsLocaleChanged(this.locale);
  @override
  List<Object?> get props => [locale];
}
