// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/ray_button.dart';
import '../viewmodels/challenge_group_view_model.dart';

@RoutePage()
class CreateChallengeGroupScreen extends ConsumerStatefulWidget {
  const CreateChallengeGroupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateChallengeGroupScreen> createState() => _CreateChallengeGroupScreenState();
}

class _CreateChallengeGroupScreenState extends ConsumerState<CreateChallengeGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(challengeGroupViewModelProvider.notifier).createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo criado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar grupo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Criar Novo Grupo',
      ),
      body: _isLoading
          ? const Center(child: AppLoading())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagem ilustrativa
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Icon(
                        Icons.group_add,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo nome do grupo
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do grupo',
                        hintText: 'Ex: Amigos do Ray Club',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O nome do grupo é obrigatório';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo descrição
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Descreva o propósito do grupo',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Texto explicativo
                    Text(
                      'Ao criar um grupo, você poderá convidar amigos para acompanhar o progresso e visualizar rankings específicos.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botão de criação
                    RayButton(
                      label: 'Criar Grupo',
                      onPressed: _createGroup,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 