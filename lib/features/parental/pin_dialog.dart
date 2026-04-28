import 'package:flutter/material.dart';

import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Resultado do diálogo de PIN na barra inferior e em outros fluxos parentais.
enum PinDialogResult {
  /// PIN correto — pode liberar a ação (ex.: aba Ajustes).
  verified,

  /// Usuário cancelou.
  cancelled,

  /// Adulto confirmou no aparelho e deve ir para redefinir PIN (sem lembrar o antigo).
  forgotPin,
}

Future<PinDialogResult> showPinDialog(
  BuildContext context, {
  bool canCancel = true,
}) async {
  return await showDialog<PinDialogResult>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinDialog(canCancel: canCancel),
      ) ??
      PinDialogResult.cancelled;
}

class PinDialog extends StatefulWidget {
  const PinDialog({super.key, this.canCancel = true});

  final bool canCancel;

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  String _entered = '';
  bool _error = false;
  bool _forgotBusy = false;
  DateTime? _lastDigitPressAt;

  static const int _min = ParentalService.pinMinDigits;
  static const int _max = ParentalService.pinMaxDigits;

  bool get _canSubmit =>
      _entered.length >= _min && _entered.length <= _max;

  void _onKey(String key) {
    setState(() => _error = false);
    if (key == 'del') {
      if (_entered.isNotEmpty) {
        setState(() => _entered = _entered.substring(0, _entered.length - 1));
      }
      return;
    }
    final now = DateTime.now();
    if (_lastDigitPressAt != null &&
        now.difference(_lastDigitPressAt!) <
            const Duration(milliseconds: 220)) {
      return;
    }
    _lastDigitPressAt = now;
    if (_entered.length >= _max) return;
    setState(() => _entered = _entered + key);
  }

  Future<void> _verify() async {
    if (!_canSubmit) return;
    final ok = await ParentalService.verifyPin(_entered);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(PinDialogResult.verified);
    } else {
      setState(() {
        _entered = '';
        _error = true;
      });
    }
  }

  Future<void> _onForgotPin() async {
    setState(() => _forgotBusy = true);
    final ok = await ParentalService.authenticateDeviceAdult(
      localizedReason:
          'Confirme com biometria ou PIN do aparelho para redefinir o PIN parental do Dulang.',
    );
    if (!mounted) return;
    setState(() => _forgotBusy = false);
    if (ok) {
      Navigator.of(context).pop(PinDialogResult.forgotPin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível confirmar no aparelho. Tente de novo ou use o PIN do Dulang se lembrar.',
          ),
        ),
      );
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_max, (i) {
        final filled = i < _entered.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _error
                ? Colors.red
                : filled
                    ? FlutterFlowTheme.of(context).primary
                    : Colors.grey.shade300,
            border: Border.all(
              color: _error ? Colors.red : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKey(String label, String value) {
    final tertiary = FlutterFlowTheme.of(context).tertiary;
    return Material(
      key: ValueKey<String>('pin_key_$value'),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: tertiary.withValues(alpha: 0.35),
        highlightColor: tertiary.withValues(alpha: 0.14),
        onTap: () => _onKey(value),
        child: SizedBox(
          width: 72,
          height: 56,
          child: Center(
            child: value == 'del'
                ? Icon(
                    Icons.backspace_outlined,
                    size: 22,
                    color: FlutterFlowTheme.of(context).primaryText,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tertiary = FlutterFlowTheme.of(context).tertiary;
    return AlertDialog(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 40,
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 8),
          Text(
            'PIN Parental',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).headlineSmall,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Digite de $_min a $_max dígitos e toque em Confirmar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            _buildDots(),
            if (_error) ...[
              const SizedBox(height: 10),
              const Text(
                'PIN incorreto. Tente novamente.',
                style: TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _canSubmit ? _verify : null,
              style: FilledButton.styleFrom(
                backgroundColor: tertiary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Confirmar'),
            ),
            const SizedBox(height: 16),
            for (final row in [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
              ['', '0', 'del'],
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((k) {
                    if (k.isEmpty) return const SizedBox(width: 72, height: 56);
                    return _buildKey(k, k);
                  }).toList(),
                ),
              ),
            TextButton(
              onPressed: _forgotBusy ? null : _onForgotPin,
              child: _forgotBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Esqueci o PIN'),
            ),
          ],
        ),
      ),
      actions: widget.canCancel
          ? [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(PinDialogResult.cancelled),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ),
            ]
          : null,
    );
  }
}
