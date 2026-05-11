# Credenciais GitHub Actions (secrets do CI)

Este guia descreve **onde obter** ou **como gerar** os secrets usados pelos workflows de release, na **ordem recomendada** (dependências: app → Apple Developer → App Store Connect). Os valores **não** entram no repositório: ficam em **GitHub → repositório → Settings → Secrets and variables → Actions**.

**Workflows que consomem estes nomes**

- Android: [`.github/workflows/deploy_android.yml`](../.github/workflows/deploy_android.yml)
- iOS: [`.github/workflows/deploy_ios.yml`](../.github/workflows/deploy_ios.yml)

**Fora desta lista (Android):** o deploy na Play também usa `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` e `PLAY_STORE_JSON_KEY` — veja a Parte 2d em [`docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`](PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md).

---

## Segurança

- Não commite arquivos com chaves; `environment.json` local costuma estar no `.gitignore`.
- Se um secret vazar, **revogue** na origem (Google, Apple, RevenueCat, Supabase) e **gere outro**; atualize o GitHub.
- O arquivo **`.p8`** da App Store Connect API **só pode ser baixado uma vez** na criação da chave. Perdeu = crie **nova** chave e atualize os três secrets da API.

---

## Tabela resumo

| Secret | Formato no GitHub | Usado em |
|--------|-------------------|----------|
| `ENVIRONMENT_JSON` | Base64 do arquivo JSON inteiro | Android e iOS |
| `YOUTUBE_API_KEY` | Texto (chave da API) | Android e iOS |
| `REVENUECAT_IOS_KEY` | Texto (chave pública iOS) | Só iOS |
| `APPLE_TEAM_ID` | Texto (10 caracteres) | Só iOS |
| `APPLE_CERTIFICATE_P12_BASE64` | Base64 do arquivo `.p12` | Só iOS |
| `APPLE_CERTIFICATE_PASSWORD` | Texto (senha do `.p12`) | Só iOS |
| `KEYCHAIN_PASSWORD` | Texto (qualquer senha forte) | Só iOS |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Base64 do `.mobileprovision` | Só iOS |
| `APPLE_API_KEY_ID` | Texto (Key ID, 10 caracteres) | Só iOS |
| `APPLE_API_ISSUER_ID` | Texto (UUID do Issuer) | Só iOS |
| `APPLE_API_PRIVATE_KEY` | Texto PEM **ou** base64 do `.p8` | Só iOS |

---

## 1. `ENVIRONMENT_JSON`

**O que é:** conteúdo do arquivo local [`assets/environment_values/environment.json`](../assets/environment_values/environment.json) (normalmente **não** versionado). O CI grava o JSON decodificado antes do `flutter pub get`.

**Como montar o secret**

1. Use um `environment.json` válido do seu ambiente (Supabase URL/anon key, chaves RevenueCat Android se aplicável, etc.).
2. Codifique o **arquivo inteiro** em Base64 **uma linha**, sem quebras.

