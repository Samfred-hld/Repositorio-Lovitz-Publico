# Lovitz — Progresso do Desenvolvimento

**Última atualização:** 2026-05-09

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
- [ ] Tela de criação/edição de hábito
- [ ] Tela de detalhes do hábito
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
- [ ] Pull-to-refresh nos dados
- [ ] Tratamento de erro offline

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
│   │   ├── home_screen.dart      # Tela principal + pirâmide
│   │   ├── habits_screen.dart    # Lista de hábitos
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
- **Background:** `#0D0D1A`
- **Surface:** `#1E1E38`
- **Primary:** `#8B70E8` (roxo)
- **Accent:** `#E040FB` (rosa), `#FF8C42` (laranja), `#6FCF97` (verde)
- **Maslow:** `#E8C840` (fisiológico), `#E89040` (segurança), `#D45BA0` (pertencimento), `#5B8FD4` (estima), `#8B6CE0` (autorrealização)
- **Fontes:** AppTextStyles (heading1-3, bodyLarge/Medium/Small, buttonText)

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
