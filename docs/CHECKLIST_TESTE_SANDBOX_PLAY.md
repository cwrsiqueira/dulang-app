# Checklist rápido: validar sandbox da Play (Internal Test)

Use este checklist antes de testar compra/cancelamento/mudança de plano no Android.

## 1) Conta de teste habilitada

- [ ] Em `Play Console > Testing > Internal testing`, o e-mail está na lista de testers.
- [ ] Em `Play Console > Settings > License testing`, o mesmo e-mail está como licensed tester.

## 2) Instalação correta do app

- [ ] Desinstalar versão atual do app.
- [ ] Entrar no link de opt-in da track `Internal testing`.
- [ ] Reinstalar pela Play Store (não usar APK/local build para esse teste).

## 3) Conta ativa no aparelho

- [ ] Na Play Store do celular, confirmar que a conta ativa é a conta tester/licensed.
- [ ] Evitar múltiplas contas Google no aparelho durante o teste.

## 4) Sinais de sandbox durante compra

- [ ] No checkout da Play, aparece indicação de compra de teste.
- [ ] Compra concluída sem cobrança real.

## 5) Validação no RevenueCat e Play

- [ ] No RevenueCat, evento/purchase aparece como `sandbox`.
- [ ] No Play Console (pedidos), o pedido aparece como teste.

## 6) Validação por tempo (ambiente acelerado)

- [ ] Trial e renovação em tempo reduzido (minutos), não no calendário real.
- [ ] Se o ciclo estiver em tempo real, revisar conta/licensing/instalação da track.

## 7) Se ainda não estiver em sandbox

- [ ] Remover e adicionar novamente a conta em `License testing`.
- [ ] Confirmar novamente inclusão da conta na track de teste.
- [ ] Aguardar propagação da Play.
- [ ] Limpar cache/dados da Play Store/Play Services e reinstalar pela track.

## Resultado esperado

Com os itens acima, o fluxo de teste fica confiável para validar compra, trial, gerenciamento, cancelamento e restauração sem risco de cobrança real.