**PowerShell (Windows)**

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("assets\environment_values\environment.json")) | Set-Clipboard
```

**macOS / Linux**

```bash
base64 -i assets/environment_values/environment.json | tr -d '\n'
# Em alguns Linux com GNU coreutils:
# base64 -w0 assets/environment_values/environment.json
```

3. Cole o resultado no secret **`ENVIRONMENT_JSON`**.

---

## 2. `YOUTUBE_API_KEY`

**O que é:** chave da **YouTube Data API v3** (Google Cloud).

**Onde obter**

1. [Google Cloud Console](https://console.cloud.google.com/) → projeto com YouTube Data API v3 habilitada.
2. **APIs e serviços → Credenciais** → criar chave de API; restrinja por app (bundle iOS / pacote Android) quando possível.

**No GitHub:** cole o valor em **texto puro** (não Base64). O workflow injeta com `--dart-define=YOUTUBE_API_KEY=…` no build.

---

## 3. `REVENUECAT_IOS_KEY`

**O que é:** chave **pública** do SDK RevenueCat para o app **iOS** (não use a chave do Android aqui).

**Onde obter**

1. [RevenueCat](https://app.revenuecat.com/) → seu projeto → app **iOS** → **Public API key**.

**No GitHub:** texto puro no secret **`REVENUECAT_IOS_KEY`**. Usada apenas no workflow iOS.

---

## 4. `APPLE_TEAM_ID`

**O que é:** identificador do time na Apple (10 caracteres, ex.: `ABCDE12345`).

**Onde obter**

1. [Apple Developer](https://developer.apple.com/account) → **Membership details** / **Account** → **Team ID**.

**Uso no CI:** substitui o placeholder no [`ios/ExportOptions.plist`](../ios/ExportOptions.plist) no passo de patch do workflow. Necessário para alinhar CSR, certificados e perfis de provisionamento.

---

## 5. `APPLE_CERTIFICATE_P12_BASE64` e `APPLE_CERTIFICATE_PASSWORD`

**O que é:** certificado de **distribuição** iOS (Apple Distribution / iPhone Distribution) exportado como **PKCS12** (`.p12`) e a senha definida na exportação.

**Ordem típica**

1. Gerar um **CSR** (Certificate Signing Request): no **Mac**, pelo Acesso às Chaves; no **Windows**, com **OpenSSL** (fluxo que o time já usou para assinar no CI).
2. [Apple Developer](https://developer.apple.com/account/resources/certificates/list) → **Certificates** → criar certificado **Apple Distribution** (ou equivalente) usando esse CSR.
3. Baixar o `.cer`, importar no Keychain (Mac) ou encadear com a chave privada gerada no OpenSSL até formar o par exportável.
4. Exportar **My Certificates** → certificado de distribuição + chave privada → formato **`.p12`**, definindo uma **senha de exportação** → essa senha vira **`APPLE_CERTIFICATE_PASSWORD`**.
5. Codificar o `.p12` em Base64 (uma linha), como no passo 1, e colar em **`APPLE_CERTIFICATE_P12_BASE64`**.

**No CI:** o workflow faz `base64 --decode` do P12 e importa no keychain temporário com a senha do segundo secret.

Contexto leigo complementar: [`docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`](PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md) (Parte 2b/2c e lojas).

---

## 6. `KEYCHAIN_PASSWORD`

**O que é:** senha **qualquer**, forte, **inventada por você** só para o keychain **efêmero** criado no runner do GitHub Actions.

**Não** vem da Apple. Pode ser definida quando for cadastrar os secrets do iOS. O workflow cria o arquivo de keychain com essa senha e importa o `.p12` nele.

---

## 7. `APPLE_PROVISIONING_PROFILE_BASE64`

**O que é:** perfil de provisionamento **App Store** (Distribuição na loja) que inclui o **App ID** correto (ex.: `com.carlosdev.dulang`) e o **certificado de distribuição** do passo 5.

**Onde obter**

1. [Apple Developer](https://developer.apple.com/account/resources/profiles/list) → **Profiles** → **+** → **App Store** → selecione App ID e o certificado de distribuição.
2. Baixe o arquivo **`.mobileprovision`**.
3. Codifique em Base64 (uma linha) e cole em **`APPLE_PROVISIONING_PROFILE_BASE64`**.

**Importante:** o **nome** do perfil na Apple deve coincidir com o que está em `ios/ExportOptions.plist` (`provisioningProfiles` por bundle) e com `PROVISIONING_PROFILE_SPECIFIER` no Xcode (Release), senão o archive falha na assinatura.

---

## 8. `APPLE_API_KEY_ID`, `APPLE_API_ISSUER_ID` e `APPLE_API_PRIVATE_KEY`

**O que é:** credenciais da **App Store Connect API** para o **fastlane pilot** subir o `.ipa` ao TestFlight (JWT). Não confundir com o Team ID do Developer.

**Onde obter**

1. [App Store Connect](https://appstoreconnect.apple.com/) → **Users and Access** → **Integrations** → **App Store Connect API**.
2. Anote o **Issuer ID** (UUID no topo da área de chaves) → secret **`APPLE_API_ISSUER_ID`** (**não** é o `APPLE_TEAM_ID`).
3. **Generate API Key** (ou equivalente) com papel **App Manager** ou **Admin** (só **Developer** costuma ser insuficiente para upload de build).
4. Copie o **Key ID** (10 caracteres) → **`APPLE_API_KEY_ID`** (tem que ser o **mesmo** ID do arquivo `AuthKey_XXXXXXXXXX.p8` que você baixa).
5. Baixe o **`.p8` uma única vez** → conteúdo vai em **`APPLE_API_PRIVATE_KEY`**:
   - **Preferência:** colar o PEM completo (`-----BEGIN PRIVATE KEY-----` … `-----END PRIVATE KEY-----`).
   - **Alternativa:** colar o arquivo `.p8` inteiro codificado em Base64 (uma linha); o workflow iOS aceita os dois formatos e valida com `openssl`.

**Conferências frequentes**

- **Issuer ID** copiado da página de **API Keys** da App Store Connect, não do portal Developer.
- **Key ID** exatamente igual ao do par `.p8` (erro comum: trocar de chave no portal e não atualizar o ID no GitHub).

---

## Ordem sugerida de cadastro (checklist)

1. `ENVIRONMENT_JSON`  
2. `YOUTUBE_API_KEY`  
3. `REVENUECAT_IOS_KEY`  
4. `APPLE_TEAM_ID`  
5. `APPLE_CERTIFICATE_P12_BASE64` + `APPLE_CERTIFICATE_PASSWORD`  
6. `KEYCHAIN_PASSWORD`  
7. `APPLE_PROVISIONING_PROFILE_BASE64`  
8. `APPLE_API_KEY_ID` + `APPLE_API_ISSUER_ID` + `APPLE_API_PRIVATE_KEY`  

Depois disso, rode o workflow **Deploy iOS to TestFlight** manualmente em **Actions** (não dispara no `push` por padrão). Para **não** rodar o deploy Android ao dar `push` na `master` com só mudanças de doc/config, use **`[skip ci]`** na mensagem do commit — veja [`docs/ai-context/engineering-rules.md`](ai-context/engineering-rules.md).

---

## CI iOS: runner e Xcode (SDK para upload)

A App Store Connect pode recusar o IPA com erro do tipo **“built with the iOS 18.x SDK … must be built with the iOS 26 SDK or later, Xcode 26 or later”**. Isso não é secret: é a **imagem do runner** e o **Xcode** usados no [`.github/workflows/deploy_ios.yml`](../.github/workflows/deploy_ios.yml).

- O job usa **`runs-on: macos-26`** e seleciona **`Xcode_26.4.1`** antes do `flutter build ipa`, para compilar com o **SDK iOS 26** exigido no envio.
- Se o GitHub alterar caminhos na imagem, consulte a documentação atual da imagem **macOS 26**: [runner-images — macos-26-Readme.md](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md) (tabela de versões do Xcode em `/Applications/`).

---

*Documento operacional; detalhes de produto e roadmap permanecem em `docs/ai-context/`.*
