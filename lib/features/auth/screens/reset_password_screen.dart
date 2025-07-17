// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authViewModelProvider.notifier).resetPassword(_emailController.text.trim());
        
        if (mounted) {
          // Mostrar mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email enviado com instruções para redefinir sua senha'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Retornar para a tela de login
          context.router.navigate(const LoginRoute());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao enviar email: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    
    // Determinar se está carregando
    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    // Mostrar mensagem de erro se existir
    state.maybeWhen(
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
          context.router.navigate(const LoginRoute());
        });
      },
      orElse: () {},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.navigate(const LoginRoute()),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Informe seu email para receber instruções de como redefinir sua senha.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Digite seu email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _handleResetPassword(),
                ),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: isLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text(
                          'Enviar email',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () => context.router.navigate(const LoginRoute()),
                  child: const Text('Voltar para o login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
