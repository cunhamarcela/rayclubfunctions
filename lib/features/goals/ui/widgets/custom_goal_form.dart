// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// **FORMULÁRIO PARA META PERSONALIZADA**
/// 
/// Campo de texto onde o usuário pode escrever
/// o título da meta que ele quiser
class CustomGoalForm extends StatelessWidget {
  final TextEditingController titleController;

  const CustomGoalForm({
    super.key,
    required this.titleController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Título da sua meta',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escreva um título personalizado para sua meta. '
          'Você controlará o progresso manualmente.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Ex: Praticar meditação diariamente',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant.withOpacity(0.3),
            prefixIcon: Icon(
              Icons.edit,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Digite um título para sua meta';
            }
            if (value.trim().length < 3) {
              return 'O título deve ter pelo menos 3 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }
}

