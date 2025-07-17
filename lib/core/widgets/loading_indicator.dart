import 'package:flutter/material.dart';

/// Widget para exibir um indicador de carregamento centralizado
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;
  final String? message;
  final double? value;

  const LoadingIndicator({
    Key? key,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.message,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color,
              strokeWidth: strokeWidth,
              value: value,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color ?? Theme.of(context).primaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 