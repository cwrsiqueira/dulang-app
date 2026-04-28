import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/configuracoes/device_auth_help_widget.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlterarPinWidget extends StatefulWidget {
  const AlterarPinWidget({super.key});

  static String routeName = 'AlterarPin';
  static String routePath = '/alterarPin';

  @override
  State<AlterarPinWidget> createState() => _AlterarPinWidgetState();
}

class _AlterarPinWidgetState extends State<AlterarPinWidget> {
  final _n1 = TextEditingController();
  final _n2 = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _n1.dispose();
    _n2.dispose();
    super.dispose();
  }

  Future<void> _openSystemLockSettings() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await AppSettings.openAppSettings(
          type: AppSettingsType.lockAndPassword,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await AppSettings.openAppSettings();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir os ajustes: $e')),
      );
    }
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    final a = _n1.text.trim();
    final b = _n2.text.trim();
    if (a.length < ParentalService.pinMinDigits ||
        a.length > ParentalService.pinMaxDigits ||
        b.length < ParentalService.pinMinDigits ||
        b.length > ParentalService.pinMaxDigits) {
      setState(() {
        _error =
            'O PIN deve ter entre ${ParentalService.pinMinDigits} e ${ParentalService.pinMaxDigits} dígitos.';
        _busy = false;
      });
      return;
    }
    if (a != b) {
      setState(() {
        _error = 'Os PINs novos não coincidem.';
        _busy = false;
      });
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      setState(() {
        _error =
            'Alteração com confirmação no aparelho só em Android ou iOS.';
        _busy = false;
      });
      return;
    }

    final deviceOk = await ParentalService.authenticateDeviceAdult(
      localizedReason:
          'Confirme no aparelho para salvar o novo PIN parental do Dulang.',
    );
    if (!mounted) return;
    if (!deviceOk) {
      await _openSystemLockSettings();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error =
            'Ative PIN, senha ou biometria nas configurações que abriram e tente Salvar de novo.';
      });
      return;
    }

    await ParentalService.setPinAfterDeviceAuth(a);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN atualizado com sucesso.')),
    );
    context.safePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Alterar PIN',
          style: theme.headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _n1,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: ParentalService.pinMaxDigits,
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) =>
                const SizedBox.shrink(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText:
                  'Novo PIN (${ParentalService.pinMinDigits}–${ParentalService.pinMaxDigits} dígitos)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _n2,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: ParentalService.pinMaxDigits,
            buildCounter: (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) =>
                const SizedBox.shrink(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText:
                  'Confirmar novo PIN (${ParentalService.pinMinDigits}–${ParentalService.pinMaxDigits} dígitos)',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: theme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: theme.tertiary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () =>
                  context.pushNamed(DeviceAuthHelpWidget.routeName),
              child: const Text('Por que o Dulang pede confirmação no aparelho?'),
            ),
          ),
        ],
      ),
    );
  }
}
