# Passo a passo: conta, assinatura e lojas (bem simples)

Este guia é para **quem vai fazer funcionar de verdade** no dia a dia: criar a assinatura nas lojas, ligar ao serviço que o app usa para saber se a família pagou, e conferir a conta dos pais. O texto evita siglas desnecessárias; quando um nome próprio de site aparece, é porque o app já está preparado para trabalhar com ele.

**Não substitui** o guia técnico resumido em `docs/ai-context/current-status.md` — aqui o foco é **ordem prática** e linguagem direta.

---

## Antes de começar: duas coisas principais

1. **Assinatura (pagamento todo mês ou por ano)**  
   Quem cobra é a **Google Play** (Android) ou a **App Store** (iPhone). O app **não** inventa preço sozinho: ele mostra o que a loja mandar. Quem paga já tem uma **conta na loja** (Google ou Apple); é ela que “segura” a compra quando a família troca de celular ou reinstala — use **Restaurar compras** no app com a **mesma conta da loja**.

2. **O “intermediário” que o app pergunta “está pago?”**  
   O projeto usa o **RevenueCat**: ele conversa com a Play e com a Apple e devolve para o app um “sim/não” para o acesso premium. No código o identificador do entitlement é **`dulang_premium_entitlement`** (`SubscriptionConstants` / RevenueCat) — precisa ser **exatamente** esse no painel do RevenueCat, igual no app.

O app **não exige login com e-mail no Dulang** para assistir ou para assinar: menos fricção para a família. (Se no futuro você quiser conta na nuvem só para preferências, isso é outro passo — opcional.)

---

## Parte 1 — Supabase (só se você ainda usar para outra coisa)

O projeto pode continuar com **Supabase** ligado no app para dados no servidor (ex.: vídeos). **Não** é mais obrigatório configurar “login do app” para o fluxo de assinatura descrito abaixo. Se o painel do Supabase tiver Auth ligado sem uso, pode deixar desligado ou ignorar para este roteiro.

---

## Parte 2 — Assinatura na Google Play (Android)

1. Entre no **Google Play Console** com a conta do app.
2. Vá em **Monetização** / **Produtos** / **Assinaturas** (o caminho exato pode mudar um pouco, mas a ideia é “criar assinatura”).
3. Crie **duas** assinaturas (ou uma base com dois planos, conforme o modelo da Play):
   - uma **mensal**;
   - uma **anual**.
4. Configure o **período de teste grátis** de **7 dias** (combinado com o produto).
5. Publique (ou deixe em rascunho testável com lista de testadores internos, conforme a política da Play).
6. Anote os **IDs** dos produtos (códigos que a Play gera) — você vai colá-los no RevenueCat.

Repita a lógica equivalente na **App Store Connect** para iPhone: assinaturas mensal e anual, teste grátis, IDs.

---

## Parte 2b — A “autorização” que liga a Play ao RevenueCat (Android)

Não existe um botão único com esse nome na Play; o que o **RevenueCat** precisa é **acesso de leitura/gestão** à **Google Play Developer API** usando uma **conta de serviço** (arquivo JSON). Sem isso, o painel do RevenueCat não consegue validar assinaturas nem sincronizar compras.

Resumo do fluxo (detalhe visual no checklist oficial do RevenueCat: *Creating Play Service Credentials*):

1. **Google Cloud Console** (projeto ligado à mesma organização que faz sentido para vocês): ative a API **Google Play Android Developer** (e o que o assistente do RevenueCat pedir, por exemplo *Developer Reporting*).
2. Crie uma **conta de serviço**, gere chave **JSON** e baixe o arquivo (guarde como segredo; não commite no Git).
3. **Google Play Console** → **Usuários e permissões** → **Convidar usuário** com o **e-mail da conta de serviço** (`algo@projeto.iam.gserviceaccount.com`). Conceda as permissões que o RevenueCat lista (em geral incluem **ver dados financeiros / pedidos** e **gerenciar pedidos e assinaturas** — siga a lista atual do assistente, pois os nomes mudam às vezes).
4. **Primeiro upload do app**: publique pelo menos um **Android App Bundle (AAB)** assinado em uma trilha (**teste interno** ou **fechado**) com o **mesmo ID do aplicativo** (`applicationId`) que está no app. Isso “materializa” o app na Play e destrava criação/associação de produtos de forma estável.
5. No **RevenueCat** → projeto → app **Android** → credenciais da Play: **envie o JSON** da conta de serviço.
6. **Paciência**: a Google costuma levar **até cerca de 36 horas** para credenciais novas passarem a responder direito na API; erros temporários de “credencial inválida” podem aparecer nesse período.

