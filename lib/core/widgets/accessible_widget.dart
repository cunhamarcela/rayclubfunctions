// Flutter imports:
import 'package:flutter/material.dart';

/// Widget que melhora a acessibilidade de seus filhos, adicionando semântica para VoiceOver
class AccessibleWidget extends StatelessWidget {
  /// O widget filho que será envolvido com semântica
  final Widget child;
  
  /// Rótulo para o widget (lido por leitores de tela)
  final String? label;
  
  /// Descrição mais detalhada (lida após o rótulo)
  final String? hint;
  
  /// Indica se o widget é um botão
  final bool isButton;
  
  /// Função a ser chamada quando o usuário ativar o item usando acessibilidade
  final VoidCallback? onTap;
  
  /// Construtor que recebe todos os parâmetros para configurar a acessibilidade
  const AccessibleWidget({
    Key? key,
    required this.child,
    this.label,
    this.hint,
    this.isButton = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      enabled: onTap != null,
      onTap: onTap,
      child: ExcludeSemantics(
        // ExcludeSemantics para evitar duplicação de leitura
        child: child,
      ),
    );
  }
}

/// Extensão para adicionar acessibilidade a qualquer widget
extension AccessibilityExtension on Widget {
  /// Adiciona semântica de acessibilidade a um widget
  Widget withAccessibility({
    String? label,
    String? hint,
    bool isButton = false,
    VoidCallback? onTap,
  }) {
    return AccessibleWidget(
      label: label,
      hint: hint,
      isButton: isButton,
      onTap: onTap,
      child: this,
    );
  }
} 