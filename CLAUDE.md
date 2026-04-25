# Dulang — Contexto do Projeto para Claude Code

## O que é o Dulang
App mobile para crianças de 0 a 5 anos assistirem vídeos em inglês selecionados pelo curador (o próprio desenvolvedor/pai). O objetivo é expor crianças ao inglês nativo de forma segura, sem distrações do YouTube, sem possibilidade de navegar para outros conteúdos.

Site: https://dulang.com.br
Instagram: @dulangoficial
YouTube: @DulangOficial

## Desenvolvedor
Carlos Siqueira — pai, desenvolvedor solo, experiência com Flutter, React Native, FlutterFlow, GitHub Actions. Trabalha com Cursor + Claude Code.

## Stack
- **Framework**: Flutter (Dart)
- **Banco de dados**: Supabase (substituindo SQLite local)
- **Assinaturas**: RevenueCat (in-app purchase, trial 7 dias)
- **Vídeos**: YouTube Data API v3 (sync automático por canal)
- **Player**: youtube_player_iframe
- **Estado**: Provider
- **Navegação**: go_router

## Package Names
- **Android**: `com.mycompany.dulang`
- **iOS**: (confirmar com o desenvolvedor)

## Repositório
- GitHub: `github.com/cwrsiqueira/dulang-app`
- Branch principal: `master`
- Sem FlutterFlow — desenvolvimento 100% no Cursor a partir de agora

## Deploy
- **Android**: GitHub Actions → Play Store Internal Test → promoção manual para produção
- **iOS**: Codemagic → TestFlight → App Store (a configurar)
- Workflow Android: `.github/workflows/deploy_android.yml`
- Versão atual em produção: build 30

## Secrets do GitHub Actions (Android)
- `KEYSTORE_BASE64` — keystore em base64
- `KEYSTORE_PASSWORD` — senha do keystore
- `KEY_ALIAS` — alias da chave
- `KEY_PASSWORD` — senha da chave
- `PLAY_STORE_JSON_KEY` — JSON da conta de serviço do Google Play

## Arquivos críticos (nunca sobrescrever sem atenção)
- `android/app/build.gradle` — applicationId e signingConfig
- `android/key.properties` — gerado no CI, não commitar
- `.github/workflows/deploy_android.yml` — workflow de deploy
- `pubspec.yaml` — dependency_overrides

## Modelo de negócio
- App gratuito na loja
- Assinatura mensal/anual via in-app purchase (RevenueCat)
- Trial gratuito de 7 dias
- Sem anúncios (público infantil)
- Tela de apresentação com vídeo do filho do desenvolvedor falando inglês

## Arquitetura planejada

### Backend (Supabase)
```
tabela: channels
- id, name, youtube_channel_id, active, created_at

tabela: videos
- id, youtube_video_id, channel_id, title, description
- thumbnail_default, thumbnail_high, published_at
- is_active, created_at
```

### App — estrutura de pastas
```
lib/
├── main.dart
├── app/
│   ├── app.dart           # MaterialApp + rotas
│   └── theme.dart         # cores, tipografia
├── features/
│   ├── auth/              # paywall + assinatura RevenueCat
│   ├── feed/              # feed de vídeos (principal)
│   ├── player/            # player YouTube
│   ├── parental/          # PIN parental, timer, horários
│   └── history/           # histórico + favoritos
├── services/
│   ├── supabase_service.dart
│   ├── revenue_cat_service.dart
│   └── youtube_sync_service.dart
└── shared/
    ├── widgets/
    └── models/
```

## Features planejadas

### Fase 1 — Base + aprovação Play Store
- [ ] Migração SQLite → Supabase
- [ ] YouTube Data API: sync automático por canal
- [ ] PIN parental para sair do app
- [ ] Tela de boas-vindas para pais
- [ ] Submissão correta como "Designed for Families"

### Fase 2 — Monetização
- [ ] RevenueCat: trial 7 dias + assinatura
- [ ] Paywall com vídeo de apresentação
- [ ] Conteúdo bloqueado sem assinatura ativa

### Fase 3 — Features de valor
- [ ] Controle de tempo de tela (horas por dia)
- [ ] Controle de horário (só libera em horários definidos)
- [ ] Histórico para os pais
- [ ] Múltiplos perfis de criança

## Decisões técnicas já tomadas
- Sem FlutterFlow — nunca mais fazer merge com branch gerada pelo FlutterFlow
- SQLite local será substituído por Supabase para permitir atualização de vídeos sem publicar nova versão do app
- RevenueCat para assinaturas (mais simples que implementar direto com Play Billing)
- Codemagic para build iOS (runner macOS gratuito até 500 min/mês)
- Branch master como única branch de trabalho

## Convenções de código
- Dart/Flutter padrão
- Nomes de arquivos em snake_case
- Nomes de classes em PascalCase
- Uma feature por pasta em lib/features/
- Services são singletons acessados via Provider ou get_it

## Observações importantes
- App destinado a crianças 0-5 anos: nenhum link externo, nenhuma navegação fora do app sem PIN parental
- O player de vídeo NÃO pode mostrar recomendações do YouTube, botão de compartilhar, ou qualquer elemento que permita sair para o YouTube
- Política de privacidade deve cobrir LGPD e COPPA (crianças)
- Sem anúncios de qualquer tipo
