# Lovitz — Roadmap Visual (Esqueleto do App)

> Análise baseada no código atual (`lib/`) comparado com os mockups **Ref1**, **Ref2** e **Ref3**.  
> Foco: estrutura sólida antes de implementações de negócio.

---

## Diagnóstico: Estado Atual vs. Mockups

| Componente | Estado Atual | Meta (Mockup) |
|---|---|---|
| `main.dart` | Aponta direto para `HomeScreen`, tema com cores erradas (`0xFF120808`) | Usar `MainShell`, tema `AppColors.background` |
| `MainShell` | Existe mas está vazio (só exibe `Text('Shell')`) | Shell funcional com 4 abas |
| `HomeScreen` | Header ✅ · Cards resumo ✅ · Pirâmide ✅ (estrutura ok) | Navegação para `MaslowDetailScreen` ao tocar na pirâmide |
| `ProgressScreen` | Grid de stats + lista de conquistas (layout diferente do mockup) | Tabs Hoje/Semana/Mês/Ano + gráfico de barras + lista de hábitos |
| `MaslowDetailScreen` | **Não existe** | Tela nova completa (Ref2) |
| `HabitsScreen` | **Não existe** | Placeholder com estrutura (aparece no bottom nav) |
| `ProfileScreen` | **Não existe** | Placeholder com estrutura |
| `bottom_nav_bar.dart` | ✅ Implementado e estilizado | Sem alterações |
| `app_theme.dart` | ✅ Cores e estilos corretos | Adicionar `AppTextStyles` faltantes se necessário |
| `pubspec.yaml` | Sem pacote de gráficos | Adicionar `fl_chart` para o bar chart da Ref3 |

---

## Etapa 1 — Corrigir a Arquitetura Shell

**Problema:** `main.dart` bypassa o `MainShell` e vai direto pra `HomeScreen`. O bottom nav existe na Home, mas não navega entre telas — cada tap em "Progresso" ou "Perfil" não faz nada.

### 1.1 · `main.dart`
- Trocar `home: const HomeScreen()` por `home: const MainShell()`
- Corrigir `scaffoldBackgroundColor` para `AppColors.background` (`0xFF0D0D1A`)
- Corrigir `colorScheme.primary` para `AppColors.primary` (`0xFF8B70E8`)

```dart
// ANTES
home: const HomeScreen(),
scaffoldBackgroundColor: const Color(0xFF120808),

// DEPOIS
home: const MainShell(),
scaffoldBackgroundColor: AppColors.background,
```

### 1.2 · `main_shell.dart`
Implementar o shell com `IndexedStack` para preservar estado das abas:

```dart
class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    HabitsScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
```

### 1.3 · `home_screen.dart`
- Remover o `bottomNavigationBar` do `Scaffold` interno (agora é responsabilidade do `MainShell`)
- Manter o `AnimationController` e o `SingleChildScrollView`

---

## Etapa 2 — Criar Telas Placeholder

Criar arquivos com estrutura mínima para o shell não quebrar na compilação.

### 2.1 · `lib/screens/habits_screen.dart` *(novo)*

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Hábitos', style: AppTextStyles.heading1),
              // TODO: lista de hábitos
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.2 · `lib/screens/profile_screen.dart` *(novo)*

Mesma estrutura de placeholder com título "Perfil".

---

## Etapa 3 — Criar `MaslowDetailScreen` (Ref2)

Esta é a tela mais complexa ausente. É acessada ao tocar em qualquer nível da pirâmide na `HomeScreen`.

**Estrutura visual (Ref2):**
```
AppBar: [← Pirâmide de Maslow] [···]
TabBar: [Visão geral] [Detalhes]
──────────────────────────────────
Card expandido (nível ativo):
  ┌─ ícone · Nome do Nível · 0%
  │  Descrição curta
  │  [====== barra de progresso ======]
  │  0/2 hábitos concluídos
  │
  │  Hábitos neste nível:    0/2
  │  ┌── ícone · Meditar         ○ ──┐
  │  │   10 min por dia              │
  │  └───────────────────────────────┘
  │  ┌── ícone · Escrever diário  ○ ──┐
  │  │   Refletir sobre o dia        │
  │  └───────────────────────────────┘
└─────────────────────────────────────

Cards colapsados (outros níveis):
  ┌── ícone · Estima          0%  > ──┐
  │   [==== barra de progresso ====]  │
  └───────────────────────────────────┘
  (repete para Pertencimento, Segurança, Fisiológico)
```

### Arquivo: `lib/screens/maslow_detail_screen.dart` *(novo)*

**Parâmetro de entrada:** `MaslowLevel level` (o nível clicado na pirâmide).

**Widgets necessários:**
- `DefaultTabController` com 2 tabs
- `SliverAppBar` ou `AppBar` simples com `leading: BackButton`
- `TabBar` estilizado (underline roxo, fundo transparente)
- `_ExpandedLevelCard` — card do nível ativo com lista de hábitos e checkboxes
- `_CollapsedLevelCard` — card dos outros níveis com `LinearProgressIndicator` e seta `>`

