import '/features/parental/parental_service.dart';
import '/features/subscription/freemium_service.dart';
import '/features/subscription/subscription_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/dulang_premium/dulang_premium_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  Future<void> _persist() async {
    await ParentalService.setAccessWindowEnabled(_windowOn);
    await ParentalService.setDailyLimitEnabled(_limitOn);
    await ParentalService.setAccessWindowHours(_start, _end);
    await ParentalService.setDailyLimitMinutes(_limitMin);
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferências salvas.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final premium = context.watch<SubscriptionService>().hasPremiumAccess;
    final freemium = context.watch<FreemiumService>().isEnrolled && !premium;

    if (freemium) {
      final theme = FlutterFlowTheme.of(context);
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.secondaryBackground,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: theme.primaryText),
            onPressed: () => context.safePop(),
          ),
          title: Text('Horários e tempo de uso',
              style: theme.headlineSmall),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    size: 60,
                    color: theme.tertiary.withValues(alpha: 0.5)),
                const SizedBox(height: 20),
                Text(
                  'Plano gratuito: 1 hora por dia',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.primaryText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No plano gratuito o limite de 1h/dia é fixo. Assine o Premium para configurar horários e limites personalizados.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.tertiary,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () =>
                      context.pushNamed(DulangPremiumWidget.routeName),
                  child: Text(
                    'Ver planos Premium',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
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
            onChanged: (v) => setState(() => _windowOn = v),
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
                        onChanged: (v) => setState(() => _start = v ?? 8),
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
                        onChanged: (v) => setState(() => _end = v ?? 22),
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
            onChanged: (v) => setState(() => _limitOn = v),
          ),
          if (_limitOn)
            Slider(
              value: _limitMin.toDouble(),
              min: 15,
              max: 300,
              divisions: 19,
              label: '$_limitMin min',
              onChanged: (v) => setState(() => _limitMin = v.round()),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _persist,
            style: FilledButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).tertiary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
