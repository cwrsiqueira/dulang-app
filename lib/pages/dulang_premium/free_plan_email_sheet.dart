import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/features/subscription/freemium_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/termos_de_uso_e_politica_de_privacidade/termos_de_uso_e_politica_de_privacidade_widget.dart';

/// Bottom sheet de captura de e-mail para o plano gratuito.
/// Abre via [showFreePlanEmailSheet]; resolve com `true` se o cadastro ocorreu.
class FreePlanEmailSheet extends StatefulWidget {
  const FreePlanEmailSheet({super.key});

  @override
  State<FreePlanEmailSheet> createState() => _FreePlanEmailSheetState();
}

class _FreePlanEmailSheetState extends State<FreePlanEmailSheet> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreed = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    print('[DEBUG] _submit chamado');
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      setState(() => _error = 'Aceite os termos para continuar.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    print('[DEBUG] email: $email');

    try {
      await FreemiumService.instance.enroll(email);
      print('[DEBUG] enroll ok');
      _sendToBrevo(email);
      print('[DEBUG] sendToBrevo chamado');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e, stack) {
      print('[DEBUG] ERRO em _submit: $e\n$stack');
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _sendToBrevo(String email) async {
    print('[Brevo] 1 - iniciando para $email');
    try {
      print('[Brevo] 2 - chamando invoke');
      final res = await Supabase.instance.client.functions.invoke(
        'hyper-function',
        body: {'email': email},
      );
      print('[Brevo] 3 - status=${res.status} data=${res.data}');
    } catch (e) {
      print('[Brevo] erro: $e');
    }
    print('[Brevo] 4 - fim');
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tertiary = theme.tertiary;
    final onCard = theme.primaryText;
    final onMuted = theme.secondaryText;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Plano gratuito — 1h por dia',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: onCard,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acesso a todo o conteúdo, por 1 hora diária, para sempre.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: onMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    style: GoogleFonts.inter(color: onCard, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'E-mail do responsável',
                      labelStyle: GoogleFonts.inter(color: onMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.mail_outline_rounded, color: onMuted),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe seu e-mail.';
                      final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                      if (!ok) return 'E-mail inválido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreed,
                        onChanged: (v) => setState(() {
                          _agreed = v ?? false;
                          _error = null;
                        }),
                        activeColor: tertiary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: onMuted,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'Concordo com os '),
                                TextSpan(
                                  text: 'Termos e Política de Privacidade',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: tertiary,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => context.pushNamed(
                                          TermosDeUsoEPoliticaDePrivacidadeWidget.routeName,
                                        ),
                                ),
                                const TextSpan(
                                  text: ' e autorizo o uso do meu e-mail para comunicações do Dulang (LGPD).',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: tertiary,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Continuar grátis',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Abre o bottom sheet e retorna `true` se o usuário completou o cadastro.
Future<bool> showFreePlanEmailSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const FreePlanEmailSheet(),
  );
  return result == true;
}
