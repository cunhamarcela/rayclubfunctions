// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

// Project imports:
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_textures.dart';
import '../../../core/theme/app_typography.dart';
import '../viewmodels/auth_view_model.dart';
import '../../../core/providers/service_providers.dart';
import '../../../services/deep_link_service.dart';
import '../../../auth_debug.dart';
import '../widgets/apple_sign_in_button.dart';
import '../widgets/signup_form.dart';

@RoutePage()
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);
    final viewModel = ref.read(authViewModelProvider.notifier);
    
    // Redirecionar se já estiver autenticado
    state.maybeWhen(
      authenticated: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Verificar se há um caminho para redirecionamento
          final redirectPath = viewModel.redirectPath;
          if (redirectPath != null && redirectPath.isNotEmpty) {
            // Limpar o caminho de redirecionamento e navegar para ele
            viewModel.clearRedirectPath();
            context.router.replaceNamed(redirectPath);
          } else {
            // Usar o método do ViewModel para garantir consistência na navegação
            viewModel.navigateToHomeAfterAuth(context);
          }
        });
      },
      pendingEmailVerification: (email, userId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Navegar para a tela de verificação de email
          context.router.replace(
            EmailVerificationRoute(
              email: email,
              userId: userId,
            ),
          );
        });
      },
      orElse: () {},
    );
    
    // Verificar se há mensagem de erro para mostrar
    state.maybeWhen(
      error: (message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Limpar erros anteriores
          ScaffoldMessenger.of(context).clearSnackBars();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 4), // Dar mais tempo para ler
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        });
      },
      orElse: () {},
    );

    // Cores do tema baseadas na tela de login
    const primaryColor = Color(0xFF8B7355);
    const backgroundColor = Color(0xFFF8F5F2);
    const secondaryBackgroundColor = Color(0xFFEDE8E3);
    final accentColor = primaryColor.withOpacity(0.7);
    
    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, secondaryBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  
                  // Botão de voltar e título
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF333333)),
                        onPressed: () => context.router.maybePop(),
                      ),
                      const Text(
                        "Criar conta",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Título principal
                  const Text(
                    "Seja bem vinda",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Junte-se ao Ray Club e comece sua jornada",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Substituto para a ilustração: Ícones circulares representando features
                  SizedBox(
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Círculo central
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        
                        // Ícones orbitando ao redor
                        ...List.generate(6, (index) {
                          final angle = index * (3.14159 * 2 / 6);
                          final x = math.cos(angle) * 70;
                          final y = math.sin(angle) * 70;
                          
                          // Escolher ícone baseado no índice
                          IconData iconData;
                          switch (index) {
                            case 0:
                              iconData = Icons.restaurant;
                              break;
                            case 1:
                              iconData = Icons.directions_run;
                              break;
                            case 2:
                              iconData = Icons.emoji_events;
                              break;
                            case 3:
                              iconData = Icons.local_fire_department;
                              break;
                            case 4:
                              iconData = Icons.favorite;
                              break;
                            case 5:
                              iconData = Icons.star;
                              break;
                            default:
                              iconData = Icons.fitness_center;
                          }
                          
                          return Positioned(
                            left: MediaQuery.of(context).size.width / 2 - 24 + x - 36, // Centralizar
                            top: 90 + y - 24,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: index % 2 == 0 ? accentColor : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                iconData,
                                color: index % 2 == 0 ? Colors.white : primaryColor,
                                size: 24,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Formulário de cadastro
                  SignupForm(
                    isLoading: isLoading,
                    onSignup: (name, email, password) {
                      viewModel.signUp(email, password, name);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Ou continue com",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Google Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: !isLoading ? () {
                        ref.read(authViewModelProvider.notifier).signInWithGoogle();
                      } : null,
                      icon: SvgPicture.asset(
                        'assets/icons/google.svg',
                        height: 24,
                        width: 24,
                        placeholderBuilder: (context) => const Icon(Icons.public, size: 24, color: Colors.blue),
                      ),
                      label: const Text(
                        "Continuar com Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[200]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Apple Login Button
                  AppleSignInButton(
                    onPressed: !isLoading ? () {
                      ref.read(authViewModelProvider.notifier).signInWithApple();
                    } : null,
                    isLoading: isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Já tem uma conta?",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: !isLoading ? () {
                          context.router.pushNamed(AppRoutes.login);
                        } : null,
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.only(left: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Faça login",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para texto circular rotacionado
class RotatingText extends StatelessWidget {
  final String text;
  final double radius;
  final TextStyle textStyle;
  
  const RotatingText({
    super.key,
    required this.text,
    required this.radius,
    required this.textStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RotatingTextPainter(
        text: text,
        radius: radius,
        textStyle: textStyle,
      ),
      size: Size.square(radius * 2),
    );
  }
}

class _RotatingTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final TextStyle textStyle;
  
  _RotatingTextPainter({
    required this.text,
    required this.radius,
    required this.textStyle,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    
    final spacing = 0.22; // espaçamento entre caracteres em radianos
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i < text.length; i++) {
      final double angle = i * spacing;
      final char = text[i];
      
      canvas.save();
      canvas.rotate(angle);
      
      textPainter.text = TextSpan(
        text: char,
        style: textStyle,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -radius));
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(_RotatingTextPainter oldDelegate) => 
    text != oldDelegate.text || 
    radius != oldDelegate.radius || 
    textStyle != oldDelegate.textStyle;
} 