**Chave pública do RevenueCat (Android)** — é outra coisa: é a string **API Key** do *SDK* que o app usa no `Purchases.configure` (hoje: `REVENUECAT_ANDROID_KEY` em `environment_values` ou `--dart-define`). Ela **não** substitui o JSON da conta de serviço; são duas peças: **app fala com RC (chave pública)** e **servidores do RC falam com a Play (JSON)**.

### Permissão `com.android.vending.BILLING`

**Não precisa** colocar essa linha no `AndroidManifest.xml` do app à mão. O **Play Billing Library** (puxado pelo pacote `purchases_flutter`) declara a permissão no manifesto da biblioteca; o Gradle **mescla** tudo no AAB final. Na prática, a Play já enxerga billing no pacote que tem a biblioteca correta.

---

## Parte 2d — Deploy do AAB pela GitHub Actions (trilha Teste interno)

No repositório existe o workflow **Deploy Android to Internal Test** (arquivo `.github/workflows/deploy_android.yml`).

**Quando roda**

- Automaticamente em cada **push** na branch **`master`**.
- Ou **manual**: GitHub → **Actions** → **Deploy Android to Internal Test** → **Run workflow** (precisa da opção `workflow_dispatch` no YAML — está habilitada).

**O que o job faz**

- `flutter pub get`, ícones, `flutter build appbundle --release` com ofuscação e `--dart-define=YOUTUBE_API_KEY=…` (segredo do GitHub).
- Envia o `.aab` para a Play na trilha **internal** (teste interno), pacote **`com.mycompany.dulang`**, usando a action `r0adkll/upload-google-play`.

**Secrets obrigatórios no GitHub** (Settings → Secrets and variables → Actions)

| Secret | Uso |
|--------|-----|
| `KEYSTORE_BASE64` | Keystore `.jks` codificado em Base64 (uma linha). |
| `KEYSTORE_PASSWORD` | Senha do keystore. |
| `KEY_PASSWORD` | Senha da chave de assinatura. |
| `KEY_ALIAS` | Alias da chave. |
| `YOUTUBE_API_KEY` | Passada no build; o `environment.json` versionado deixa essa chave vazia no repo. |
| `PLAY_STORE_JSON_KEY` | JSON da **conta de serviço** com permissão na Play Console para **publicar** na trilha (API Google Play Android Developer). Pode ser o mesmo projeto/conta usada no RevenueCat **se** essa conta tiver também os papéis de upload — ou um JSON separado, conforme a organização. |

Depois que o upload concluir, abra a **Play Console** → app Dulang → **Teste interno** (ou equivalente) e confira a nova versão. Com o app já publicado em uma trilha, a criação de **assinaturas** e IDs de produto costuma ficar estável (alinhado ao passo 4 da Parte 2b).

### Opt-in do teste interno e erro “Item not found” na Play Store

- Use o link copiado de **Teste interno → Testadores** (opt-in). Instale/atualize **pela Play Store** após aceitar.
- Em **Configurações → Teste de licença**, a lista de e-mails precisa estar **marcada (checkbox) + Salvar alterações** — senão a compra tende a não entrar no fluxo de licensed tester.
- Se uma conta Google listada cair em **Item not found** mesmo com release **Disponível para testers**, veja o roteiro em [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](CHECKLIST_TESTE_SANDBOX_PLAY.md) (seção 8).

Contexto técnico resumido também em `docs/ai-context/engineering-rules.md` (arquivo sensível: `deploy_android.yml`).

---

## Parte 2c — Avisos da Play que vocês citaram (Famílias, 16 KB, API 35)

### Política para famílias — WebViews / conteúdo de terceiros

A mensagem costuma aparecer quando a Play classifica o app como **agregador** de conteúdo de terceiros (ex.: YouTube embutido). Para **não ser bloqueado de novo**, alinhem **produto + loja + evidência**:

- **Ficha do app (Play Console):** descrição clara de que o Dulang é **curadoria** de vídeos em inglês para crianças, **ambiente fechado**, **sem navegação web livre** para a criança, **sem anúncios** no app.
- **Contato profissional:** e-mail de suporte visível e respondido (a própria política cita isso como sinal de operação séria).
- **Propriedade / valor agregado:** se a Play pedir comprovante, juntar **marca** (ícone, nome), **política de privacidade** atualizada e **capturas de tela** do fluxo (PIN parental, player sem sair para o browser, etc.).
- **Técnico:** o app já restringe navegação no player (YouTube iframe); evitem qualquer WebView genérica com URL aberta. Manter dependências do player atualizadas ajuda em auditoria.

**Texto real da última reprovação (Play Console, 2026-03-02):** a Play aplicou **Requisitos da Política para famílias: WebViews** com a justificativa de que **não são permitidos apps que coletam principalmente conteúdo que não pertence ao desenvolvedor**, e pede remoção e/ou **prova de titularidade** (marca + contato profissional) e/ou **mais funcionalidades** para não ser apenas um invólucro de vídeo de terceiros. Registro canônico no repositório: `docs/ai-context/decisions-log.md` (entrada **2026-03-02**).

