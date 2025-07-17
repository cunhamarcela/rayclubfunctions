// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../viewmodels/auth_view_model.dart';

@RoutePage()
class EmailVerificationScreen extends ConsumerWidget {
  final String email;
  final String? userId;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    
    // Verificar se o usuário já está autenticado
    authState.maybeWhen(
      authenticated: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authViewModelProvider.notifier).navigateToHomeAfterAuth(context);
        });
      },
      orElse: () {},
    );
    
    // Verificar se há mensagem de erro para mostrar
    authState.maybeWhen(
      error: (message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        });
      },
      success: (message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        });
      },
      orElse: () {},
    );
    
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => context.router.replace(const LoginRoute()),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícone de email
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Título
              Text(
                'Verifique seu Email',
                style: AppTypography.headingMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Mensagem
              Text(
                'Enviamos um link de verificação para $email\n\nPor favor, verifique sua caixa de entrada e clique no link para ativar sua conta.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Botão para reenviar email
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ref.read(authViewModelProvider.notifier).resendVerificationEmail(email);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Reenviar Email',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Botão para voltar para login
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.router.replace(const LoginRoute()),
                child: const Text(
                  'Voltar para Login',
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Instruções adicionais
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Não recebeu o email?',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Verifique sua pasta de spam ou lixo eletrônico\n'
                      '• Certifique-se de que o endereço de email está correto\n'
                      '• Se o problema persistir, clique em "Reenviar Email"',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 