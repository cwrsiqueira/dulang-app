import 'package:flutter/material.dart';
import '/features/parental/parental_service.dart';
import '/features/profiles/child_profile_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  /// 0 = carrossel; 1 = PIN parental; 2 = criar primeiro perfil.
  int _phase = 0;
  final PageController _introController = PageController();
  int _introPage = 0;

  // Fase 1 — PIN
  String _pin = '';
  String _entered = '';
  bool _isConfirming = false;
  String? _errorMessage;
  DateTime? _lastDigitPressAt;

  // Fase 2 — perfil
  final _profileController = TextEditingController();
  bool _savingProfile = false;

  static const _introHeadlines = [
    'Conteúdo pensado para pequenos',
    'Sem distrações do YouTube',
    'Controle nas mãos dos pais',
  ];
  static const _introSubtitles = [
    'Vídeos em inglês, curadoria segura e ambiente fechado para crianças.',
    'Nada de links externos nem navegação fora do app.',
    'PIN, horários e limite diário quando você quiser usar.',
  ];

  @override
  void dispose() {
    _introController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  // ── Fase 1: PIN ──────────────────────────────────────────────

  void _onKey(String key) {
    setState(() => _errorMessage = null);
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
    if (_entered.length >= ParentalService.pinMaxDigits) return;
    setState(() => _entered = _entered + key);
  }

  void _submitPinEntry() {
    if (_entered.length < ParentalService.pinMinDigits ||
        _entered.length > ParentalService.pinMaxDigits) return;
    _onPinComplete(_entered);
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
        _finishPin(pin);
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

  Future<void> _finishPin(String pin) async {
    await ParentalService.completeOnboarding(pin);
    if (!mounted) return;
    setState(() => _phase = 2);
  }

  // ── Fase 2: perfil ───────────────────────────────────────────

  Future<void> _createProfileAndFinish() async {
    final name = _profileController.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingProfile = true);
    await ChildProfileService.instance.addProfile(name, 0xFF36B4FF);
    if (!mounted) return;
    // Tudo feito no mesmo widget — sem navegação cross-route.
    // O router assume o controle após setOnboardingDone().
    AppStateNotifier.instance.setOnboardingDone();
  }

  // ── Build helpers ─────────────────────────────────────────────

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(ParentalService.pinMaxDigits, (i) {
        final filled = i < _entered.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 16,
          height: 16,
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
                final accent = FlutterFlowTheme.of(context).tertiary;
                return Material(
                  key: ValueKey<String>('onboard_pin_$k'),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashColor: accent.withValues(alpha: 0.35),
                    highlightColor: accent.withValues(alpha: 0.14),
                    onTap: () => _onKey(k),
                    child: SizedBox(
                      width: 80,
                      height: 60,
                      child: Center(
                        child: k == 'del'
                            ? Icon(Icons.backspace_outlined,
                                size: 24,
                                color:
                                    FlutterFlowTheme.of(context).primaryText)
                            : Text(
                                k,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
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

  Widget _buildIntroPageIndicator() {
    final accent = FlutterFlowTheme.of(context).tertiary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == _introPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: active ? accent : Colors.grey.shade700,
          ),
        );
      }),
    );
  }

  Widget _buildIntro() {
    final accent = FlutterFlowTheme.of(context).tertiary;
    return Column(
      children: [
        Expanded(
          flex: 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _IntroCollage(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 10,
          child: ColoredBox(
            color: Colors.black,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _introController,
                    onPageChanged: (i) => setState(() => _introPage = i),
                    itemCount: 3,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _introHeadlines[i],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _introSubtitles[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildIntroPageIndicator(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_introPage < 2) {
                          _introController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          setState(() => _phase = 1);
                        }
                      },
                      child: Text(
                        _introPage < 2 ? 'Continuar' : 'Começar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetPin() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => setState(() {
                _phase = 0;
                _entered = '';
                _isConfirming = false;
                _pin = '';
                _errorMessage = null;
              }),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
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
                : 'Use de ${ParentalService.pinMinDigits} a ${ParentalService.pinMaxDigits} dígitos. '
                    'Será pedido para sair do app ou acessar as configurações.',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPinDots(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_entered.length >= ParentalService.pinMinDigits &&
                    _entered.length <= ParentalService.pinMaxDigits)
                ? _submitPinEntry
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).tertiary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(_isConfirming ? 'Confirmar PIN' : 'Continuar'),
          ),
          const SizedBox(height: 16),
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

  Widget _buildCreateProfile() {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care_rounded, size: 56, color: theme.primary),
          const SizedBox(height: 20),
          Text(
            'Quem vai usar o Dulang?',
            style: theme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie o primeiro perfil infantil para começar.',
            style: theme.bodySmall
                .copyWith(color: theme.secondaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _profileController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createProfileAndFinish(),
            decoration: InputDecoration(
              labelText: 'Nome da criança',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _savingProfile ? null : _createProfileAndFinish,
            style: FilledButton.styleFrom(
              backgroundColor: theme.tertiary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _savingProfile
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.black),
                  )
                : const Text(
                    'Continuar',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _phase == 0
            ? Colors.black
            : FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: _phase == 0
              ? _buildIntro()
              : _phase == 1
                  ? _buildSetPin()
                  : _buildCreateProfile(),
        ),
      ),
    );
  }
}

/// Grade de "posters" com leve rotação, inspirada em apps de streaming.
class _IntroCollage extends StatelessWidget {
  const _IntroCollage();

  @override
  Widget build(BuildContext context) {
    const assets = [
      'assets/images/dulang512x512.png',
      'assets/images/dulang.webp',
      'assets/images/dulang1_bgtransparent.png',
      'assets/images/Ad_do_App.png',
    ];
    return ColoredBox(
      color: const Color(0xFF141414),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          final specs = <({
            double lx,
            double ty,
            double rw,
            double rh,
            double angle
          })>[
            (lx: 0.02, ty: 0.06, rw: 0.38, rh: 0.42, angle: -0.09),
            (lx: 0.48, ty: 0.02, rw: 0.44, rh: 0.38, angle: 0.07),
            (lx: 0.12, ty: 0.38, rw: 0.36, rh: 0.40, angle: 0.05),
            (lx: 0.52, ty: 0.42, rw: 0.40, rh: 0.36, angle: -0.06),
            (lx: -0.04, ty: 0.52, rw: 0.34, rh: 0.34, angle: 0.04),
            (lx: 0.62, ty: 0.58, rw: 0.32, rh: 0.32, angle: -0.05),
          ];
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              for (var i = 0; i < specs.length; i++)
                Positioned(
                  left: w * specs[i].lx,
                  top: h * specs[i].ty,
                  child: Transform.rotate(
                    angle: specs[i].angle,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        assets[i % assets.length],
                        width: w * specs[i].rw,
                        height: h * specs[i].rh,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: w * specs[i].rw,
                          height: h * specs[i].rh,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
