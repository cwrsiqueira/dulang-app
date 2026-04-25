# Contexto: Rejeição da Play Store e Direcionamentos

## Por que o app foi rejeitado

O Dulang foi rejeitado pela Play Store na segunda ou terceira atualização com a seguinte mensagem:

**"Requisitos da Política para famílias: WebViews — Não são permitidos apps que coletam principalmente conteúdo que não pertence ao desenvolvedor."**

O Google exigiu:
- Comprovante de propriedade do conteúdo (ícone, nome do desenvolvedor, e-mail profissional)
- Funcionalidades adicionais além de apenas exibir conteúdo de terceiros
- Conformidade com as Políticas do programa para desenvolvedores

## O que é o Dulang (contexto essencial)

O Dulang **não é um agregador genérico de vídeos**. É um app criado por um pai (Carlos Siqueira) para seu filho de 4 anos assistir vídeos em inglês selecionados, sem as distrações do YouTube. O propósito é expor crianças de 0 a 5 anos ao inglês nativo de forma segura, sem possibilidade de navegar para outros conteúdos.

- Site: https://dulang.com.br
- Instagram: @dulangoficial  
- YouTube: @DulangOficial
- O desenvolvedor é o próprio curador do conteúdo

## Por que o Google rejeitou (análise real)

1. **Categoria errada** — o app não foi submetido corretamente como "Designed for Families (DFF)", que é o programa específico do Google para apps infantis
2. **App parecia um wrapper de YouTube** — o `youtube_player_iframe` e `webviewx_plus` ativam sinais de alerta de "webview spam"
3. **Sem valor agregado visível** — o revisor do Google não via diferença entre o Dulang e qualquer app que agrega vídeos do YouTube
4. **Sem identidade de curador** — nada no app comunicava que há um curador humano por trás escolhendo o conteúdo

## Decisões tomadas para resolver

### 1. Submissão correta como "Designed for Families"
- Declarar explicitamente no Play Console faixa etária 0-5 anos
- Garantir política de privacidade cobrindo LGPD e COPPA (dados de crianças)
- Sem SDKs que coletam dados não aprovados pelo programa DFF
- Sem anúncios de qualquer tipo (já ok — modelo é assinatura)

### 2. Features que provam que é uma ferramenta parental legítima
Precisam ser implementadas para demonstrar valor além de "wrapper de YouTube":

- **PIN parental** — pais configuram PIN de 4 dígitos para sair do app. Demonstra tecnicamente que é ferramenta parental, não entretenimento genérico
- **Tela de boas-vindas para pais** — na primeira abertura, explicar o propósito do app ANTES de entregar para a criança
- **Controle de tempo de tela** — limitar horas por dia ou por sessão
- **Controle de horário** — só libera o app em horários definidos pelos pais
- **Histórico para os pais** — relatório do que foi assistido

### 3. Identidade editorial forte dentro do app
- Tela "Sobre o Dulang" contando a história do pai que criou para o filho
- Nome do curador, foto, e-mail profissional visível
- A curadoria é por **canal**, não por vídeo individual — isso precisa ser comunicado

### 4. Player sem elementos do YouTube
O player de vídeo NÃO pode mostrar:
- Recomendações do YouTube
- Botão de compartilhar
- Link para abrir no YouTube
- Qualquer elemento que permita sair para o YouTube

### 5. Migração do banco de dados
- **Problema atual**: vídeos ficam indisponíveis e precisam ser trocados manualmente (URLs hardcoded no SQLite)
- **Solução**: Supabase + YouTube Data API v3
  - Carlos cura **canais**, não vídeos individuais
  - O sistema busca automaticamente novos vídeos dos canais curados
  - Vídeos indisponíveis são detectados e removidos automaticamente
  - Sem precisar publicar nova versão do app para atualizar conteúdo

### 6. Monetização
- **Modelo**: assinatura mensal/anual via RevenueCat
- **Trial**: 7 dias gratuitos
- **Paywall**: tela com vídeo do filho do Carlos falando inglês (prova do conceito)
- Conteúdo bloqueado sem assinatura ativa
- **Sem anúncios** — público infantil, modelo de assinatura é o correto

## Arquitetura para resolver os problemas

### Backend (Supabase)
```
tabela: channels
- id, name, youtube_channel_id, active, created_at

tabela: videos  
- id, youtube_video_id, channel_id, title, description
- thumbnail_default, thumbnail_high, published_at
- is_active, created_at
```

### Fluxo de curadoria
1. Carlos adiciona canais no painel Supabase
2. Cron job (ou função Edge do Supabase) busca novos vídeos via YouTube Data API v3
3. App busca vídeos do Supabase (não mais do SQLite local)
4. Vídeos indisponíveis são marcados como `is_active = false` automaticamente

### Estrutura do app
```
lib/
├── main.dart
├── app/
│   ├── app.dart           # MaterialApp + rotas
│   └── theme.dart         # cores, tipografia
├── features/
│   ├── auth/              # paywall + assinatura RevenueCat
│   ├── feed/              # feed de vídeos (principal)
│   ├── player/            # player YouTube SEM elementos de navegação
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

## Prioridade de implementação

### Fase 1 — Aprovação na Play Store (URGENTE)
1. [ ] PIN parental para sair do app
2. [ ] Tela de boas-vindas para pais (primeira abertura)
3. [ ] Player sem botões de compartilhar/abrir no YouTube
4. [ ] Tela "Sobre o Dulang" com história do curador e e-mail profissional
5. [ ] Migração SQLite → Supabase
6. [ ] YouTube Data API: sync automático por canal
7. [ ] Política de privacidade cobrindo LGPD e COPPA
8. [ ] Submissão correta como "Designed for Families" no Play Console

### Fase 2 — Monetização
1. [ ] RevenueCat: trial 7 dias + assinatura
2. [ ] Paywall com vídeo de apresentação do filho falando inglês
3. [ ] Conteúdo bloqueado sem assinatura ativa

### Fase 3 — Features de valor (justificam a assinatura)
1. [ ] Controle de tempo de tela (horas por dia)
2. [ ] Controle de horário (só libera em horários definidos)
3. [ ] Histórico detalhado para os pais
4. [ ] Múltiplos perfis de criança

## Observações críticas para o desenvolvedor

- App destinado a crianças 0-5 anos: **nenhum link externo, nenhuma navegação fora do app sem PIN parental**
- O player de vídeo é o ponto mais crítico para a aprovação — deve ser completamente isolado do ecossistema YouTube
- A política de privacidade deve mencionar explicitamente que o app é direcionado para crianças e que não coleta dados pessoais delas
- O e-mail de contato profissional deve estar visível dentro do app (exigência do Google para DFF)
- Sem FlutterFlow — todo desenvolvimento é feito no Cursor com Claude Code
