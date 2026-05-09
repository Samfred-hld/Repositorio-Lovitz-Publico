# Lovitz — Progresso do Desenvolvimento

**Última atualização:** 2026-05-09 (sessão noturna)

---

## Visão Geral

App Flutter de rastreamento de hábitos baseado na Pirâmide de Maslow. Migração completa do Base44 para Supabase.

**Repositório:** https://github.com/Samfred-hld/Repositorio-Lovitz-Publico

---

## ✅ Concluído

### 1. Fix: Overlap na Pirâmide de Maslow
- Labels envolvidos em `Flexible` com `TextOverflow.ellipsis`
- Fonte reduzida: labels 12→11, porcentagem 13→12
- Padding inferior extra na seção da pirâmide
- **Arquivo:** `lib/screens/home_screen.dart`

### 2. Migração Base44 → Supabase
- Schema SQL completo (`supabase/schema.sql`):
  - 5 tabelas: `users`, `habits`, `habit_logs`, `achievements`, `user_achievements`
  - RLS policies (segurança por usuário)
  - 3 triggers automáticos: `updated_at`, recálculo de streak, XP ao registrar
  - 5 índices compostos para queries otimizadas
  - 2 views: `user_stats`, `daily_progress`
  - Seed com 10 conquistas
- `api_service.dart` reescrito com Supabase client
- `supabase_client.dart` criado (inicialização)
- `constants.dart` limpo (sem Base44)
- `pubspec.yaml`: `http` → `supabase_flutter ^2.3.0`
- Models atualizados: `habit.dart`, `habit_record.dart`, `achievement.dart`, `user.dart`

### 3. Autenticação Supabase
- `auth_screen.dart`: tela de login/cadastro com animação, validação, erros PT-BR
- `auth_service.dart`: signIn, signUp, signOut, resetPassword
- `main.dart`: AuthGate com StreamBuilder (redireciona automaticamente)
- `profile_screen.dart`: card do usuário, stats em tempo real, menu configurações, logout

### 4. Configuração Supabase
- Projeto criado no Supabase: **clasnbnmudesgmwlgouh** (URL: `https://clasnbnmudesgmwlgouh.supabase.co`)
- Schema SQL rodado com sucesso
- Credenciais (anon key) configuradas em `constants.dart`
- **Nota:** Projeto anterior `mvrcjazxjkjvirnbgiwt` foi substituído

### 5. Redesign da Pirâmide de Maslow
- **Cantos arredondados** via trapézios com `arcToPoint` (raio 14px)
- **Formato de pirâmide real**: base 95% → topo 40% da largura
- **Preenchimento sólido** com gradiente sutil (sem glow excessivo)
- **Círculos de progresso** com % ao lado de cada nível
- **Emojis** (🔥🛡️❤️⭐🌟) posicionados fora da pirâmide
- **Seção "Continue sua jornada"** com círculo de progresso grande (78%)
- **Cores atualizadas**: amarelo (base), laranja, rosa, azul, roxo (topo)
- **Arquivos alterados:**
  - `lib/widgets/maslow_pyramid_painter.dart` — painter redesenhado
  - `lib/screens/home_screen.dart` — layout pirâmide + labels + círculos + seção jornada
  - `lib/theme/app_theme.dart` — cores Maslow atualizadas

### 6. Telas de Hábitos — Criação, Detalhes, Lista
- **`create_habit_screen.dart`** — Tela "Criar Novo Hábito"
  - Input com nome do hábito
  - Seletor de frequência: Diário / Semanal / Personalizado (toggle rounded)
  - Seletor de nível Maslow com 5 ícones neon (vermelho → laranja → cyan → azul → roxo)
  - Botão "Salvar Hábito" com glow neon
  - Tradução fiel do HTML de referência (cores, dimensões, efeitos)
