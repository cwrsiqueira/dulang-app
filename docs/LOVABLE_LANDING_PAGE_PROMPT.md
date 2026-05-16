# Prompt — Landing Page Dulang (Lovable)

Prompt completo para gerar a landing page de marketing, vendas, captação de leads e suporte do Dulang no Lovable.
Inclui: 3 idiomas (pt-BR / en / es), detecção automática de idioma, SEO multilíngue, funil de vendas, captação de leads (Brevo), formulário de contato, páginas de Política de Privacidade e Termos de Uso.

**Status atual do app:** em revisão final pelas lojas (App Store e Google Play). CTAs de download substituídos por captação de leads por enquanto. Após aprovação nas lojas, os botões de download serão adicionados, mas o formulário de captação de leads permanece para remarketing e lista de divulgação futura.

---

```
Build a high-converting, SEO-optimized, multilingual marketing and lead capture landing page for "Dulang" — a Brazilian children's English learning app for ages 0–5.

IMPORTANT — APP STATUS: The app is currently under final review by the App Store and Google Play. It is NOT yet publicly available. Therefore:
- All "Download" / "Baixar" CTAs must be replaced by a lead capture form ("Notify me when it launches")
- The hero and pricing sections show a "Coming soon" badge instead of store buttons
- After the app is approved and store links are provided, the store buttons will be added — but the lead capture form MUST remain on the page permanently (for remarketing, upsell, and future app launches)

The page must support 3 languages: Brazilian Portuguese (pt-BR), English (en), and Spanish (es), with automatic browser language detection and a manual language switcher button.

---

## BRAND ASSETS (provided)

Logo with text: [ATTACH: dulang1.png]
Logo icon only: [ATTACH: favicon_transparente.png]
Feature graphic / banner: [ATTACH: feature_graphic_1024x500.png]
Brand color guide: [ATTACH: icon_512x512.png — extract palette from this]

Brand colors (extracted from logo):
- Primary teal: #19B8AA (mint/teal — the cloud color)
- Dark outline: #1A3A3A (near-black dark teal)
- Accent pink: #F9A8B8 (cheeks pink)
- Accent yellow/gold: used for stars and accents
- Background: white / very light mint (#F0FAFA)
- CTA color: warm coral #FF6B5B
- Coming soon badge: amber #F59E0B

Typography: Nunito (Google Fonts) — rounded, child-friendly, highly legible (weights 400, 600, 700, 800)
Icons: Lucide React

---

## INTERNATIONALIZATION (i18n) REQUIREMENTS

### Language detection & routing:
- On first visit, auto-detect `navigator.language` (or `navigator.languages[0]`):
  - `pt`, `pt-BR`, `pt-PT` → load pt-BR version (default)
  - `es`, `es-*` (any Spanish locale) → load es version
  - anything else → load en version
- URL structure for SEO:
  - `/` → pt-BR (canonical default)
  - `/en/` → English
  - `/es/` → Spanish
  - `/obrigado` | `/en/thank-you` | `/es/gracias` → thank you page after lead capture
  - `/contato` | `/en/contact` | `/es/contacto` → contact page
  - `/politica-de-privacidade` | `/en/privacy-policy` | `/es/politica-de-privacidad` → privacy policy
  - `/termos-de-uso` | `/en/terms-of-use` | `/es/terminos-de-uso` → terms of use
- When the user manually switches language, update URL and store preference in `localStorage`

### Language switcher UI:
- Top-right corner of the sticky navbar, next to the notify CTA
- Three flags side by side: 🇧🇷 PT | 🇺🇸 EN | 🇪🇸 ES
- Active: filled teal pill with white text; inactive: transparent + dark text
- Mobile: collapse to single flag icon + dropdown

### SEO for all 3 languages:
- `<html lang="...">` attribute updates dynamically per language
- Separate `<title>` and `<meta name="description">` per language
- hreflang link tags in `<head>` for all 3 + x-default:
  <link rel="alternate" hreflang="pt-BR" href="https://dulang.com.br/" />
  <link rel="alternate" hreflang="en" href="https://dulang.com.br/en/" />
  <link rel="alternate" hreflang="es" href="https://dulang.com.br/es/" />
  <link rel="alternate" hreflang="x-default" href="https://dulang.com.br/" />
- Open Graph og:locale and og:locale:alternate per language
- og:image using the feature graphic (1024x500) — serve a 1200x630 crop
- JSON-LD MobileApplication schema in all 3 languages
- Canonical URL per language version
- robots.txt allowing all paths
- sitemap.xml with all language URLs including inner pages

---

## BREVO INTEGRATION (lead capture)

### Configuration:
- Brevo API Key: [BREVO_API_KEY — operator will provide when deploying]
- Brevo List ID: 10
- Endpoint: POST https://api.brevo.com/v3/contacts
- Store the API key in an environment variable: VITE_BREVO_API_KEY (never hardcode in source)

### Lead capture request body:
{
  "email": "<user email>",
  "listIds": [10],
  "attributes": {
    "LANGUAGE": "<pt-BR | en | es — active language at time of signup>",
    "SOURCE": "landing-page",
    "OPT_IN": true
  },
  "updateEnabled": true
}

### Contact form transactional email:
- Also use Brevo to send transactional email
- Endpoint: POST https://api.brevo.com/v3/smtp/email
- When contact form is submitted, send email TO: contato@carlosdev.com.br
- Subject: "Nova mensagem via site Dulang — [visitor name]"
- Template (HTML): include all form fields (name, email, message, language)
- Environment variable: VITE_BREVO_API_KEY (same key)

### Double opt-in (Brevo):
- After the lead submits their email, Brevo automatically sends a confirmation email asking them to verify their address before being added to the list.
- To enable: in Brevo dashboard → Contacts → Lists → List 10 → Settings → enable "Double opt-in". Create a simple confirmation email template in Brevo.
- The confirmation email subject (configure in Brevo):
  - pt-BR: "Confirme seu email para receber as novidades do Dulang"
  - en: "Confirm your email to get Dulang updates"
  - es: "Confirma tu email para recibir novedades de Dulang"
- After confirmation, Brevo shows a success page. Configure this redirect URL in Brevo to: dulang.com.br/obrigado (or /en/thank-you / /es/gracias based on browser language at time of signup — store in the attribute LANGUAGE sent to Brevo)
- Note: with double opt-in enabled, the user is NOT added to the list until they click the confirmation link. This improves deliverability and is LGPD/GDPR best practice.

### LGPD consent (required on ALL forms):
- Checkbox (unchecked by default, required to submit):
  - pt-BR: "Concordo em receber comunicações do Dulang por email. Você pode cancelar a qualquer momento. Veja nossa Política de Privacidade."
  - en: "I agree to receive communications from Dulang by email. You can unsubscribe at any time. See our Privacy Policy."
  - es: "Acepto recibir comunicaciones de Dulang por email. Puedes cancelar en cualquier momento. Ver Política de Privacidad."
- "Política de Privacidade" / "Privacy Policy" / "Política de Privacidad" must be a clickable link to the privacy policy page

### Spam protection:
- Add a hidden honeypot field (name="website", hidden via CSS) — if filled, reject the submission silently
- Rate limit: disable submit button for 3 seconds after click

---

## META TAGS (per language)

**pt-BR:**
- title: "Dulang — App de Inglês para Crianças | Em breve na App Store e Google Play"
- description: "Seja avisado quando o Dulang chegar: o app de inglês para bebês e crianças de 0 a 5 anos com vídeos curados, controle parental e sem anúncios."
- keywords: "app inglês criança, ensinar inglês bebê, app educativo infantil seguro, controle parental, bilinguismo infantil, em breve"

**en:**
- title: "Dulang — English Learning App for Kids | Coming Soon to App Store & Google Play"
- description: "Get notified when Dulang launches: the English app for babies and children ages 0–5 with curated videos, parental controls, and no ads."
- keywords: "english app for kids, teach english toddlers, safe educational app children, parental control kids app, bilingual children, coming soon"

**es:**
- title: "Dulang — App de Inglés para Niños | Próximamente en App Store y Google Play"
- description: "Sé el primero en saber cuando llegue Dulang: la app de inglés para bebés y niños de 0 a 5 años con videos curados, control parental y sin anuncios."
- keywords: "app inglés niños, enseñar inglés bebés, app educativa infantil segura, control parental niños, niños bilingues, próximamente"

---

## LANDING PAGE SECTIONS

### SECTION 1 — STICKY NAVIGATION BAR

- Logo (left): dulang1.png
- Menu links:
  pt-BR: Funcionalidades | Como funciona | Depoimentos | Seja avisado | Contato
  en: Features | How it works | Testimonials | Get notified | Contact
  es: Funcionalidades | Cómo funciona | Testimonios | Avísame | Contacto
- Language switcher: 🇧🇷 PT | 🇺🇸 EN | 🇪🇸 ES
- CTA button (coral):
  pt-BR: "Quero ser avisado" | en: "Notify me" | es: "Avísame"
  → smooth-scroll to lead capture section
- Transparent on scroll, solid white + shadow when scrolled

---

### SECTION 2 — HERO (above the fold — conversion #1)

**"Coming soon" badge** (amber pill, above H1):
- pt-BR: "🚀 Em breve nas lojas"
- en: "🚀 Coming soon to stores"
- es: "🚀 Próximamente en las tiendas"

**COUNTDOWN TIMER (below the coming soon badge, above H1):**
Create a live countdown showing days / hours / minutes / seconds until launch.
- Read the launch date from environment variable: VITE_LAUNCH_DATE (ISO format, e.g. "2026-06-15T00:00:00-03:00")
- If VITE_LAUNCH_DATE is not set or the date has passed, hide the countdown entirely (do not show a negative timer)
- Style: four cards side by side (teal background, white numbers, small label below):
  pt-BR: DIAS | HORAS | MINUTOS | SEGUNDOS
  en: DAYS | HOURS | MINUTES | SECONDS
  es: DÍAS | HORAS | MINUTOS | SEGUNDOS
- Update every second with JavaScript setInterval
- On mobile: slightly smaller cards, still side by side
- Add to VITE_LAUNCH_DATE in the environment variables section

**H1:**
- pt-BR: "Seu filho não precisa de mais tela. Precisa da tela certa."
- en: "Your child doesn't need more screen time. They need the right screen."
- es: "Tu hijo no necesita más pantalla. Necesita la pantalla correcta."

**Subheadline:**
- pt-BR: "O Dulang é o app de inglês para crianças de 0 a 5 anos com vídeos curados, sem anúncios e controle parental completo. Seguro. Educativo. Feito para famílias. Em revisão final pelas lojas — cadastre-se para ser o primeiro a saber quando lançar."
- en: "Dulang is the English app for children ages 0–5 with curated videos, no ads, and full parental control. Safe. Educational. Made for families. Currently under final store review — sign up to be the first to know when it launches."
- es: "Dulang es la app de inglés para niños de 0 a 5 años con videos seleccionados, sin anuncios y control parental completo. Segura. Educativa. Hecha para familias. En revisión final en las tiendas — regístrate para ser el primero en saber cuándo llega."

**INLINE LEAD CAPTURE FORM (hero CTA — replaces download buttons):**
- Email input + submit button side by side (pill shape, coral button):
  pt-BR: placeholder "Seu melhor email" | button: "Me avisa no lançamento"
  en: placeholder "Your best email" | button: "Notify me at launch"
  es: placeholder "Tu mejor email" | button: "Avísame en el lanzamiento"
- LGPD consent checkbox below (required)
- On success: replace form with:
  pt-BR: "✅ Ótimo! Você será avisado assim que o Dulang chegar nas lojas."
  en: "✅ Great! You'll be notified as soon as Dulang is available."
  es: "✅ ¡Genial! Te avisaremos en cuanto Dulang esté disponible."
- On error: show inline error in red (translated)

**Trust badges row:**
- pt-BR: 🔒 Sem anúncios | 👨‍👩‍👧 Controle parental | ✅ Conteúdo curado | 📵 Sem internet aberta
- en: 🔒 No ads | 👨‍👩‍👧 Parental controls | ✅ Curated content | 📵 No open web
- es: 🔒 Sin anuncios | 👨‍👩‍👧 Control parental | ✅ Contenido curado | 📵 Sin internet abierta

**Visuals:**
- App mockup on iPhone + Android side by side (slight 3D tilt) [APP SCREENSHOT PLACEHOLDER]
- Background: soft gradient from teal (#19B8AA) top to white bottom
- Lightweight CSS animation: floating ABC letters and stars (keyframes)

---

### SECTION 3 — URGENCY STRIP

Full-width amber/yellow gradient band, centered:

**Large text:**
- pt-BR: "5 minutos de hoje. Valem anos de esforço depois."
- en: "5 minutes today. Worth years of effort later."
- es: "5 minutos hoy. Valen años de esfuerzo después."

**Smaller text below:**
- pt-BR: "Fluência não nasce no cursinho. Começa na infância. Cada dia que passa é uma janela que se fecha."
- en: "Fluency doesn't start in language school. It starts in childhood. Every day that passes is a window that closes."
- es: "La fluidez no nace en el instituto. Empieza en la infancia. Cada día que pasa es una ventana que se cierra."

---

### SECTION 4 — STATS (animated counter on scroll)

Three stat cards:
- pt-BR: "0 a 5 anos" / "A janela de ouro para o bilinguismo"  |  "100% curado" / "Conteúdo selecionado para crianças"  |  "0 anúncios" / "Ambiente seguro para sua criança"
- en: "Ages 0–5" / "The golden window for bilingualism"  |  "100% curated" / "Content selected for children"  |  "0 ads" / "Safe environment for your child"
- es: "0 a 5 años" / "La ventana de oro para el bilingüismo"  |  "100% curado" / "Contenido seleccionado para niños"  |  "0 anuncios" / "Entorno seguro para tu hijo"

---

### SECTION 5 — HOW IT WORKS (3 steps)

**H2:** pt-BR: "Como funciona" | en: "How it works" | es: "Cómo funciona"

Step 1 — 🔽 Download:
- pt-BR: Baixe o app — Em breve disponível gratuitamente na App Store e Google Play.
- en: Download the app — Coming soon, free on the App Store and Google Play.
- es: Descarga la app — Próximamente gratis en App Store y Google Play.

Step 2 — 👨‍👩‍👧 Setup:
- pt-BR: Configure o perfil — Crie o perfil do seu filho e defina o PIN parental em menos de 2 minutos.
- en: Set up the profile — Create your child's profile and set the parental PIN in under 2 minutes.
- es: Configura el perfil — Crea el perfil de tu hijo y establece el PIN parental en menos de 2 minutos.

Step 3 — ▶️ Watch:
- pt-BR: Assista junto — Acesse vídeos em inglês curados para bebês e crianças. Com controle de tempo e horários.
- en: Watch together — Access curated English videos for babies and toddlers. With time and schedule controls.
- es: Mira juntos — Accede a videos en inglés seleccionados para bebés y niños. Con control de tiempo y horarios.

Note below:
- pt-BR: "Recomendamos assistir junto com a criança para potencializar o aprendizado."
- en: "We recommend watching together with your child to maximize learning."
- es: "Recomendamos ver junto con tu hijo para potenciar el aprendizaje."

---

### SECTION 6 — FEATURES (2×3 grid of cards)

**H2:**
- pt-BR: "Tudo que uma família precisa para começar cedo"
- en: "Everything a family needs to start early"
- es: "Todo lo que una familia necesita para empezar temprano"

Feature 1 — 🎬:
- pt-BR: Vídeos curados em inglês | Conteúdo selecionado de canais infantis reconhecidos — sem surpresas, sem conteúdo inadequado.
- en: Curated English videos | Selected content from trusted children's channels — no surprises, no inappropriate content.
- es: Videos en inglés curados | Contenido seleccionado de canales infantiles reconocidos — sin sorpresas, sin contenido inapropiado.

Feature 2 — 🔒:
- pt-BR: PIN parental | Configure um PIN de 4 dígitos e proteja as configurações do app.
- en: Parental PIN | Set a 4-digit PIN to protect the app settings.
- es: PIN parental | Configura un PIN de 4 dígitos para proteger los ajustes de la app.

Feature 3 — ⏱️:
- pt-BR: Limite de tempo e horários | Defina quanto tempo por dia e em quais horários seu filho pode usar o app.
- en: Time limits & schedules | Set how much time per day and which hours your child can use the app.
- es: Límites de tiempo y horarios | Define cuánto tiempo al día y en qué horarios tu hijo puede usar la app.

Feature 4 — 📵:
- pt-BR: Sem anúncios. Sem internet aberta. | A criança não navega na web. Só o conteúdo que você aprovou, dentro do app.
- en: No ads. No open web. | Children don't browse the web. Only the content you approved, inside the app.
- es: Sin anuncios. Sin internet abierta. | Los niños no navegan por la web. Solo el contenido que aprobaste, dentro de la app.

Feature 5 — ❤️:
- pt-BR: Favoritos e histórico | Salve os vídeos preferidos e acompanhe o que foi assistido.
- en: Favorites & history | Save favorite videos and track what was watched.
- es: Favoritos e historial | Guarda los videos favoritos y controla lo que se vio.

Feature 6 — 🌍:
- pt-BR: Inglês desde o berço | Crianças expostas a idiomas antes dos 5 anos têm muito mais facilidade de aprender.
- en: English from the cradle | Children exposed to languages before age 5 learn much more easily.
- es: Inglés desde la cuna | Los niños expuestos a idiomas antes de los 5 años aprenden con mucha más facilidad.

---

### SECTION 7 — EMOTIONAL / DESIRE

**H2:**
- pt-BR: "Seu filho vai te agradecer pela oportunidade"
- en: "Your child will thank you for this opportunity"
- es: "Tu hijo te agradecerá esta oportunidad"

Left: warm flat illustration of parent and child watching tablet together [IMAGE PLACEHOLDER]

Large italic quote (right column):
- pt-BR: "Fluência não é um dom. É uma decisão tomada cedo pelos pais."
- en: "Fluency isn't a gift. It's a decision made early by parents."
- es: "La fluidez no es un don. Es una decisión que los padres toman temprano."

3 checkmark bullets:
- pt-BR: ✓ Menos custo com cursos no futuro | ✓ Mais oportunidades na carreira | ✓ Uma habilidade para a vida toda
- en: ✓ Lower cost of language courses later | ✓ More career opportunities | ✓ A lifelong skill
- es: ✓ Menor costo en cursos en el futuro | ✓ Más oportunidades laborales | ✓ Una habilidad para toda la vida

CTA (coral button → smooth scroll to lead capture):
- pt-BR: "Quero garantir meu lugar na fila" | en: "I want to be first in line" | es: "Quiero ser el primero"

---

### SECTION 8 — TESTIMONIALS

**H2:** pt-BR: "O que os pais estão dizendo" | en: "What parents are saying" | es: "Lo que dicen los padres"

pt-BR cards:
1. ⭐⭐⭐⭐⭐ Ana Paula M., São Paulo — "Minha filha de 3 anos já reconhece palavras em inglês nos desenhos! O app é simples, seguro e ela adora."
2. ⭐⭐⭐⭐⭐ Ricardo F., Belo Horizonte — "Finalmente um app sem anúncios irritantes. Consigo deixar ela assistir tranquila sabendo que é conteúdo seguro."
3. ⭐⭐⭐⭐⭐ Camila S., Curitiba — "O controle de horário foi um divisor de águas. Ela sabe que tem um tempo certo pra assistir."

en cards:
1. ⭐⭐⭐⭐⭐ Sarah M., Miami — "My 3-year-old already recognizes English words in cartoons! The app is simple, safe, and she loves it."
2. ⭐⭐⭐⭐⭐ James R., New York — "Finally an app without annoying ads. I can let her watch knowing it's safe content."
3. ⭐⭐⭐⭐⭐ Laura P., Los Angeles — "The schedule control was a game changer. She knows she has a specific time to watch."

es cards:
1. ⭐⭐⭐⭐⭐ María G., Ciudad de México — "¡Mi hija de 3 años ya reconoce palabras en inglés en los dibujos! La app es simple, segura y le encanta."
2. ⭐⭐⭐⭐⭐ Carlos R., Buenos Aires — "Por fin una app sin anuncios molestos. Puedo dejarla ver tranquila sabiendo que es contenido seguro."
3. ⭐⭐⭐⭐⭐ Valentina S., Bogotá — "El control de horarios fue un cambio total. Ella sabe que tiene un tiempo específico para ver."

---

### SECTION 9 — PRICING / PREMIUM

**H2:**
- pt-BR: "Dulang Premium — acesso completo" | en: "Dulang Premium — full access" | es: "Dulang Premium — acceso completo"

Centered card (teal gradient, white text) with "Coming soon" amber badge at top-right corner.

"Coming soon" note inside card:
- pt-BR: "Em revisão final pelas lojas. Seja avisado no lançamento."
- en: "Under final store review. Get notified at launch."
- es: "En revisión final en las tiendas. Recibe una notificación al lanzar."

Features checklist (✓):
- pt-BR: Acesso a todo o catálogo | Controle de horários e limite diário | PIN parental | Favoritos e histórico | Sem anúncios | Sem navegação livre
- en: Full catalog access | Schedule & daily time controls | Parental PIN | Favorites & history | No ads | No open web browsing
- es: Acceso a todo el catálogo | Control de horarios y límite diario | PIN parental | Favoritos e historial | Sin anuncios | Sin navegación libre

CTA (coral → smooth scroll to lead section):
- pt-BR: "Me avisa quando lançar" | en: "Notify me at launch" | es: "Avísame cuando lance"

---

### SECTION 10 — LEAD CAPTURE (dedicated section, id="avisar")

This section persists permanently on the page — before launch as the primary CTA, and after launch as a secondary "stay in the loop" section for remarketing.

**H2:**
- pt-BR: "Seja o primeiro a saber quando o Dulang chegar nas lojas"
- en: "Be the first to know when Dulang arrives on the stores"
- es: "Sé el primero en saber cuando Dulang llegue a las tiendas"

**Subtext:**
- pt-BR: "Cadastre seu email e receba um aviso assim que o app estiver disponível. Sem spam — só o que importa."
- en: "Enter your email and we'll let you know as soon as the app is available. No spam — just what matters."
- es: "Ingresa tu email y te avisamos en cuanto la app esté disponible. Sin spam — solo lo que importa."

**Form fields:**
- Name field (text, optional):
  pt-BR: placeholder "Seu nome (opcional)"
  en: "Your name (optional)"
  es: "Tu nombre (opcional)"
- Email field (email, required):
  pt-BR: "Seu melhor email"
  en: "Your best email"
  es: "Tu mejor email"
- LGPD consent checkbox (required, unchecked by default)
- Honeypot hidden field (name="website", hidden via CSS)
- Submit button (coral, full-width on mobile):
  pt-BR: "Me avisa no lançamento 🚀" | en: "Notify me at launch 🚀" | es: "Avísame en el lanzamiento 🚀"

**States:**
- Loading: show spinner inside button, disable all fields
- Success: hide form, show success card:
  pt-BR: "✅ Perfeito! Você está na lista. Avisaremos assim que o Dulang estiver disponível nas lojas."
  en: "✅ Perfect! You're on the list. We'll notify you as soon as Dulang is available."
  es: "✅ ¡Perfecto! Estás en la lista. Te avisaremos en cuanto Dulang esté disponible."
  → Redirect to thank you page after 2 seconds
- Error: show inline error message in red (translated)

Background: light mint (#F0FAFA), centered, max-width 480px form card with soft shadow

**IMPORTANT — After app launch:**
Change H2 to:
- pt-BR: "Fique por dentro das novidades do Dulang"
- en: "Stay up to date with Dulang"
- es: "Mantente al tanto de las novedades de Dulang"
And change subtext to mention updates, new content, and new apps in the same line.

---

### SECTION 11 — FAQ (accordion/expandable)

**H2:** pt-BR: "Perguntas frequentes" | en: "Frequently asked questions" | es: "Preguntas frecuentes"

Q1 — When does it launch?
- pt-BR: Quando o app vai lançar? / O Dulang está em revisão final pela App Store e Google Play. Cadastre seu email acima para ser avisado assim que estiver disponível.
- en: When does it launch? / Dulang is currently under final review by the App Store and Google Play. Sign up above to be notified as soon as it's available.
- es: ¿Cuándo lanza? / Dulang está en revisión final por App Store y Google Play. Regístrate arriba para recibir un aviso en cuanto esté disponible.

Q2 — Is it free?
- pt-BR: O Dulang é gratuito? / O app é gratuito para baixar, mas todo o conteúdo exige Dulang Premium ativo. O acesso é liberado por assinatura anual, comprada na App Store ou Google Play.
- en: Is Dulang free? / The app is free to download, but all content requires an active Dulang Premium subscription, purchased on the App Store or Google Play.
- es: ¿Dulang es gratuito? / La app es gratuita para descargar, pero todo el contenido requiere una suscripción Dulang Premium activa, comprada en App Store o Google Play.

Q3 — Parental controls:
- pt-BR: Como funciona o controle parental? / Você configura um PIN de 4 dígitos no primeiro acesso. Com o Premium, também define horários e limite de tempo de uso diário.
- en: How does parental control work? / You set a 4-digit PIN on first use. With Premium, you also set schedules and daily time limits.
- es: ¿Cómo funciona el control parental? / Configuras un PIN de 4 dígitos al primer uso. Con Premium, también defines horarios y límites de tiempo diario.

Q4 — Internet/browsing:
- pt-BR: Meu filho pode acessar a internet pelo app? / Não. O Dulang não é um navegador. A criança só assiste ao conteúdo curado dentro do app.
- en: Can my child browse the internet? / No. Dulang is not a browser. Children only watch curated content inside the app.
- es: ¿Mi hijo puede navegar por internet? / No. Dulang no es un navegador. Los niños solo ven contenido curado dentro de la app.

Q5 — Cancellation:
- pt-BR: Como cancelo a assinatura? / O gerenciamento é feito pela App Store (iOS) ou Google Play (Android), na conta do aparelho.
- en: How do I cancel? / Managed directly in the App Store (iOS) or Google Play (Android).
- es: ¿Cómo cancelo? / Se gestiona directamente en App Store (iOS) o Google Play (Android).

Q6 — Platforms:
- pt-BR: Disponível para Android e iPhone? / Sim. App Store (iPhone/iPad) e Google Play (Android).
- en: Available for Android and iPhone? / Yes. App Store (iPhone/iPad) and Google Play (Android).
- es: ¿Disponible para Android e iPhone? / Sí. App Store (iPhone/iPad) y Google Play (Android).

Q7 — Age range:
- pt-BR: Para qual faixa etária? / De 0 a 5 anos — a fase de maior absorção de idiomas. Uso supervisionado por adulto é sempre recomendado.
- en: What age is it for? / Ages 0–5 — the phase of peak language absorption. Supervised use by an adult is always recommended.
- es: ¿Para qué edad? / De 0 a 5 años — la fase de mayor absorción de idiomas. Siempre se recomienda uso supervisado por un adulto.

---

### SECTION 12 — FINAL CTA (conversion #2 — lead capture repeat)

Full-width teal (#19B8AA) background, centered, white text:

**H2:**
- pt-BR: "O futuro bilíngue não espera. Garanta seu lugar."
- en: "The bilingual future won't wait. Secure your spot."
- es: "El futuro bilingüe no espera. Asegura tu lugar."

**Subtext:**
- pt-BR: "Seja o primeiro a saber quando o Dulang chegar. Cadastre seu email — é grátis e sem spam."
- en: "Be the first to know when Dulang arrives. Enter your email — free and no spam."
- es: "Sé el primero en saber cuando llegue Dulang. Ingresa tu email — gratis y sin spam."

Compact inline form (email + button, white background on input, coral button):
→ Same Brevo integration as Section 10
→ On success: same success message

---

### SECTION 13 — FOOTER

Dark navy (#0D2020) background, white text, 4 columns:

Column 1: Logo + tagline + copyright per language:
- pt-BR: "© 2026 Dulang. Todos os direitos reservados."
- en: "© 2026 Dulang. All rights reserved."
- es: "© 2026 Dulang. Todos los derechos reservados."

Column 2 — Navigation (translated per language)

Column 3 — Support:
- Email: contato@carlosdev.com.br
- Links (translated): Contact page | Privacy Policy | Terms of Use

Column 4: Social media icons + "Coming soon" store badges (greyed out, cursor-not-allowed)

Social media links (open in new tab):
- Instagram: [VITE_INSTAGRAM_URL — placeholder "#instagram" until account is created]
- YouTube: [VITE_YOUTUBE_URL — placeholder "#youtube" until channel is created]
- TikTok: [VITE_TIKTOK_URL — placeholder "#tiktok" until account is created]
Use Lucide React icons: Instagram, Youtube, Music2 (for TikTok)
If a VITE_*_URL env var is empty or set to "#", hide that icon from the footer.

Note: after launch, replace greyed-out store badges with real App Store and Google Play badges linking to store URLs.

---

## ADDITIONAL PAGES

### PAGE: THANK YOU (/obrigado | /en/thank-you | /es/gracias)

Simple centered page (same header/footer as main):

Icon: large ✅ or animated confetti

H1:
- pt-BR: "Você está na lista! 🎉"
- en: "You're on the list! 🎉"
- es: "¡Estás en la lista! 🎉"

Text:
- pt-BR: "Assim que o Dulang chegar na App Store e no Google Play, você será um dos primeiros a saber. Fique de olho no seu email."
- en: "As soon as Dulang is available on the App Store and Google Play, you'll be one of the first to know. Keep an eye on your inbox."
- es: "En cuanto Dulang esté disponible en App Store y Google Play, serás uno de los primeros en saberlo. Mantente atento a tu email."

Button (coral → back to home):
- pt-BR: "Voltar ao início" | en: "Back to home" | es: "Volver al inicio"

Share prompt (optional but high-conversion):
- pt-BR: "Conhece outros pais que querem ensinar inglês para seus filhos? Compartilhe o Dulang:"
- en: "Know other parents who want to teach their children English? Share Dulang:"
- es: "¿Conoces otros padres que quieren enseñar inglés a sus hijos? Comparte Dulang:"
→ WhatsApp, Instagram, X share buttons (pre-filled message)

---

### PAGE: CONTACT (/contato | /en/contact | /es/contacto)

Same header/footer as main page.

H1: pt-BR: "Fale conosco" | en: "Contact us" | es: "Contáctanos"

Subtext:
- pt-BR: "Tem dúvidas, sugestões ou feedback? Mande uma mensagem. Respondemos em até 2 dias úteis."
- en: "Have questions, suggestions, or feedback? Send a message. We respond within 2 business days."
- es: "¿Tienes dudas, sugerencias o comentarios? Envía un mensaje. Respondemos en hasta 2 días hábiles."

Contact info (above form):
- 📧 contato@carlosdev.com.br
- 🌐 dulang.com.br

Contact form fields:
1. Name (required): pt-BR "Seu nome" | en "Your name" | es "Tu nombre"
2. Email (required): pt-BR "Seu email" | en "Your email" | es "Tu email"
3. Subject (required): pt-BR "Assunto" | en "Subject" | es "Asunto"
4. Message (textarea, required, min 20 chars): pt-BR "Sua mensagem" | en "Your message" | es "Tu mensaje"
5. LGPD consent checkbox (required)
6. Honeypot hidden field

Submit button (coral):
- pt-BR: "Enviar mensagem" | en: "Send message" | es: "Enviar mensaje"

Backend: POST to Brevo transactional email API
- TO: contato@carlosdev.com.br
- REPLY-TO: visitor email
- SUBJECT: "Contato via site Dulang — [subject field] — [visitor name]"
- BODY: HTML with all fields: name, email, subject, message, timestamp, browser language

States:
- Loading: spinner in button
- Success: show green card:
  pt-BR: "✅ Mensagem enviada! Respondemos em até 2 dias úteis."
  en: "✅ Message sent! We'll respond within 2 business days."
  es: "✅ ¡Mensaje enviado! Respondemos en hasta 2 días hábiles."
- Error: show red error card

---

### PAGE: PRIVACY POLICY (/politica-de-privacidade | /en/privacy-policy | /es/politica-de-privacidad)

Same header/footer as main page.

H1:
- pt-BR: "Política de Privacidade" | en: "Privacy Policy" | es: "Política de Privacidad"

Last updated date displayed below H1.

Content: [OPERATOR WILL PROVIDE THE FULL TEXT — use a placeholder with clear comment in code: /* INSERT PRIVACY POLICY TEXT HERE */]

Style: clean, readable, max-width 720px, good line-height, section headings as H2

---

### PAGE: TERMS OF USE (/termos-de-uso | /en/terms-of-use | /es/terminos-de-uso)

Same header/footer as main page.

H1:
- pt-BR: "Termos de Uso" | en: "Terms of Use" | es: "Términos de Uso"

Last updated date displayed below H1.

Content: [OPERATOR WILL PROVIDE THE FULL TEXT — use a placeholder with clear comment in code: /* INSERT TERMS OF USE TEXT HERE */]

Style: same as Privacy Policy

---

### PAGE: 404

Same header/footer.

Large emoji/illustration of the Dulang cloud character looking confused.

H1: pt-BR: "Ops, essa página não existe!" | en: "Oops, this page doesn't exist!" | es: "¡Ups, esta página no existe!"

Text: (translated)

Two buttons: Back to home + Lead capture CTA ("Quero ser avisado")

---

## COOKIE CONSENT BANNER (LGPD)

Fixed bottom bar (appears on first visit):

Text:
- pt-BR: "Usamos cookies para melhorar sua experiência. Ao continuar, você concorda com nossa Política de Privacidade."
- en: "We use cookies to improve your experience. By continuing, you agree to our Privacy Policy."
- es: "Usamos cookies para mejorar tu experiencia. Al continuar, aceptas nuestra Política de Privacidad."

Buttons: Aceitar / Accept / Aceptar (coral) | Recusar / Decline / Rechazar (ghost)
- Store choice in localStorage ("cookieConsent": "accepted" | "declined")
- If declined: only essential cookies

---

## TECHNICAL IMPLEMENTATION

### i18n architecture:
- react-i18next with /src/i18n/pt-BR.json, en.json, es.json
- Language detection: localStorage → navigator.language → default pt-BR
- URL routing: React Router with /, /en/, /es/ + all inner pages
- On first load: auto-redirect based on browser language
- On manual switch: update URL + html lang + localStorage

### Environment variables (Vite):
VITE_BREVO_API_KEY=<operator will provide>
VITE_BREVO_LIST_ID=10
VITE_CONTACT_EMAIL=contato@carlosdev.com.br
VITE_LAUNCH_DATE=<ISO date of expected launch, e.g. 2026-06-15T00:00:00-03:00 — leave empty to hide countdown>
VITE_GA4_MEASUREMENT_ID=<Google Analytics 4 Measurement ID, e.g. G-XXXXXXXXXX — leave empty to disable>
VITE_INSTAGRAM_URL=<Instagram profile URL — leave empty or "#" to hide icon>
VITE_YOUTUBE_URL=<YouTube channel URL — leave empty or "#" to hide icon>
VITE_TIKTOK_URL=<TikTok profile URL — leave empty or "#" to hide icon>

Never hardcode secrets — always read from import.meta.env.*

### SEO (react-helmet-async):
- Dynamic html lang, title, meta description per language/page
- hreflang alternate links
- og:locale + og:locale:alternate
- og:image: feature_graphic_1024x500.png (serve as 1200x630)
- JSON-LD MobileApplication schema per language
- Canonical per language/page
- robots.txt allowing all paths
- sitemap.xml with all URLs (/, /en/, /es/, /contato, /en/contact, /es/contacto, etc.)

### Favicon:
- Use favicon_transparente.png (the cloud icon without text) as the favicon
- Generate all necessary sizes: favicon.ico (32x32), apple-touch-icon (180x180), favicon-192x192.png, favicon-512x512.png
- Add to public/ folder and reference in index.html:
  <link rel="icon" type="image/png" href="/favicon_transparente.png" />
  <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
  <meta name="theme-color" content="#19B8AA" />

### Google Analytics 4:
- Read measurement ID from import.meta.env.VITE_GA4_MEASUREMENT_ID
- If the env var is empty, do NOT load GA4 (no script tag)
- If provided, load the GA4 gtag.js script in index.html (or via react-helmet-async on mount)
- Only initialize GA4 after cookie consent is "accepted" (respect LGPD — do not track before consent)
- Track the following custom events:
  - lead_capture_submit: when the lead email form is submitted successfully
    { language: "pt-BR"|"en"|"es", source: "hero"|"section"|"final_cta" }
  - contact_form_submit: when the contact form is submitted successfully
  - language_switch: when the user manually changes language
    { from: "pt-BR", to: "en" }
  - cta_click: when any "notify me" or "download" button is clicked
    { button_label: "...", section: "navbar"|"hero"|"pricing"|"final_cta" }
- Use gtag('event', ...) calls in the relevant form submit / click handlers

### Performance:
- Lazy load images below the fold
- Preload hero image
- Code-split each route
- Minimal dependencies: react-i18next + react-helmet-async + react-router-dom

### Animations:
- Scroll-reveal fade-up (Intersection Observer, no library)
- Hero: floating cloud/star CSS keyframes
- Stats: counter on scroll
- No autoplay video, no heavy third-party animations

### Accessibility:
- Single H1 per page, H2/H3 hierarchy
- Alt text on all images (translated)
- Focus states on all interactive elements
- ARIA labels on icon-only buttons
- Form labels properly associated with inputs

---

## DESIGN NOTES

- Mobile-first responsive: 375px / 768px / 1280px
- Sticky navbar: transparent → solid white + shadow on scroll
- Section background alternation: white → light mint (#F0FAFA) → white
- All cards: border-radius 16–24px, shadow 0 8px 32px rgba(0,0,0,0.08)
- All CTA buttons: coral #FF6B5B, white text, rounded pill, hover darken 10%, active scale 0.97
- Font: Nunito (400, 600, 700, 800)
- Icons: Lucide React
- No stock photos of people — flat illustrations + app mockup screenshots only
- Mockup frames: clean iPhone 15 + Pixel 8 SVG frames [APP SCREENSHOT PLACEHOLDER]
- "Coming soon" badge: amber pill (#F59E0B, white text)

---

## IMPORTANT NOTES

- Contact email: contato@carlosdev.com.br
- Website: dulang.com.br
- Brevo API key: VITE_BREVO_API_KEY — operator provides before deploy
- Brevo List ID: 10 — double opt-in must be enabled in Brevo dashboard for this list
- Launch date: VITE_LAUNCH_DATE — ISO format; if empty, countdown is hidden
- Google Analytics 4: VITE_GA4_MEASUREMENT_ID — only loads after cookie consent accepted
- Social media: VITE_INSTAGRAM_URL / VITE_YOUTUBE_URL / VITE_TIKTOK_URL — hide icon if empty or "#"
- Privacy Policy and Terms of Use content: PLACEHOLDERS — operator will paste the text
- Store links: PLACEHOLDERS ("#app-store" / "#google-play") — operator will update after approval
- Tech stack: React + TypeScript + Tailwind CSS + react-i18next + react-helmet-async + React Router
- All forms: LGPD consent required + honeypot anti-spam + double opt-in via Brevo
- Cookie consent: LGPD banner on first visit; GA4 and non-essential cookies only after acceptance
```

