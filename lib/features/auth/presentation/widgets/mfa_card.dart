import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/theme/app_radius.dart';

/// Widget reutilizable de entrada MFA de 6 dígitos.
///
/// Ref Pencil: Auth - MFA Challenge (hO0Ik) — digit input row.
/// - 6 cajas: 48x56, radius md, fill bg-input, stroke border-subtle
/// - Foco activo: stroke accent-blue, width 2
/// - Texto: 22px/500 text-primary
class MfaDigitInput extends StatefulWidget {
  /// Llamado cuando los 6 dígitos se han completado.
  final ValueChanged<String>? onCompleted;

  /// Llamado con cada cambio parcial del código.
  final ValueChanged<String>? onChanged;

  /// Número de dígitos (por defecto 6).
  final int length;

  const MfaDigitInput({
    super.key,
    this.onCompleted,
    this.onChanged,
    this.length = 6,
  });

  @override
  State<MfaDigitInput> createState() => _MfaDigitInputState();
}

class _MfaDigitInputState extends State<MfaDigitInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _currentCode =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final code = _currentCode;
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.only(left: i > 0 ? 10 : 0),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(i, event),
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: context.colors.bgInput,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(
                    color: context.colors.borderSubtle,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(
                    color: context.colors.borderSubtle,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(
                    color: context.colors.accentBlue,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onDigitChanged(i, value),
            ),
          ),
        );
      }),
    );
  }
}
