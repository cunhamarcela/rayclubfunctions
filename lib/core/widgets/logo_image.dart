import 'package:flutter/material.dart';
import '../constants/app_logos.dart';

/// Widget para exibir logos de forma consistente em todo o aplicativo
class LogoImage extends StatelessWidget {
  /// O logo a ser exibido
  final Logo logo;
  
  /// Largura do logo (opcional)
  final double? width;
  
  /// Altura do logo (opcional)
  final double? height;
  
  /// Tamanho do logo (define altura e largura iguais)
  final double? size;
  
  /// Cor de filtro para aplicar ao logo (útil para logos monocromáticos)
  final Color? color;
  
  /// Ajuste de encaixe da imagem
  final BoxFit fit;
  
  /// Espaçamento em volta do logo
  final EdgeInsetsGeometry? padding;
  
  /// Callback quando ocorrer erro ao carregar o logo
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  
  /// Constructor
  const LogoImage({
    super.key,
    required this.logo,
    this.width,
    this.height,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
    this.padding,
    this.errorBuilder,
  }) : assert(
    (width != null && height != null) || size != null || (width == null && height == null),
    'Especifique width e height juntos, ou apenas size, ou nenhum deles'
  );
  
  /// Constructor alternativo para criar pelo ID do logo
  factory LogoImage.byId({
    Key? key,
    required String logoId,
    double? width,
    double? height,
    double? size,
    Color? color,
    BoxFit fit = BoxFit.contain,
    EdgeInsetsGeometry? padding,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    final logo = AppLogos.getLogoById(logoId);
    if (logo == null) {
      return LogoImage(
        key: key,
        logo: AppLogos.rayClubIcon, // Fallback para o ícone do app
        width: width,
        height: height,
        size: size,
        color: color,
        fit: fit,
        padding: padding,
        errorBuilder: errorBuilder,
      );
    }
    
    return LogoImage(
      key: key,
      logo: logo,
      width: width,
      height: height,
      size: size,
      color: color,
      fit: fit,
      padding: padding,
      errorBuilder: errorBuilder,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      logo.path,
      width: size ?? width,
      height: size ?? height,
      fit: fit,
      color: color,
      errorBuilder: errorBuilder ?? _defaultErrorBuilder,
    );
    
    if (padding != null) {
      return Padding(
        padding: padding!,
        child: image,
      );
    }
    
    return image;
  }
  
  /// Builder padrão para erros de carregamento
  Widget _defaultErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      width: size ?? width ?? 48,
      height: size ?? height ?? 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: (size ?? width ?? height ?? 48) * 0.5,
          color: Colors.grey[400],
        ),
      ),
    );
  }
} 