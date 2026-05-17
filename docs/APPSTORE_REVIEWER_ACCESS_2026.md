# App Store Connect — revisor Apple (códigos DULANGIOS202601–05)

## Onde preencher no App Store Connect

**App Store Connect → seu app → Envio para revisão → Informações para revisão do app**

| Campo | O que fazer |
|-------|-------------|
| **Login necessário** | **Não** (desmarcar / selecionar "Não") |
| **Nome de usuário** | Deixar em branco |
| **Senha** | Deixar em branco |
| **Notas** | Colar o bloco abaixo |

> Os campos usuário/senha só ficam visíveis se você marcar "Login necessário = Sim". Com "Não", só o campo **Notas** aparece — é o único lugar que precisa preencher.

---

## Notas — inglês (texto principal; colar no campo "Notas")

Cole exatamente este bloco:

```
There is no email/password login in this app. All reviewer access is via a one-time access code entered in the Premium screen.

Steps to unlock premium content:
1. Complete onboarding: set any 4–6 digit parental PIN (e.g. 1234) and a child profile name.
2. After onboarding, the app goes directly to the Premium screen (paywall). Scroll to the bottom of that screen.
3. Tap "Tenho um código de acesso" (I have an access code) — it appears as a small link at the bottom.
4. Enter the code below (ALL CAPS, no spaces) and tap Confirm.
5. All premium areas unlock immediately on this install.

Access code: DULANGIOS202601

If this code shows "already used" or any error, use the next code in order:
DULANGIOS202602
DULANGIOS202603
DULANGIOS202604
DULANGIOS202605

Each code is single-use. If you reinstall or clear data, use the next unused code.
No VPN required. No in-app purchase needed for review.
```

---

## Versão compacta (se preferir texto mais curto)

```
No login required. To access premium content:

1. Complete onboarding: set a 4–6 digit parental PIN and a child name.
2. After onboarding the app goes directly to the Premium screen. Scroll to the bottom.
3. Tap "Tenho um código de acesso" (small link at the bottom) → enter code (ALL CAPS) → Confirm.

Code: DULANGIOS202601
Backup codes (single-use each): DULANGIOS202602, DULANGIOS202603, DULANGIOS202604, DULANGIOS202605

No VPN. No purchase needed.
```

---

## SQL — Supabase (SQL Editor)

Cria o lote exclusivo para revisão da App Store. Pode rodar mais de uma vez sem erro (o `delete` antes do `insert` garante idempotência).

```sql
begin;

-- Remove códigos deste lote caso o script seja reexecutado
delete from public.access_codes
where code in (
  'DULANGIOS202601',
  'DULANGIOS202602',
  'DULANGIOS202603',
  'DULANGIOS202604',
  'DULANGIOS202605'
);

insert into public.access_codes (code, label) values
  ('DULANGIOS202601', 'apple-appstore-review-2026-01'),
  ('DULANGIOS202602', 'apple-appstore-review-2026-02'),
  ('DULANGIOS202603', 'apple-appstore-review-2026-03'),
  ('DULANGIOS202604', 'apple-appstore-review-2026-04'),
  ('DULANGIOS202605', 'apple-appstore-review-2026-05');

commit;
```

**Conferência após inserir:**

```sql
select code, label, used, used_at, created_at
from public.access_codes
where code like 'DULANGIOS2026%'
order by code;
```

Os códigos têm **15 caracteres** (`DULANGIOS202601`…`05`), dentro do limite 8–32 da Edge Function `validate-access-code`.

---

## Dicas para não ser rejeitado

- **Não deixe as Notas em branco** — sem instrução, o revisor Apple testa o app sem premium e pode rejeitar dizendo que "funções principais estão bloqueadas".
- **Não cite RevenueCat ou sandbox** nas Notas — o revisor não precisa saber a stack técnica. Foco no fluxo.
- **PIN de 4–6 dígitos:** qualquer número funciona (ex.: 1234). Vale deixar explícito nas Notas para o revisor não ficar preso no onboarding.
- **Se o revisor testar IAP** (compra real no sandbox): o fluxo funciona normalmente. O código de acesso é só uma alternativa mais rápida para a revisão.
- **Resposta a rejeição por "conteúdo bloqueado":** encaminhe o texto da seção "Notas" por mensagem na Central de Revisões do ASC, destacando os passos e os códigos.
