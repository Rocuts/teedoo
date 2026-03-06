import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/navigation/app_topbar.dart';
import '../../providers/settings_provider.dart';
import '../widgets/certificate_card.dart';
import '../widgets/company_info_card.dart';
import '../widgets/integrations_tab.dart';
import '../widgets/language_tab.dart';
import '../widgets/logo_upload_card.dart';
import '../widgets/numbering_card.dart';
import '../widgets/security_tab.dart';
import '../widgets/users_tab.dart';
import '../widgets/appearance_tab.dart';

/// Pantalla de Configuración.
///
/// Ref Pencil: Settings - Organization (UqKoP) — 1440x900
///
/// Layout: Column > Topbar + Content area con tabs.
/// Tabs: Organización | Usuarios | Idioma | Integraciones | Seguridad
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _activeTab = 0;
  final _scrollController = ScrollController();

  static const _tabs = [
    'Organización',
    'Usuarios',
    'Idioma',
    'Integraciones',
    'Apariencia',
    'Seguridad',
  ];

  void _onTabChanged(int index) {
    if (index == _activeTab) return;
    setState(() => _activeTab = index);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTopbar(
          breadcrumbs: [
            const BreadcrumbItem(label: 'Configuración'),
            BreadcrumbItem(label: _tabs[_activeTab]),
          ],
        ),
        Expanded(
          child: ClipRect(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.contentPaddingH,
                vertical: context.contentPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Administra la configuración de tu organización',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  _buildTabBar(),
                  const SizedBox(height: AppSpacing.s28),

                  KeyedSubtree(
                    key: ValueKey<int>(_activeTab),
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.borderSubtle),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isActive = index == _activeTab;
            return Semantics(
              button: true,
              label: _tabs[index],
              selected: isActive,
              child: InkWell(
                onTap: () => _onTabChanged(index),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: isActive
                        ? Border(
                            bottom: BorderSide(
                              color: context.colors.accentBlue,
                              width: 2,
                            ),
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: ExcludeSemantics(
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                          color: isActive
                              ? context.colors.accentBlue
                              : context.colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_activeTab) {
      0 => _buildOrganizationTab(),
      1 => const UsersTab(),
      2 => const LanguageTab(),
      3 => const IntegrationsTab(),
      4 => const AppearanceTab(),
      5 => const SecurityTab(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildOrganizationTab() {
    final settingsState = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final org = settingsState.organization;

    return Column(
      children: [
        CompanyInfoCard(
          companyName: org.name,
          nif: org.nif,
          address: org.address,
          country: org.country,
          postalCode: org.postalCode,
          onNameChanged: notifier.updateName,
          onNifChanged: notifier.updateNif,
          onAddressChanged: notifier.updateAddress,
          onCountryChanged: (value) {
            if (value != null) notifier.updateCountry(value);
          },
          onPostalCodeChanged: notifier.updatePostalCode,
          onSave: settingsState.isDirty ? notifier.saveChanges : null,
        ),
        const SizedBox(height: AppSpacing.s24),

        LogoUploadCard(
          logoUrl: org.logoUrl,
          onUpload: () {
            // TODO: Implement file picker integration
          },
        ),
        const SizedBox(height: AppSpacing.s24),

        CertificateCard(
          certificateName: org.certificateName,
          certificateExpiry: org.certificateExpiry,
          onUpload: () {
            // TODO: Implement certificate upload
          },
        ),
        const SizedBox(height: AppSpacing.s24),

        NumberingCard(
          invoicePrefix: org.invoicePrefix,
          nextNumber: org.nextInvoiceNumber.toString().padLeft(6, '0'),
          onPrefixChanged: notifier.updateInvoicePrefix,
          onNumberChanged: (value) {
            final number = int.tryParse(value);
            if (number != null) {
              notifier.updateNextInvoiceNumber(number);
            }
          },
        ),
      ],
    );
  }
}