- **`habit_detail_screen.dart`** — Tela "Detalhes do Hábito"
  - Card principal com nome, nível Maslow, barra de progresso com glow
  - Calendário de conclusão com círculos neon nos dias completados
  - Navegação entre meses com recarga de dados
  - Grid de stats: streak real + total de conclusões reais
  - Botão "Marcar como concluído" / "Concluído hoje ✓" (toggle real no banco)
  - Botões Editar / Excluir com confirmação via dialog
- **`habits_screen.dart`** — Lista de hábitos atualizada
  - Carrega hábitos do Supabase via `ApiService.getHabits()`
  - Cards com ícone neon por nível, nome, streak real
  - Botão "+" no header para criar novo hábito
  - Navegação para detalhes ao tocar no card
  - Pull-to-refresh, estado vazio, loading state
  - Recarrega ao voltar de create/detail

### 7. Integração Total com Supabase — Dados Reais
- **HomeScreen** — zero dados fictícios
  - Cards de resumo: streak real do banco, hábitos concluídos/total de hoje
  - Pirâmide Maslow: % real calculada por nível (hábitos com streak > 0 / total)
  - "Continue sua jornada": progresso real, texto dinâmico
- **CreateHabitScreen** — salva no banco
  - Validação (nome obrigatório), loading state, feedback visual (SnackBar)
  - Retorna `true` para recarregar lista ao voltar
- **HabitDetailScreen** — interação real
  - Calendário carrega logs reais do mês via `ApiService.getHabitLogs()`
  - Toggle de conclusão hoje (insert/delete no banco)
  - Stats reais (streak atualizado via trigger do banco)
  - Exclusão real com `ApiService.deleteHabit()`
- **HabitsScreen** — lista do banco
  - `ApiService.getHabits()` com recarga automática

### 8. Efeitos Neon com CustomPaint (Canvas Real)
- **`_GlowBoxPainter`** — replica CSS `box-shadow` com outer + inset
  - Outer glow: `MaskFilter.blur` + múltiplas camadas de halo
  - Inset glow: `canvas.clipRRect` + `MaskFilter.blur` com `PaintingStyle.fill`
  - Usado nos ícones Maslow e botão Salvar
- **`_NeonBorderPainter`** — replica CSS `neon-border-purple`
  - Outer glow + borda visível + inset glow
  - Usado no input e toggle Diário
- **Cores neon exatas**: `#BF00FF` (purple), `#FF4D4D` (red), `#FFAA00` (orange), `#00F2FF` (cyan), `#007FFF` (blue), `#D946EF` (pink)
- **Fundo com grid** 40px via `CustomPaint` (`_GridPainter`)

---

## ⚠️ Pendente / Em andamento

### Configuração Supabase
- **Redirect URLs:** Adicionar `http://localhost:3000` no painel Supabase
  - Painel → Authentication → URL Configuration → Add URL
- **Email Auth:** Confirmar que está habilitado em Authentication → Providers
- **Status:** Aguardando usuário configurar

---

## 📋 Próximos Passos (Roadmap)

### Prioridade 1 — Estabilizar
- [ ] Configurar CORS (redirect URL no Supabase)
- [ ] Testar fluxo completo: cadastro → login → criar hábito → registrar → logout

### Prioridade 2 — Telas faltantes
- [x] ~~Tela de criação/edição de hábito~~ ✅
- [x] ~~Tela de detalhes do hábito~~ ✅
- [ ] Tela de edição de hábito (reutilizar create com dados preenchidos)
- [ ] Tela de configurações (notificações, aparência, tema)
- [ ] Tela de onboarding (primeira vez)

### Prioridade 3 — Funcionalidades
- [ ] Notificações locais
- [ ] Suporte a temas (light/dark toggle)
- [ ] Upload de foto de perfil (Supabase Storage)
- [ ] Journal/diário (tabela `journal_entries` no schema)

### Prioridade 4 — Polish
- [ ] Animações de transição entre telas
- [ ] Skeleton loading nos cards
- [ ] Pull-to-refresh nos dados (implementado em HabitsScreen, falta nas outras)
- [ ] Tratamento de erro offline
- [ ] Aplicar CustomPaint neon nas outras telas (home, detail, progress)

