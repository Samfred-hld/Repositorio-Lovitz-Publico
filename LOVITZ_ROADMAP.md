# Lovitz — Validação Visual: App Atual vs. Mockups

> Comparação direta entre os screenshots do último commit e os mockups Ref1 e Ref3.  
> Cada item indica o **status**, o **problema exato** e o **código de correção** para o Claude Code.

---

## 🏠 Home Screen — Ref1 vs. Screenshot Atual

### ✅ O que foi atingido
- Título "Habit Tracker" com gradiente roxo
- Cards de resumo com layout 2 colunas, valores e ícones corretos
- Pirâmide com 5 níveis coloridos e ícones centrais
- Labels e percentuais à direita de cada nível
- Bottom nav com 4 abas e indicador de ativo

---

### ❌ Gap 1 — Pirâmide: Título fora do card container

**Mockup:** "Pirâmide de Maslow" + subtítulo ficam **fora** do card `surface`, no fundo `background`. O card começa apenas na borda da pirâmide.  
**Atual:** Título e pirâmide estão dentro do mesmo `Container` com fundo `AppColors.surface`.

**Correção em `home_screen.dart`:**
```dart
// REMOVER o Container externo e expor o título diretamente na Column:
Column(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pirâmide de Maslow', style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text('Acompanhe seu progresso em cada nível.', style: AppTextStyles.bodyMedium),
        ],
      ),
    ),
    const SizedBox(height: 16),
    // A pirâmide sem Container wrapping extra
    _buildMaslowPyramid(),
  ],
)
```

---

### ❌ Gap 2 — Pirâmide: Ausência de separação (gap) entre camadas

**Mockup:** Cada trapézio tem ~4–6px de espaço vazio entre ele e o próximo, criando efeito de "camadas empilhadas".  
**Atual:** As camadas são desenhadas uma encostada na outra, sem separação, virando um bloco sólido.

**Correção em `maslow_pyramid_painter.dart`:**
```dart
// Adicionar gap entre níveis no painter:
const double levelGap = 5.0;
final adjustedLevelHeight = (totalHeight - (levelGap * (levelCount - 1))) / levelCount;

// Para cada nível, calcular y com o gap:
final y = i * (adjustedLevelHeight + levelGap);

// Usar adjustedLevelHeight no lugar de levelHeight em todo o painter
```

---

### ❌ Gap 3 — Pirâmide: Ausência de efeito neon/glow nas camadas

**Mockup:** Cada camada tem um brilho intenso nas **bordas laterais e superior**, como se a cor emitisse luz. Efeito tipo "neon glow" — fica claro principalmente nos níveis verde (Segurança) e vermelho (Fisiológico).  
**Atual:** Camadas são flat, sem nenhum glow. Só há `drawShadow` com preto, que não reproduz o efeito.

**Correção em `maslow_pyramid_painter.dart` — substituir o shadow atual:**
```dart
// REMOVER:
canvas.drawShadow(path, Colors.black, 8.0, true);

// ADICIONAR glow colorido ANTES do fillPaint:
final glowPaint = Paint()
  ..color = level.color.withOpacity(0.55)
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 6.0;
canvas.drawPath(path, glowPaint);

// Segundo passe de glow mais suave (halo externo):
final outerGlowPaint = Paint()
  ..color = level.color.withOpacity(0.25)
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 12.0;
canvas.drawPath(path, outerGlowPaint);
```

---

### ❌ Gap 4 — Pirâmide: Gradiente das camadas muito apagado

**Mockup:** O gradiente de cada camada vai de uma cor **viva e saturada** no topo/lateral para uma levemente mais escura na base. Cores têm alta luminosidade.  
**Atual:** O gradient usa `level.color.withOpacity(0.5)` como stop final, o que escurece e dessatura demais — ficando opaco e sem vida.

**Correção em `maslow_pyramid_painter.dart`:**
```dart
// SUBSTITUIR o gradient:
final gradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    _lighten(level.color, 0.15),  // tom mais claro na borda iluminada
    level.color,                   // cor base
    _darken(level.color, 0.12),   // leve escurecimento na sombra
  ],
  stops: const [0.0, 0.5, 1.0],
);

// Helpers a adicionar na classe:
Color _lighten(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}
Color _darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
```

---

### ❌ Gap 5 — Pirâmide: Ícones sem fundo colorido vibrante

**Mockup:** Cada ícone está num container **quadrado arredondado** com fundo colorido (da mesma cor do nível, em tom vibrante claro — não transparente branco). Os ícones parecem "selos" coloridos.  
**Atual:** Container com `Colors.white.withOpacity(0.12)` — fundo quase invisível, ícone flutua sem destaque.

**Correção em `home_screen.dart`, bloco dos ícones:**
```dart
// SUBSTITUIR o container dos ícones:
Container(
  width: 36,
  height: 36,
  decoration: BoxDecoration(
    color: level.color.withOpacity(0.30),   // fundo colorido visível
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: level.color.withOpacity(0.60), // borda na cor do nível
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: level.color.withOpacity(0.40),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  ),
  child: Icon(level.icon, color: Colors.white, size: 20),
)
```

---

### ❌ Gap 6 — Pirâmide: Labels sem painel semi-transparente

**Mockup:** As labels do lado direito (`Autorrealização 0%`, etc.) estão sobre um **painel escuro semi-transparente** com leve transparência, claramente distinto do fundo. Há hierarquia visual entre o label e o fundo.  
**Atual:** Container com `Colors.white.withOpacity(0.04)` — praticamente invisível, labels parecem flutuar no vazio.