---

## Checklist antes de publicar o site

- [ ] Adicionar `VITE_BREVO_API_KEY` nas variáveis de ambiente do Lovable/host
- [ ] Confirmar que a Lista 10 do Brevo existe e está ativa
- [ ] Ativar **double opt-in** na Lista 10 do Brevo e configurar o email de confirmação nos 3 idiomas
- [ ] Definir `VITE_LAUNCH_DATE` com a data estimada de lançamento (ou deixar vazio para não mostrar o contador)
- [ ] Adicionar `VITE_GA4_MEASUREMENT_ID` com o ID do Google Analytics 4 (criar propriedade em analytics.google.com)
- [ ] Adicionar `VITE_INSTAGRAM_URL`, `VITE_YOUTUBE_URL`, `VITE_TIKTOK_URL` quando as contas forem criadas
- [ ] Colar texto da Política de Privacidade na página correspondente
- [ ] Colar texto dos Termos de Uso na página correspondente
- [ ] Testar envio de formulário de captação (verificar se email de confirmação chega e contato entra no Brevo após confirmar)
- [ ] Testar formulário de contato (verificar se email chega em contato@carlosdev.com.br)
- [ ] Testar detecção automática de idioma em pt-BR, en e es
- [ ] Testar cookie consent banner — confirmar que GA4 só carrega após aceitar cookies
- [ ] Testar countdown timer (mostrar/esconder, contagem regressiva correta)
- [ ] Checar favicon em browser desktop e mobile
- [ ] Checar SEO: title, description e hreflang nos 3 idiomas (usar Google Search Console depois de publicar)
- [ ] Verificar preview Open Graph (og:image) com ferramenta como opengraph.xyz ou compartilhando no WhatsApp
- [ ] Após aprovação nas lojas: substituir `#app-store` e `#google-play` pelas URLs reais, remover badges "em breve", ocultar ou adaptar countdown

---

## Como usar no Lovable

1. Abra o [Lovable](https://lovable.dev) e crie um novo projeto
2. Cole o prompt acima na janela inicial
3. Faça upload das imagens junto com o prompt:
   - `dulang1.png` — logo com texto
   - `favicon_transparente.png` — ícone sem fundo
   - `feature_graphic_1024x500.png` — banner/feature graphic
   - `icon_512x512.png` — referência de paleta de cores
4. Quando o Lovable perguntar pela API Key do Brevo, informe o valor
5. Cole os textos de Política de Privacidade e Termos de Uso quando solicitado
6. Após geração inicial, itere pedindo ajustes de design e copy no chat do Lovable
7. Após aprovação nas lojas: peça ao Lovable para substituir os placeholders pelos links reais
