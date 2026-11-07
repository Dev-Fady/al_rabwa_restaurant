import 'package:flutter/material.dart';

class SettingsState {
  final Locale locale;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  // final bool biometricsEnabled;

  const SettingsState({
    required this.locale,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    // required this.biometricsEnabled,
  });

  SettingsState copyWith({
    Locale? locale,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    // bool? biometricsEnabled,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      // biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }

  List<Object?> get props => [
    locale,
    notificationsEnabled,
    darkModeEnabled,
    // biometricsEnabled,
  ];
}
