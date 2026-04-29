# Checklist rápido: validar sandbox da Play (Internal Test)

Use este checklist antes de testar compra/cancelamento/mudança de plano no Android.

Marque os itens conforme for concluindo (este arquivo é um modelo reutilizável).

## 1) Conta de teste habilitada

- [ ] Em `Play Console > Testing > Internal testing`, o e-mail está na lista de testers.
- [ ] Em `Play Console > Settings > License testing` (**Teste de licença**), o e-mail está em uma lista **e essa lista está marcada (checkbox) + Salvar alterações**. Só existir a lista não basta: ela precisa estar **selecionada** como lista de licensed testers.

## 2) Instalação correta do app

- [ ] Desinstalar versão atual do app.
- [ ] Entrar no link de opt-in da track `Internal testing` (copiar de **Teste interno → Testadores → link para participantes**).
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

## 8) Problema comum: Play Store mostra “Item not found” no opt-in (Internal testing)

Sintoma observado em QA (2026-04-28): uma conta Google consegue instalar o app pelo opt-in, outra conta (também listada) cai em **Item not found** mesmo com release **Disponível para testers**.

Checklist rápido para esse caso:

- [ ] Confirmar que o opt-in foi aberto com a **mesma conta** que está ativa na Play Store no momento do “Baixar”.
- [ ] Remover outras contas Google do aparelho temporariamente e repetir o opt-in.
- [ ] Conferir se a conta não está em conflito entre trilhas (ex.: também em **Teste fechado/aberto** de forma que atrapalhe a elegibilidade do interno).
- [ ] Aguardar propagação (horas) e tentar novamente.
- [ ] Se precisar destravar QA imediatamente, usar temporariamente a conta Google que **já instala** o build interno até a Play estabilizar para a segunda conta.

## 9) Trial de 7 dias em conta que já começou trial “de verdade”

Se a conta já consumiu o trial em produção para a mesma oferta de **aquisição de novos clientes**, a Play costuma **não oferecer outro trial** para essa conta — mesmo em fluxo de teste. Para repetir trial com fidelidade, use **outra conta Google** de QA (com internal + license testing).

## Resultado esperado

Com os itens acima, o fluxo de teste fica confiável para validar compra, trial, gerenciamento, cancelamento e restauração sem risco de cobrança real.
