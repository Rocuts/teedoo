import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/organization_model.dart';

/// Estado inmutable para la configuración de la organización.
class SettingsState {
  final Organization organization;
  final bool isDirty;
  final bool isSaving;

  const SettingsState({
    required this.organization,
    this.isDirty = false,
    this.isSaving = false,
  });

  SettingsState copyWith({
    Organization? organization,
    bool? isDirty,
    bool? isSaving,
  }) {
    return SettingsState(
      organization: organization ?? this.organization,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Notifier de configuración con patrón moderno Riverpod.
class SettingsNotifier extends AutoDisposeNotifier<SettingsState> {
  @override
  SettingsState build() => SettingsState(organization: Organization.mock);

  // Company Info
  void updateName(String value) {
    state = state.copyWith(
      organization: state.organization.copyWith(name: value),
      isDirty: true,
    );
  }

  void updateNif(String value) {
    state = state.copyWith(
      organization: state.organization.copyWith(nif: value),
      isDirty: true,
    );
  }

  void updateAddress(String value) {
    state = state.copyWith(
      organization: state.organization.copyWith(address: value),
      isDirty: true,
    );
  }

  void updateCountry(String value) {
    state = state.copyWith(
      organization: state.organization.copyWith(country: value),
      isDirty: true,
    );
  }

  void updatePostalCode(String value) {
    state = state.copyWith(
      organization: state.organization.copyWith(postalCode: value),
      isDirty: true,
    );
  }

  // Invoice Numbering
  void updateInvoicePrefix(String value) {
    state = state.copyWith(
      organization: state.organization.copyWith(invoicePrefix: value),
      isDirty: true,
    );
  }

  void updateNextInvoiceNumber(int value) {
    state = state.copyWith(
      organization: state.organization.copyWith(nextInvoiceNumber: value),
      isDirty: true,
    );
  }

  // Language
  void updateLanguage(String value) {
    state = state.copyWith(
      organization: state.organization.copyWith(defaultLanguage: value),
      isDirty: true,
    );
  }

  // Save
  Future<void> saveChanges() async {
    state = state.copyWith(isSaving: true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isSaving: false, isDirty: false);
  }

  // Reset
  void resetChanges() {
    state = SettingsState(organization: Organization.mock);
  }
}

/// Provider de configuración con autoDispose.
final settingsProvider =
    AutoDisposeNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
