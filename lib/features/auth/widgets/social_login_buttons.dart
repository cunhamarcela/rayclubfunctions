// Flutter imports:
import 'package:flutter/material.dart';

/// Widget de botões de login social
class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleLogin;
  final VoidCallback? onAppleLogin;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleLogin,
    this.onAppleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Google login button
        SocialButton(
          onPressed: onGoogleLogin,
          icon: 'assets/icons/google.png',
          label: 'Google',
        ),
        
        // Apple login button (opcional)
        if (onAppleLogin != null)
          SocialButton(
            onPressed: onAppleLogin!,
            icon: 'assets/icons/apple.png',
            label: 'Apple',
            isDark: true,
          ),
      ],
    );
  }
}

/// Botão individual para login social
class SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String label;
  final bool isDark;

  const SocialButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  icon,
                  height: 30,
                  width: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
