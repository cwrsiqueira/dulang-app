import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
  final _current = TextEditingController();
  final _n1 = TextEditingController();
  final _n2 = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _n1.dispose();
    _n2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    final c = _current.text.trim();
    final a = _n1.text.trim();
    final b = _n2.text.trim();
    if (c.length < 4 || a.length < 4) {
      setState(() {
        _error = 'PIN deve ter pelo menos 4 dígitos.';
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
    final ok = await ParentalService.changePin(c, a);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _error = 'PIN atual incorreto.');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN atualizado com sucesso.')),
    );
    context.safePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Alterar PIN',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _current,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'PIN atual',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _n1,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Novo PIN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _n2,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Confirmar novo PIN',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: FlutterFlowTheme.of(context).error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).tertiary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar novo PIN'),
          ),
        ],
      ),
    );
  }
}