---

## 🏗️ Arquitetura

### Estrutura do Projeto
```
lovitz-app/
├── supabase/
│   └── schema.sql              # Schema completo do banco
├── lib/
│   ├── main.dart               # Entry point + AuthGate
│   ├── main_shell.dart         # Shell de navegação (bottom nav)
│   ├── theme/
│   │   └── app_theme.dart      # Cores, tipografia, sombras
│   ├── utils/
│   │   └── constants.dart      # Supabase URL/key, níveis Maslow
│   ├── models/
│   │   ├── habit.dart
│   │   ├── habit_record.dart
│   │   ├── achievement.dart
│   │   └── user.dart
│   ├── services/
│   │   ├── supabase_client.dart  # Inicialização Supabase
│   │   ├── auth_service.dart     # Login/cadastro/logout
│   │   └── api_service.dart      # CRUD completo (habits, logs, achievements)
│   ├── screens/
│   │   ├── auth_screen.dart      # Login/cadastro
│   │   ├── home_screen.dart      # Tela principal + pirâmide (dados reais)
│   │   ├── habits_screen.dart    # Lista de hábitos (Supabase)
│   │   ├── create_habit_screen.dart  # Criar hábito (CustomPaint neon)
│   │   ├── habit_detail_screen.dart  # Detalhes + calendário + toggle
│   │   ├── progress_screen.dart  # Progresso
│   │   ├── profile_screen.dart   # Perfil + stats + logout
│   │   └── maslow_detail_screen.dart
│   └── widgets/
│       ├── maslow_pyramid_painter.dart
│       ├── progress_ring.dart
│       ├── habit_card.dart
│       ├── legend_card.dart
│       └── bottom_nav_bar.dart
├── pubspec.yaml
└── assets/images/
```

### Supabase
- **Projeto:** clasnbnmudesgmwlgouh
- **URL:** https://clasnbnmudesgmwlgouh.supabase.co
- **Auth:** Email (habilitado)
- **Tabelas:** users, habits, habit_logs, achievements, user_achievements

### Design System
- **Background:** `#0C0A18` (create), `#0D0D1A` (outras)
- **Surface:** `#1E1E38` / `#1A162B` (card)
- **Primary:** `#8B70E8` (roxo)
- **Neon:** `#BF00FF` (purple), `#D946EF` (pink), `#FF4D4D` (red), `#FFAA00` (orange), `#00F2FF` (cyan), `#007FFF` (blue)
- **Accent:** `#E040FB` (rosa), `#FF8C42` (laranja), `#6FCF97` (verde)
- **Maslow:** `#E8C840` (fisiológico), `#E89040` (segurança), `#D45BA0` (pertencimento), `#5B8FD4` (estima), `#8B6CE0` (autorrealização)
- **Fontes:** AppTextStyles (heading1-3, bodyLarge/Medium/Small, buttonText)

### Efeitos Neon (CustomPaint)
- **Outer glow:** `MaskFilter.blur(BlurStyle.normal, radius)` com `PaintingStyle.stroke`
- **Inset glow:** `canvas.clipRRect()` + `MaskFilter.blur` com `PaintingStyle.fill`
- **Halo:** múltiplas camadas com opacity decrescente
- **Text glow:** `Shadow` com blur matching a cor do elemento

---

## 🔧 Comandos úteis

```powershell
# Pull das alterações
git pull

# Instalar/atualizar dependências
flutter pub get

# Rodar no Chrome (alias configurado no PowerShell)
flutter-run

# Hot reload (enquanto o app roda)
r

# Hot restart
R
```

---

## ⚠️ Notas de Segurança

- **Token GitHub** foi exposto em chat — deve ser revogado e substituído
- **Service role key** do Supabase foi compartilhada — NÃO usar no app (só anon key)
- A anon key já está configurada em `constants.dart` (segura pra client-side)
