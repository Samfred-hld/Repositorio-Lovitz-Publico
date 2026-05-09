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
