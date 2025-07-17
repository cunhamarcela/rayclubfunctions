// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../core/theme/app_colors.dart';

/// Um widget simples para mostrar indicador de carregamento
class LoadingView extends StatelessWidget {
  /// Optional message to show below the loading indicator
  final String? message;
  
  /// Constructor with optional parameters
  const LoadingView({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 