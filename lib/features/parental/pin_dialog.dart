import 'package:flutter/material.dart';
import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';

Future<bool> showPinDialog(BuildContext context, {bool canCancel = true}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinDialog(canCancel: canCancel),
      ) ??
      false;
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

  void _onKey(String key) {
    setState(() => _error = false);
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
      Future.delayed(const Duration(milliseconds: 150), () => _verify(next));
    }
  }

  Future<void> _verify(String pin) async {
    final ok = await ParentalService.verifyPin(pin);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _entered = '';
        _error = true;
      });
    }
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _entered.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
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
    return InkWell(
      onTap: () => _onKey(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 72,
        height: 56,
        alignment: Alignment.center,
        child: value == 'del'
            ? Icon(Icons.backspace_outlined,
                size: 22,
                color: FlutterFlowTheme.of(context).primaryText)
            : Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Icon(Icons.lock_outline,
              size: 40, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(height: 8),
          Text(
            'PIN Parental',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).headlineSmall,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDots(),
          if (_error) ...[
            const SizedBox(height: 10),
            const Text(
              'PIN incorreto. Tente novamente.',
              style: TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
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
        ],
      ),
      actions: widget.canCancel
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText),
                ),
              ),
            ]
          : null,
    );
  }
}
