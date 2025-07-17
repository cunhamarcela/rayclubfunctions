// Flutter imports:
import 'package:flutter/material.dart';

/// Widget do formulário de cadastro reutilizável
class SignupForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String name, String email, String password) onSignup;

  const SignupForm({
    super.key,
    required this.isLoading,
    required this.onSignup,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cores do tema baseadas na tela de login
    const primaryColor = Color(0xFF8B7355);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nome input
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: const InputDecoration(
                hintText: "Nome completo",
                prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              onEditingComplete: () {
                _emailFocusNode.requestFocus();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                if (value.trim().length < 3) {
                  return 'O nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Email input
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: const InputDecoration(
                hintText: "Endereço de email",
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              onEditingComplete: () {
                _passwordFocusNode.requestFocus();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Senha input
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                hintText: "Senha",
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              onEditingComplete: () {
                _confirmPasswordFocusNode.requestFocus();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma senha';
                }
                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }
                // Validação mais forte de senha
                if (!value.contains(RegExp(r'[A-Za-z]')) || !value.contains(RegExp(r'[0-9]'))) {
                  return 'A senha deve conter letras e números';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Confirmar senha input
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              decoration: InputDecoration(
                hintText: "Confirmar senha",
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
              ),
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              onEditingComplete: () {
                // Quando pressionar Enter no último campo, tentar enviar o formulário
                if (!widget.isLoading) {
                  _handleSubmit();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, confirme sua senha';
                }
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Botão de cadastro
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: !widget.isLoading ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: primaryColor.withOpacity(0.5),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Cadastrar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 
