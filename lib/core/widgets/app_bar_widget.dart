import 'package:flutter/material.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';

/// AppBar personalizado para o aplicativo
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// Título da AppBar
  final String title;
  
  /// Ícone para a ação de voltar (null para usar o padrão)
  final IconData? backIcon;
  
  /// Callback para quando o botão de voltar for pressionado
  final VoidCallback? onBackPressed;
  
  /// Indica se o botão de voltar deve ser mostrado
  final bool showBackButton;
  
  /// Ações adicionais para serem exibidas na AppBar
  final List<Widget>? actions;
  
  /// Conteúdo flexível exibido no centro da AppBar
  final Widget? flexibleSpace;
  
  /// Altura da AppBar
  final double height;
  
  /// Cores do tema da AppBar
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  /// Cria um AppBarWidget
  const AppBarWidget({
    Key? key,
    required this.title,
    this.backIcon,
    this.onBackPressed,
    this.showBackButton = true,
    this.actions,
    this.flexibleSpace,
    this.height = kToolbarHeight,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(backIcon ?? Icons.arrow_back_ios),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      flexibleSpace: flexibleSpace,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 0,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(height);
} 