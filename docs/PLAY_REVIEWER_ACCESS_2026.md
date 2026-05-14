# Play Console — revisor Google Play (códigos DULANGREV202601–05)

## Limites do formulário (print do Console)

| Campo | Limite |
|--------|--------|
| **Nome da instrução** | 60 caracteres |
| **Nome de usuário** | 100 caracteres |
| **Senha** | 100 caracteres |
| **Outras informações necessárias para acesso** | **500 caracteres** (contador no próprio campo) |

**Estratégia:** use **inglês** no campo de 500 caracteres (revisores globais). Nos campos **usuário/senha** da Play, **`N/A` é o valor correto** quando não há conta — mas a mensagem de rejeição *“O nome de usuário ou a senha informados não funcionam”* costuma aparecer quando alguém (ou **checklist automático**) trata esses campos como **credenciais que precisam autenticar** algo. Por isso o bloco **“Outras informações”** deve abrir dizendo, em inglês, que **`N/A` é intencional**, **não** é login do app e **não** deve ser reportado como credencial quebrada; o acesso restrito é **só** pelos códigos no fluxo indicado.

### Nome da instrução (≤60), em inglês, sem nome do app

Escolha **uma** (todas ≤60 e sem citar marca). Preferência: deixar claro **acesso sem login** e **desbloqueio por código** (evita “cupom” se soar só a desconto; *access codes* é o termo mais neutro na Play).

| Texto sugerido | Caracteres |
|----------------|------------|
| `Reviewer access: no app login; one-time access codes` | 52 |
| `Access instructions: no login; one-time access codes` | 52 |
| `Reviewer access: no login; one-time coupon codes` | 48 |
| `Review access: no login; one-time coupon codes` | 46 |
| `Play review: no login required; unlock with codes` | 49 |
| `Reviewer access: no login; Premium via codes` | 44 |
| `N/A intentional - use codes (no app login)` | 42 |
| `How to unlock paid content for review (codes, no login)` | 55 |

**Recomendação:** `Reviewer access: no app login; one-time access codes` — resume instrução de acesso, **sem login** e **códigos de uso único** (equivalente ao “cupom” no seu fluxo). Alternativa mais curta: `Reviewer access: no login; Premium via codes`.

### Nome de usuário e senha — preencher ou deixar em branco?

**Não use textos como “não usar”, “ignore” ou “do not use” como “senha”.** Parece instrução ambígua ou valor literal; um revisor apressado pode achar que é string para digitar em algum campo do app ou reportar “credencial inválida” por interpretação errada.

- **Deixar em branco:** só se o Console **permitir salvar** assim. Se salvar, o revisor pode achar que faltou credencial; a Play às vezes espera algo preenchido.
- **Preencher com `NA` ou `N/A` nos dois campos (iguais):** é o padrão mais comum para “não aplicável”, parece **credencial técnica neutra**, não parece ordem em linguagem natural, e casa bem com a primeira frase do bloco de 500 caracteres (“Play Username/Password fields are NOT for the app—put NA in both”).
- **Conclusão:** mantenha **`N/A`** (ou `NA`) **igual nos dois campos** e use o bloco inglês **“anti-rejeição credenciais”** abaixo como texto principal após essa rejeição — ele responde direto ao template *“credentials do not work”*.

### Outras informações — inglês (recomendado após rejeição “credenciais não funcionam”; ~479 caracteres)

Abre **explicitamente** para revisor/checklist: `N/A` no formulário da Play **não** é login no app e **não** deve ser tratado como falha de autenticação. Depois o fluxo + códigos.

Cole **exatamente** este bloco (confira o contador de 500 no Console):

```
IMPORTANT for reviewers: Username/Password in this Play form = N/A (not applicable). There is NO sign-in with those values IN THE APP. Do not report them as broken credentials—they are placeholders only. Full reviewer access: onboarding (4–6 digit parental PIN + child name) → Premium → "Tenho um código de acesso" → paste one code (ALL CAPS). Single-use each; on error/reinstall, use next. No VPN.

DULANGREV202601
DULANGREV202602
DULANGREV202603
DULANGREV202604
DULANGREV202605
```