**Correção em `home_screen.dart`:**
```dart
// SUBSTITUIR o container das labels:
decoration: BoxDecoration(
  color: const Color(0xFF1A1A30).withOpacity(0.75), // painel escuro visível
  borderRadius: BorderRadius.circular(10),
  border: Border.all(
    color: Colors.white.withOpacity(0.07),
    width: 1,
  ),
),
```

---

### ❌ Gap 7 — Cards de Resumo: Fundo com contraste insuficiente

**Mockup:** Os cards têm fundo `~#1C1C3A` — visivelmente mais claro que o fundo da página, com bordas arredondadas bem definidas.  
**Atual:** `AppColors.surface` (`#151528`) está muito próximo de `AppColors.background` (`#0D0D1A`), perdendo o contraste.

**Correção em `app_theme.dart`:**
```dart
// Aumentar levemente o surface para ter mais contraste:
static const Color surface = Color(0xFF1E1E38); // era 0xFF151528
```

---

## 📊 Progress Screen — Ref3 vs. Screenshot Atual

### ✅ O que foi atingido
- Tab bar Hoje/Semana/Mês/Ano com underline roxo funcional
- Gráfico de barras verticais com ícones no eixo X
- Card "Resumo da semana" com 4 métricas
- Lista "Hábitos de Hoje" com borda colorida esquerda e checkboxes
- Bottom nav com "Progresso" destacado

---

### ❌ Gap 8 — Gráfico: Barras sem glow/neon

**Mockup:** Cada barra tem um brilho suave na parte superior e nas bordas — efeito neon igual ao da pirâmide.  
**Atual:** Barras flat, sem nenhum efeito de brilho.

**Correção no widget `BarChart` (fl_chart):**
```dart
BarChartRodData(
  toY: value,
  color: barColor,
  width: 22,
  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
  backDrawRodData: BackgroundBarChartRodData(
    show: true,
    toY: 100,
    color: Colors.white.withOpacity(0.04),
  ),
  // Adicionar rodStackItems para o efeito de glow:
  rodStackItems: [
    BarChartRodStackItem(
      value * 0.85, value,
      barColor.withOpacity(0.50), // topo mais claro = glow
    ),
  ],
),
```

---

### ❌ Gap 9 — Resumo da semana: Cores dos números inconsistentes

**Mockup:** Os 4 números têm cores vibrantes e **distintas** — criando ritmo visual (roxo · roxo · roxo · laranja ou similar).  
**Atual:** Mix de laranja, cinza e verde sem padrão coeso.

**Correção — padronizar cores no widget de resumo:**
```dart
// Usar as cores Maslow primárias de forma consistente:
const summaryColors = [
  Color(0xFFA78BFA),  // roxo — Sequência
  Color(0xFFA78BFA),  // roxo — Hábitos
  Color(0xFF30C8C8),  // teal — Taxa
  Color(0xFFFF8C42),  // laranja — Pontos
];
```

---

### ❌ Gap 10 — Resumo da semana: Labels cortados

**Mockup:** Labels descritivos completos: "Sequência atual", "Hábitos concluídos", "Taxa de sucesso", "Pontos totais".  
**Atual:** Labels truncados: "Sequência", "Hábitos", "Taxa", "Pontos".

**Correção:** Restaurar os textos completos no widget de resumo.

---

### ❌ Gap 11 — Hábitos de Hoje: Poucos itens exibidos

**Mockup:** 4 hábitos na lista (Beber 2L, Dormir 8h, Fazer atividade física, Ler um livro).  
**Atual:** Apenas 2 hábitos.

Isso pode ser dado mockado — verificar se a lista de hábitos de exemplo está incompleta no código.

---

## 📋 Resumo por Prioridade

| # | Gap | Impacto Visual | Arquivo |
|---|-----|---------------|---------|
| 3 | Glow/neon nas camadas da pirâmide | 🔴 Alto | `maslow_pyramid_painter.dart` |
| 2 | Gap de separação entre camadas | 🔴 Alto | `maslow_pyramid_painter.dart` |
| 4 | Gradiente apagado nas camadas | 🔴 Alto | `maslow_pyramid_painter.dart` |
| 1 | Título da pirâmide fora do card | 🟠 Médio | `home_screen.dart` |
| 5 | Ícones sem fundo colorido vibrante | 🟠 Médio | `home_screen.dart` |
| 6 | Labels sem painel semi-transparente | 🟠 Médio | `home_screen.dart` |
| 7 | Cards de resumo com baixo contraste | 🟠 Médio | `app_theme.dart` |
| 8 | Barras do gráfico sem glow | 🟡 Baixo | `progress_screen.dart` |
| 9 | Cores do resumo inconsistentes | 🟡 Baixo | `progress_screen.dart` |
| 10 | Labels do resumo truncados | 🟡 Baixo | `progress_screen.dart` |
| 11 | Poucos hábitos na lista | 🟡 Baixo | `progress_screen.dart` |

---

## Sequência de Correção Recomendada para o Antigravity

```
[1] maslow_pyramid_painter.dart
    → Adicionar gap entre camadas (Gap 2)
    → Substituir gradiente apagado por gradiente vibrante (Gap 4)
    → Adicionar MaskFilter.blur para glow neon (Gap 3)

[2] home_screen.dart
    → Mover título para fora do card container (Gap 1)
    → Atualizar container dos ícones com fundo colorido (Gap 5)
    → Atualizar container das labels com painel escuro visível (Gap 6)

[3] app_theme.dart
    → Aumentar contraste do AppColors.surface (Gap 7)

[4] progress_screen.dart
    → Corrigir cores dos números do resumo (Gap 9)
    → Restaurar labels completos (Gap 10)
    → Adicionar mais hábitos mockados (Gap 11)
    → Adicionar glow nas barras do fl_chart (Gap 8)
```