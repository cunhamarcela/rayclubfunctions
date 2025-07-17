// Flutter imports:
import 'package:flutter/material.dart';

/// Widget que exibe a foto do perfil do usuário com fallback para um placeholder
class UserAvatar extends StatelessWidget {
  /// URL da foto do usuário
  final String? photoUrl;
  
  /// Nome do usuário (usado para gerar a inicial se não houver foto)
  final String? name;
  
  /// Tamanho do avatar
  final double size;
  
  /// Borda do avatar
  final Border? border;
  
  /// Construtor
  const UserAvatar({
    Key? key,
    this.photoUrl,
    this.name,
    this.size = 48.0,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // PATCH: Corrigir bug 4 - garantir que a foto do usuário tenha um fallback
    final hasValidPhotoUrl = photoUrl != null && photoUrl!.isNotEmpty;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: border,
      ),
      child: hasValidPhotoUrl
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Se falhar o carregamento da imagem, exibir inicial do nome
                return _buildInitialsPlaceholder(context);
              },
            )
          : _buildInitialsPlaceholder(context),
    );
  }
  
  /// Constrói um placeholder com as iniciais do usuário ou um ícone genérico
  Widget _buildInitialsPlaceholder(BuildContext context) {
    if (name != null && name!.isNotEmpty) {
      return Center(
        child: Text(
          name![0].toUpperCase(),
          style: TextStyle(
            fontSize: size / 2.5,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    } else {
      return Center(
        child: Icon(
          Icons.person,
          size: size / 1.8,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
  }
} 