### Outras informações — inglês (alternativa anterior; ~487 caracteres)

Útil se preferir menos tom “IMPORTANT”; um pouco menos direto contra o template de credenciais.

```
There is no account/email/password login. The Play Username/Password fields are NOT for the app—put NA in both (placeholders only).

First launch: parental PIN (4–6 digits) + child name. Open Premium. Tap "Tenho um código de acesso". Paste ONE code below (ALL CAPS, no spaces). Single-use each. If invalid/already used/reinstall/clear data/new device, use NEXT code (5 total). IAP sandbox optional. No VPN.

DULANGREV202601
DULANGREV202602
DULANGREV202603
DULANGREV202604
DULANGREV202605
```

### Alternativa em inglês (estilo numerado; ~487 caracteres)

Versão baseada no seu rascunho: **só inglês**, frase inicial sem redundância (“no payment” uma vez), PIN alinhado ao app (**4–6 dígitos**), margem segura abaixo de **500** (contagem UTF-8 no arquivo).

```
No login or payment is required for review.

1. Complete onboarding (set a parental PIN of 4–6 digits and a child profile name).
2. Open Premium.
3. Tap "Tenho um código de acesso" (I have an access code).
4. Enter this code: DULANGREV202601
5. Tap Confirm.

If this code is already used or you see any error, use the following codes in order:

DULANGREV202602
DULANGREV202603
DULANGREV202604
DULANGREV202605

After successful validation, premium-only areas are unlocked on this install.
```

**Análise desta alternativa**

| Ponto | Comentário |
|--------|--------------|
| **Clareza** | Passos numerados e lista de códigos reserva são fáceis de seguir. |
| **Redundância** | O original repetia “no payment”; aqui uma só menção. |
| **PIN** | No app o PIN pode ser **4, 5 ou 6** dígitos; “4-digit” sozinho seria impreciso. |
| **Limite 500** | ~487 caracteres (UTF-8) — confira o contador do Console ao colar. |
| **Campos usuário/senha da Play** | Este bloco **não** fala em `NA`; continue usando **NA** nos dois campos do formulário. Para reduzir risco de “login/senha inválidos”, o bloco **“anti-rejeição credenciais”** acima é o mais adequado após a rejeição automática por credenciais. |

### Outras informações — português (≤500; ~488 caracteres no arquivo)

Use só se quiser alinhar ao Console em PT; o inglês costuma ser mais seguro para o revisor.

```
Sem login no app. Campos usuário/senha da Play não autenticam—NA nos dois (placeholders). Não digite NA dentro do app.

Onboarding: PIN (4–6) + criança. Premium → Tenho um código de acesso. Cole UM código abaixo (MAIÚSCULAS, sem espaços). Uso único; se falhar/já usado/reinstalar/limpar/outro aparelho: próximo (5). Sem código ou compra, telas premium ficam bloqueadas (esperado). Sandbox opcional. Sem VPN.

DULANGREV202601
DULANGREV202602
DULANGREV202603
DULANGREV202604
DULANGREV202605
```

**Códigos em uma linha:** se precisar de espaço futuro, os cinco códigos cabem numa linha (74 caracteres com espaços); nesta versão as quebras de linha ajudam a leitura e ainda deixam folga no limite.

### Checkbox “Nenhuma outra informação é necessária…”

Marque **somente** se for verdade que não há VPN, conta de teste em outro serviço, etc. Se você depender de mensagem no Console para um 6º código, talvez seja mais coerente **desmarcar**; avalie conforme a política atual da tela.

---

## Texto longo (referência — **não** cabe no campo de 500)

O bloco abaixo é útil para documentação interna ou resposta a mensagem do revisor; **não** cole no campo “Outras informações” do Play Console.

<details>
<summary>Clique para expandir (inglês, formato antigo)</summary>

