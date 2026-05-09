import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _nameController = TextEditingController();
  int _selectedFrequency = 0; // 0=Diário, 1=Semanal, 2=Personalizado
  int _selectedMaslowLevel = 1; // 1-5

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Cores neon por nível Maslow (matching the HTML reference)
  Color _neonColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFF4D4D); // vermelho
      case 2:
        return const Color(0xFFFFAA00); // laranja
      case 3:
        return const Color(0xFF00F2FF); // cyan
      case 4:
        return const Color(0xFF007FFF); // azul
      case 5:
        return const Color(0xFFBF00FF); // roxo
      default:
        return AppColors.primary;
    }
  }

  IconData _maslowIcon(int level) {
    switch (level) {
      case 1:
        return Icons.restaurant_rounded;
      case 2:
        return Icons.shield_rounded;
      case 3:
        return Icons.people_rounded;
      case 4:
        return Icons.favorite_rounded;
      case 5:
        return Icons.star_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    'Criar Novo Hábito',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // balance
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do hábito
                      _buildNameInput(),
                      const SizedBox(height: 32),

                      // Frequência
                      _buildFrequencySection(),
                      const SizedBox(height: 32),

                      // Nível Maslow
                      _buildMaslowSection(),
                      const SizedBox(height: 32),

                      // Botão Salvar
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Nome do Hábito',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.edit_rounded,
                color: Colors.white.withOpacity(0.4), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySection() {
    final labels = ['Diário', 'Semanal', 'Personalizado'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequência', style: AppTextStyles.heading2),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF120E24),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(3, (i) {
              final isSelected = _selectedFrequency == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFrequency = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primary.withOpacity(0.8),
                              width: 2,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 20,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMaslowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nível da Pirâmide de Maslow',
            style: AppTextStyles.heading2),
        const SizedBox(height: 20),
        Row(
          children: List.generate(5, (i) {
            final level = i + 1;
            final isSelected = _selectedMaslowLevel == level;
            final color = _neonColor(level);
            final name = MaslowLevels.getName(level);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMaslowLevel = level),
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : color.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 16,
                                  ),
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 28,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _maslowIcon(level),
                          color: isSelected ? color : color.withOpacity(0.5),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : color.withOpacity(0.5),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            // TODO: salvar hábito
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.6),
                  blurRadius: 20,
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Salvar Hábito',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
