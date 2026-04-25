import 'package:flutter/material.dart';
import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  int _step = 0;
  String _pin = '';
  String _entered = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onKey(String key) {
    setState(() => _errorMessage = null);
    if (key == 'del') {
      if (_entered.isNotEmpty) {
        setState(() => _entered = _entered.substring(0, _entered.length - 1));
      }
      return;
    }
    if (_entered.length >= 4) return;
    final next = _entered + key;
    setState(() => _entered = next);
    if (next.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () => _onPinComplete(next));
    }
  }

  void _onPinComplete(String pin) {
    if (!_isConfirming) {
      setState(() {
        _pin = pin;
        _entered = '';
        _isConfirming = true;
      });
    } else {
      if (pin == _pin) {
        _finish(pin);
      } else {
        setState(() {
          _entered = '';
          _isConfirming = false;
          _pin = '';
          _errorMessage = 'Os PINs não coincidem. Tente novamente.';
        });
      }
    }
  }

  Future<void> _finish(String pin) async {
    await ParentalService.completeOnboarding(pin);
    if (!mounted) return;
    AppStateNotifier.instance.setOnboardingDone();
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _entered.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? FlutterFlowTheme.of(context).primary
                : Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
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
                if (k.isEmpty) return const SizedBox(width: 80, height: 60);
                return InkWell(
                  onTap: () => _onKey(k),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 60,
                    alignment: Alignment.center,
                    child: k == 'del'
                        ? Icon(Icons.backspace_outlined,
                            size: 24,
                            color: FlutterFlowTheme.of(context).primaryText)
                        : Text(
                            k,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/dulang512x512.png',
              width: 100,
              height: 100,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Bem-vindo ao Dulang!',
            style: FlutterFlowTheme.of(context).headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Olá! O Dulang é um ambiente seguro para seu filho assistir vídeos em inglês selecionados para crianças de 0 a 5 anos.\n\nNenhum link externo, sem distrações do YouTube.\n\nA seguir, vamos criar um PIN parental para proteger as configurações do app.',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Criar PIN e começar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetPin() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline,
              size: 48, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(height: 16),
          Text(
            _isConfirming ? 'Confirme o PIN' : 'Crie seu PIN parental',
            style: FlutterFlowTheme.of(context).headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isConfirming
                ? 'Digite o mesmo PIN novamente para confirmar.'
                : 'Este PIN será pedido para sair do app\nou acessar as configurações.',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildDots(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 28),
          _buildNumpad(),
          if (_isConfirming) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _isConfirming = false;
                _entered = '';
                _pin = '';
              }),
              child: Text(
                'Redefinir PIN',
                style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondaryText),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: _step == 0 ? _buildWelcome() : _buildSetPin(),
        ),
      ),
    );
  }
}
