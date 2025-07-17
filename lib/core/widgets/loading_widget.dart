// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';

/// Widget padrão para exibir estado de carregamento na aplicação.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final bool withContainer;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 40.0,
    this.withContainer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingIndicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        strokeWidth: 3.0,
      ),
    );

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        loadingIndicator,
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (withContainer) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        ),
      );
    }

    return Center(child: content);
  }
}

/// Widget para exibir um indicador de carregamento em linha
/// Útil para carregar mais itens em listas ou indicar processamento
class InlineLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const InlineLoadingWidget({
    Key? key,
    this.message,
    this.size = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2.0,
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 12),
          Text(
            message!,
            style: AppTextStyles.smallText,
          ),
        ],
      ],
    );
  }
} 