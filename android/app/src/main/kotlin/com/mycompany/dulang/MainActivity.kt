package com.mycompany.dulang

import io.flutter.embedding.android.FlutterFragmentActivity

/// [FlutterFragmentActivity] é necessário para o `local_auth` (BiometricPrompt):
/// sem isso o Android devolve falha e o PIN/senha do aparelho nunca aparece.
class MainActivity : FlutterFragmentActivity()
