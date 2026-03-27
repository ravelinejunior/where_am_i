import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;

  static const _localeKey = 'app_locale';

  SettingsBloc(this._prefs) : super(const SettingsState()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsLocaleChanged>(_onLocaleChanged);

    add(const SettingsLoaded());
  }

  void _onLoaded(SettingsLoaded event, Emitter<SettingsState> emit) {
    final saved = _prefs.getString(_localeKey);
    final locale = saved != null ? Locale(saved) : const Locale('en');
    emit(state.copyWith(locale: locale));
  }

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setString(_localeKey, event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }
}
