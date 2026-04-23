import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/inputs/select_input.dart';
import '../../../../shared/widgets/inputs/text_input.dart';

/// Card de información de la empresa.
///
/// Ref Pencil: Settings - Organization / Card 1
/// Muestra los campos de nombre, NIF, dirección, país y código postal.
class CompanyInfoCard extends StatelessWidget {
  final String companyName;
  final String nif;
  final String address;
  final String country;
  final String postalCode;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onNifChanged;
  final ValueChanged<String>? onAddressChanged;
  final ValueChanged<String?>? onCountryChanged;
  final ValueChanged<String>? onPostalCodeChanged;
  final VoidCallback? onSave;

  const CompanyInfoCard({
    super.key,
    required this.companyName,
    required this.nif,
    required this.address,
    required this.country,
    required this.postalCode,
    this.onNameChanged,
    this.onNifChanged,
    this.onAddressChanged,
    this.onCountryChanged,
    this.onPostalCodeChanged,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      header: GlassCardHeader(
        title: 'Informaci\u00f3n de la empresa',
        trailing: PrimaryButton(label: 'Guardar cambios', onPressed: onSave),
      ),
      content: GlassCardContent(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.xl,
          AppSpacing.s24,
          AppSpacing.s20,
        ),
        child: Column(
          children: [
            // Row 1: Nombre + NIF
            Row(
              children: [
                Expanded(
                  child: TeeDooTextField(
                    label: 'Nombre de la empresa',
                    controller: TextEditingController(text: companyName),
                    onChanged: onNameChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: TeeDooTextField(
                    label: 'NIF / CIF',
                    controller: TextEditingController(text: nif),
                    onChanged: onNifChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Row 2: Direccion
            TeeDooTextField(
              label: 'Direcci\u00f3n',
              controller: TextEditingController(text: address),
              onChanged: onAddressChanged,
            ),
            const SizedBox(height: AppSpacing.s16),

            // Row 3: Pais + Codigo postal
            Row(
              children: [
                Expanded(
                  child: TeeDooSelect(
                    label: 'Pa\u00eds',
                    value: country,
                    onChanged: onCountryChanged,
                    options: const [
                      SelectOption(value: 'ES', label: 'Espa\u00f1a'),
                      SelectOption(value: 'PT', label: 'Portugal'),
                      SelectOption(value: 'FR', label: 'Francia'),
                      SelectOption(value: 'DE', label: 'Alemania'),
                      SelectOption(value: 'IT', label: 'Italia'),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: TeeDooTextField(
                    label: 'C\u00f3digo postal',
                    controller: TextEditingController(text: postalCode),
                    onChanged: onPostalCodeChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