```
IMPORTANT — There is NO email/password login for this app. Do not use the Username/Password fields below for authentication. They are placeholders only (see Step 0).

Step 0 — Username / Password fields on this form
- Username: N_A_REVIEWER
- Password: N_A_REVIEWER
These values are NOT used inside the app. Google Play may require fields to be filled; they are intentionally non-functional. All reviewer access is via ONE-TIME access codes (see below).

How to unlock Premium for review (one-time codes)
The app has NO mandatory account login. Premium content is unlocked either by an in-app purchase (sandbox) OR by a one-time access code entered on the Premium screen.

1. Install the app from the review track and complete onboarding: set any 4–6 digit parental PIN (e.g. 1234) and a child profile name.
2. Open the Premium / subscription screen (paywall).
3. Tap "Tenho um código de acesso" (I have an access code).
4. Enter EXACTLY one of the codes below (all caps, no spaces). Tap Confirm.
5. All premium areas (Favorites, History, themes, schedules, etc.) unlock immediately.

Reviewer codes (each code works ONCE — first successful validation consumes it)
If a code fails with "already used" / invalid, or you cleared app data / reinstalled / switched device, use the NEXT unused code in order:

| Order | Code           |
|-------|----------------|
| 1     | DULANGREV202601 |
| 2     | DULANGREV202602 |
| 3     | DULANGREV202603 |
| 4     | DULANGREV202604 |
| 5     | DULANGREV202605 |

Do NOT reuse a code after it has worked once. If you need more than five fresh installs, contact the developer via the Play Console message thread.

Premium-gated screens without a valid code or purchase are intentionally limited — this is expected behavior, not a bug.
```

</details>

---

## A abordagem cobre os quê?

**Sim.** Em conjunto, cobre:

1. **Cupom de uso único + nova sessão** — se o revisor limpar dados, reinstalar, trocar de aparelho ou um segundo analista precisar de um código novo, há **até 5 códigos** em sequência; nas instruções você diz para usar o **próximo** se o atual já tiver sido consumido ou aparecer “inválido / já utilizado”.
2. **Declaração de acesso (usuário/senha)** — o texto deixa explícito que **não existe login com e-mail/senha** para o app; o acesso para revisão é **somente** pelos códigos no fluxo indicado. Nos campos obrigatórios de usuário/senha use os placeholders sugeridos abaixo (ou equivalente permitido pela Central de Ajuda), para não conflitar com a mensagem “credenciais não funcionam”.

**Confirmação do formulário:** no **Play Console** → **Política e programas** → **Conteúdo do app** → **Declaração de acesso ao app**, confira que existe **apenas uma** declaração ativa para este app e que **não** há outra declaração antiga (por exemplo, ainda citando e-mail/senha do plano gratuito removido). Remova ou atualize qualquer declaração duplicada antes de reenviar.

[Central de Ajuda — credenciais de acesso ao app](https://support.google.com/googleplay/android-developer/answer/9859450) (se precisar validar placeholders).

---

## SQL — Supabase (SQL Editor)

**Ordem:** remove o cupom legado `DULANGREV2026` (se existir), remove os cinco códigos novos caso você rode o script de novo, e insere os cinco códigos limpos.

```sql
begin;

-- Cupom antigo de revisor (12 caracteres), se ainda existir
delete from public.access_codes
where code = 'DULANGREV2026';

-- Permite reexecutar o script sem violar unique
delete from public.access_codes
where code in (
  'DULANGREV202601',
  'DULANGREV202602',
  'DULANGREV202603',
  'DULANGREV202604',
  'DULANGREV202605'
);

insert into public.access_codes (code, label) values
  ('DULANGREV202601', 'google-play-review-2026-01'),
  ('DULANGREV202602', 'google-play-review-2026-02'),
  ('DULANGREV202603', 'google-play-review-2026-03'),
  ('DULANGREV202604', 'google-play-review-2026-04'),
  ('DULANGREV202605', 'google-play-review-2026-05');

commit;
```

**Conferência:**

```sql
select code, label, used, used_at, created_at
from public.access_codes
where code like 'DULANGREV2026%'
order by code;
```

Os códigos têm **14 caracteres** alfanuméricos (`DULANGREV` + `202601`…`202605`), dentro do limite **8–32** da Edge Function `validate-access-code`.

---

## Link útil no repositório

Detalhes do fluxo de cupom: [`docs/ACCESS_CODES_SUPABASE.md`](ACCESS_CODES_SUPABASE.md).