**Navegar até ela a partir da `HomeScreen`:**

```dart
// Em _buildMaslowPyramid(), envolver os ícones com GestureDetector:
GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MaslowDetailScreen(level: level),
    ),
  ),
  child: /* container do ícone */,
)
```

---

## Etapa 4 — Reescrever `ProgressScreen` (Ref3)

A tela atual (`GridView` + lista de conquistas) não corresponde ao mockup. Reescrever completo.

**Estrutura visual (Ref3):**
```
TabBar: [Hoje] [Semana] [Mês] [Ano]  [≡]
──────────────────────────────────────
Título: Seu progresso
Subtítulo: Visão geral do seu desenvolvimento

Card: Progresso por nível         [Semana ▾]
  Gráfico de barras verticais
  (5 barras, uma por nível Maslow, com ícones no eixo X)

Card: Resumo da semana
  [12 Sequência] [7/9 Hábitos] [78% Taxa] [20 Pontos]

Seção: Hábitos de Hoje            Ver todos >
  Lista de habit cards com:
  - borda esquerda colorida (cor do nível Maslow)
  - ícone · nome · categoria
  - checkbox (preenchido se concluído)
```

### Dependência nova — adicionar ao `pubspec.yaml`:
```yaml
dependencies:
  fl_chart: ^0.68.0
```

### Widgets necessários em `progress_screen.dart`:
- `_PeriodTabBar` — tabs Hoje/Semana/Mês/Ano com underline roxo
- `_LevelBarChart` — usa `BarChart` do `fl_chart` com as 5 cores Maslow
- `_WeeklySummaryCard` — 4 stats em linha (número grande + label)
- `_HabitListItem` — card com borda esquerda colorida + checkbox

---

## Etapa 5 — Polimento da `HomeScreen` (Ref1)

A estrutura já está boa. Ajustes pontuais:

| Item | Problema atual | Correção |
|---|---|---|
| Ordem do header | Avatar aparece após sino no código | Inverter: avatar → sino (como na Ref1) |
| Pirâmide — ícones | Ícones centralizados no eixo X da pirâmide, mas deslocados verticalmente | Ajustar `yCenter` para alinhar com centro visual de cada fatia |
| Pirâmide — toque | Sem interação | Adicionar `GestureDetector` nos ícones → navega para `MaslowDetailScreen` |
| Padding inferior | `SizedBox(height: 100)` fixo | Usar `MediaQuery.of(context).padding.bottom + 80` |

---

## Sequência de Execução Recomendada

```
[1] Corrigir main.dart + implementar MainShell        → App navega entre abas
[2] Criar HabitsScreen + ProfileScreen (placeholder)  → Shell não quebra
[3] Criar MaslowDetailScreen                          → Fluxo principal completo
[4] Reescrever ProgressScreen + adicionar fl_chart    → Tela de progresso fiel ao mockup
[5] Polimento HomeScreen (ordem header, toque pirâmide) → Visual fiel à Ref1
```

---

## Estrutura de Arquivos Final Esperada

```
lib/
├── main.dart                          ✏️  corrigir
├── main_shell.dart                    ✏️  implementar
├── models/
│   ├── achievement.dart               ✅
│   ├── habit.dart                     ✅
│   ├── habit_record.dart              ✅
│   └── user.dart                      ✅
├── screens/
│   ├── home_screen.dart               ✏️  ajustes pontuais
│   ├── habits_screen.dart             🆕  criar (placeholder)
│   ├── progress_screen.dart           ✏️  reescrever completo
│   ├── maslow_detail_screen.dart      🆕  criar (tela completa)
│   └── profile_screen.dart            🆕  criar (placeholder)
├── services/
│   └── api_service.dart               ✅
├── theme/
│   └── app_theme.dart                 ✅
├── utils/
│   └── constants.dart                 ✅
└── widgets/
    ├── bottom_nav_bar.dart            ✅
    ├── habit_card.dart                ✅
    ├── legend_card.dart               ✅
    ├── maslow_pyramid_painter.dart    ✅
    └── progress_ring.dart             ✅
```

**Legenda:** ✅ ok · ✏️ editar · 🆕 criar

---

## Notas para o Antigravity

- Ao criar `MaslowDetailScreen`, reutilizar `MaslowLevel` do `maslow_pyramid_painter.dart` — não duplicar o modelo.
- `fl_chart` já resolve o bar chart da Ref3; não usar `percent_indicator` para isso (serve melhor para progress bars lineares nos cards colapsados da Ref2).
- O `IndexedStack` no shell garante que o estado de cada aba é preservado ao trocar de tab — preferível ao `PageView` para este caso.
- Todos os novos `Scaffold` devem usar `backgroundColor: AppColors.background` — não depender do tema global para isso.
