import 'package:flutter/material.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';

/// Um botão customizado para o app Ray Club
class RayButton extends StatelessWidget {
  /// Texto do botão
  final String label;

  /// Função a ser executada quando o botão for pressionado
  final VoidCallback onPressed;

  /// Cor de fundo do botão (opcional, padrão é AppColors.primary)
  final Color? backgroundColor;

  /// Cor do texto do botão (opcional, padrão é Colors.white)
  final Color? textColor;

  /// Elevação do botão (opcional, padrão é 2.0)
  final double? elevation;

  /// Se o botão deve ocupar toda a largura disponível (opcional, padrão é true)
  final bool fullWidth;

  /// Se o botão está desabilitado (opcional, padrão é false)
  final bool isDisabled;

  /// Ícone a ser exibido antes do texto (opcional)
  final IconData? icon;

  /// Tamanho da fonte do texto (opcional, padrão é 16.0)
  final double? fontSize;

  /// Padding interno do botão (opcional)
  final EdgeInsetsGeometry? padding;

  /// Radius das bordas do botão (opcional, padrão é 12.0)
  final double borderRadius;

  const RayButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.fullWidth = true,
    this.isDisabled = false,
    this.icon,
    this.fontSize,
    this.padding,
    this.borderRadius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          elevation: elevation ?? 2.0,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBackgroundColor: Colors.grey.shade400,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor ?? Colors.white,
                size: (fontSize ?? 16.0) + 4,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 