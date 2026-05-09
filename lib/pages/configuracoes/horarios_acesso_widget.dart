import 'dart:async' show Timer, unawaited;

import '/features/parental/parental_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class HorariosAcessoWidget extends StatefulWidget {
  const HorariosAcessoWidget({super.key});

  static String routeName = 'HorariosAcesso';
  static String routePath = '/horariosAcesso';

  @override
  State<HorariosAcessoWidget> createState() => _HorariosAcessoWidgetState();
}

class _HorariosAcessoWidgetState extends State<HorariosAcessoWidget>
    with WidgetsBindingObserver {
  bool _windowOn = false;
  bool _limitOn = false;
  int _start = 8;
  int _end = 22;
  int _limitMin = 120;
  int _used = 0;
  bool _loading = true;
  Timer? _debounceSave;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    _debounceSave?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (!_loading) {
      unawaited(_persistCore(showSnack: false, reloadAfter: false));
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    final w = await ParentalService.isAccessWindowEnabled();
    final l = await ParentalService.isDailyLimitEnabled();
    final s = await ParentalService.accessStartHour();
    final e = await ParentalService.accessEndHour();
    final m = await ParentalService.dailyLimitMinutes();
    final u = await ParentalService.todayUsedMinutes();
    if (!mounted) return;
    setState(() {
      _windowOn = w;
      _limitOn = l;
      _start = s;
      _end = e;
      _limitMin = m;
      _used = u;
      _loading = false;
    });
  }

  /// Salva preferências atuais. Com [debounce]: snack só ao parar de arrastar o slider.
  void _scheduleAutosave({bool debounce = false}) {
    if (_loading) return;
    if (debounce) {
      _debounceSave?.cancel();
      _debounceSave = Timer(const Duration(milliseconds: 450), () {
        _debounceSave = null;
        unawaited(_persistCore(showSnack: true, reloadAfter: true));
      });
    } else {
      _debounceSave?.cancel();
      _debounceSave = null;
      unawaited(_persistCore(showSnack: false, reloadAfter: true));
    }
  }

  Future<void> _persistCore({
    required bool showSnack,
    required bool reloadAfter,
  }) async {
    try {
      await ParentalService.setAccessWindowEnabled(_windowOn);
      await ParentalService.setDailyLimitEnabled(_limitOn);
      await ParentalService.setAccessWindowHours(_start, _end);
      await ParentalService.setDailyLimitMinutes(_limitMin);
      if (!mounted) return;
      if (showSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferências salvas.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      if (reloadAfter && mounted) await _load();
    } catch (e, st) {
      debugPrint('HorariosAcessoWidget persist: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível salvar. Tente de novo. (${e.toString()})',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Horários e tempo',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Limitar horário de uso'),
            subtitle: const Text(
              'Fora da janela o app orienta a criança a parar (tela principal).',
            ),
            value: _windowOn,
            onChanged: (v) {
              setState(() => _windowOn = v);
              _scheduleAutosave();
            },
          ),
          if (_windowOn) ...[
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'Início (hora)'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _start,
                        items: List.generate(
                          24,
                          (h) =>
                              DropdownMenuItem(value: h, child: Text('$h h')),
                        ),
                        onChanged: (v) {
                          setState(() => _start = v ?? 8);
                          _scheduleAutosave();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fim (hora)'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _end,
                        items: List.generate(
                          24,
                          (h) =>
                              DropdownMenuItem(value: h, child: Text('$h h')),
                        ),
                        onChanged: (v) {
                          setState(() => _end = v ?? 22);
                          _scheduleAutosave();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('Limite diário de tempo na tela'),
            subtitle: Text('Hoje: $_used min de $_limitMin min permitidos'),
            value: _limitOn,
            onChanged: (v) {
              setState(() => _limitOn = v);
              _scheduleAutosave();
            },
          ),
          if (_limitOn)
            Slider(
              value: _limitMin.toDouble(),
              min: 15,
              max: 300,
              divisions: 19,
              label: '$_limitMin min',
              onChanged: (v) {
                setState(() => _limitMin = v.round());
                _scheduleAutosave(debounce: true);
              },
            ),
          const SizedBox(height: 8),
          Text(
            'As alterações são salvas automaticamente.',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
