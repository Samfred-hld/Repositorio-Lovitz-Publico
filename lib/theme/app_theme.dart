import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1E1E38);
  static const Color surfaceVariant = Color(0xFF1C1C35);

  // Cards & Borders
  static const Color cardBorder = Color(0x14FFFFFF);     // rgba(255, 255, 255, 0.08)
  static const Color cardBackground = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)

  // Primárias / Destaques
  static const Color primary = Color(0xFF8B70E8);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6040C0);

  // Maslow (do topo à base — cores vibrantes estilo mockup)
  static const Color maslowAutorealizacao = Color(0xFF8B6CE0); // Nível 5 — roxo
  static const Color maslowEstima = Color(0xFF5B8FD4);          // Nível 4 — azul
  static const Color maslowPertencimento = Color(0xFFD45BA0);   // Nível 3 — rosa
  static const Color maslowSeguranca = Color(0xFFE89040);       // Nível 2 — laranja
  static const Color maslowFisiologico = Color(0xFFE8C840);     // Nível 1 — amarelo

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary = Color(0x73FFFFFF);  // 45%

  // Outros Acentos
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color accentSuccess = Color(0xFF6FCF97);
  static const Color accentXP = Color(0xFFF2994A);

  // Compatibilidade Widgets
  static const Color progressRingFill = primary;
  static const Color progressRingBg = cardBackground;
}

class AppTextStyles {
  static TextStyle heading1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static TextStyle buttonText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle streakNumber = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.accentOrange,
  );
}

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