### API 35 (Android 15) — nível desejado da API

No repositório, o módulo Android do app já está com **`targetSdkVersion` 36** em `android/app/build.gradle` (acima do mínimo 35). O que importa na prática é **subir um AAB novo** gerado deste projeto para a faixa de produção (o aviso some quando a versão ativa deixa de ser um pacote antigo com `targetSdk` 34).

### Páginas de memória de 16 KB

A Play exige que binários com bibliotecas nativas (`.so`) sejam compatíveis com dispositivos de **página de 16 KB**. O projeto usa **NDK r28** e **AGP 8.9** — boa base. Passos práticos:

1. Atualizar **Flutter** e dependências (`flutter pub upgrade`), depois `flutter clean` e `flutter build appbundle --release`.
2. Enviar o **novo AAB** e verificar no **Play Console** (explorador do pacote / verificações pré-lançamento) se o alerta some.
3. Se o aviso continuar, a causa costuma ser **alguma biblioteca nativa antiga** (plugins); subir versões dos plugins ou do Flutter resolve na maioria dos casos.

---

## Parte 3 — RevenueCat (ligar as lojas ao app)

1. Crie um projeto no site do **RevenueCat** (se ainda não existir).
2. **Android (Play) — agora:** siga a **Parte 2b** (JSON da conta de serviço). **iPhone:** fica para depois, como combinado — App Store Connect + credenciais Apple no RevenueCat quando for a vez.
3. Crie um **direito** (no painel eles chamam de *entitlement*) com o identificador **`dulang_premium_entitlement`**. Tem que bater com o app.
4. Crie uma **oferta padrão** (*default offering*) e coloque **dois pacotes**: um ligado à assinatura **mensal** e outro à **anual** (os IDs que você anotou na Play / Apple).
5. **Chave pública do SDK (Android):** copie a **Public API Key** do app Android no RevenueCat e coloque no build (`REVENUECAT_ANDROID_KEY` em `assets/environment_values/environment.json` no ambiente que vocês usam, ou `--dart-define=REVENUECAT_ANDROID_KEY=...` no CI — **não** commitem chaves em repositório público).

---

## Parte 4 — No celular de teste

1. Instale o app **pelo jeito que a loja exige** para testar compra (lista interna, TestFlight, etc.).
2. Faça login com a **conta de teste** da loja (não use o cartão real da família nos testes).
3. Abra o app, vá em **Dulang Premium** (ou onde o paywall aparecer) e faça uma **compra de teste**.
4. Use **“Restaurar compras”** (ou o botão equivalente na tela) e confira se o catálogo **destrava**.
5. Repita depois de **sair da conta** no app e entrar de novo — o app deve associar a compra ao mesmo usuário.

---

## Parte 5 — PIN dos pais (esqueci / trocar)

- O PIN parental do Dulang fica **guardado no aparelho** (não é enviado por e-mail).
- Para **trocar** o PIN em **Ajustes**, o app pede **biometria ou o PIN de desbloqueio do próprio celular** — assim o adulto confirma no aparelho sem precisar lembrar o PIN antigo do Dulang.
- Se a pessoa **não** conseguir nem o PIN do Dulang nem desbloquear o aparelho, na prática a saída continua sendo **apagar os dados do app** nas configurações do sistema (apaga PIN e perfis locais), ou suporte humano em último caso.

Explique isso em qualquer FAQ para pais, para evitar frustração.

---

## Se algo der errado

- **Catálogo continua bloqueado depois de pagar:** confira se o entitlement no RevenueCat é **`dulang_premium_entitlement`**, se a oferta padrão tem os dois pacotes, se o **JSON da Play** está válido no RevenueCat, e se a compra de teste foi feita com a **mesma conta Google** da Play no aparelho; use **Restaurar compras** no app.
- **Só Android funciona:** iOS precisa da chave pública do iOS no build e produto criado na Apple.
- **Erro na loja:** quase sempre é produto ainda em rascunho, app assinado com outra conta, ou testador não autorizado.

---

## Onde está o guia “só do YouTube no banco”?

Para atualizar vídeos e canais no servidor, use o outro passo a passo simples: **`docs/PASSO_A_PASSO_SYNC_YOUTUBE_SUPABASE.md`**.

---

*Última revisão: entitlement RevenueCat `dulang_premium_entitlement`; Parte 2d (GitHub Actions → teste interno); checklist sandbox Play (`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`); opt-in interno + “Item not found”; recusa Play **Famílias/WebViews** (2026-03-02) registrada em `docs/ai-context/decisions-log.md`; BILLING; Parte 2b/2c; troubleshooting sem login obrigatório.*  
