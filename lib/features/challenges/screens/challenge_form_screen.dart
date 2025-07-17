// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_view.dart';
import '../viewmodels/challenge_form_view_model.dart';
import '../viewmodels/challenge_form_state.dart';

@RoutePage()
class ChallengeFormScreen extends ConsumerStatefulWidget {
  final String? challengeId;
  
  const ChallengeFormScreen({
    @PathParam('id') this.challengeId,
    super.key,
  });

  @override
  ConsumerState<ChallengeFormScreen> createState() => _ChallengeFormScreenState();
}

class _ChallengeFormScreenState extends ConsumerState<ChallengeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Se for edição, carrega os dados do desafio
    if (widget.challengeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(challengeFormViewModelProvider.notifier).loadChallenge(widget.challengeId!);
      });
    }
    
    // Adicionar listeners para atualizar o ViewModel quando o usuário digitar
    _titleController.addListener(() {
      ref.read(challengeFormViewModelProvider.notifier).updateTitle(_titleController.text);
    });
    
    _descriptionController.addListener(() {
      ref.read(challengeFormViewModelProvider.notifier).updateDescription(_descriptionController.text);
    });
    
    _rewardController.addListener(() {
      ref.read(challengeFormViewModelProvider.notifier).updateReward(_rewardController.text);
    });
    
    _imageUrlController.addListener(() {
      ref.read(challengeFormViewModelProvider.notifier).updateImageUrl(_imageUrlController.text);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Atualizar controladores quando o estado do ViewModel mudar
    final state = ref.read(challengeFormViewModelProvider);
    _updateControllersFromState(state);
  }
  
  void _updateControllersFromState(ChallengeFormState state) {
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
    }
    
    if (_descriptionController.text != state.description) {
      _descriptionController.text = state.description;
    }
    
    if (_rewardController.text != state.points.toString()) {
      _rewardController.text = state.points.toString();
    }
    
    if (_imageUrlController.text != (state.imageUrl ?? '')) {
      _imageUrlController.text = state.imageUrl ?? '';
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final state = ref.read(challengeFormViewModelProvider);
    final initialDate = isStartDate ? state.startDate : state.endDate;
    final firstDate = isStartDate ? DateTime.now() : state.startDate;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      if (isStartDate) {
        ref.read(challengeFormViewModelProvider.notifier).updateStartDate(pickedDate);
      } else {
        ref.read(challengeFormViewModelProvider.notifier).updateEndDate(pickedDate);
      }
    }
  }
  
  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(challengeFormViewModelProvider.notifier).saveChallenge();
      
      if (mounted) {
        // Se não houve erro, navega de volta
        final state = ref.read(challengeFormViewModelProvider);
        if (state.errorMessage.isEmpty && !state.isSubmitting) {
          context.router.maybePop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeFormViewModelProvider);
    
    // Atualizar controladores quando o estado do ViewModel mudar
    _updateControllersFromState(state);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challengeId != null ? 'Editar Desafio' : 'Novo Desafio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: state.isSubmitting ? null : _saveChallenge,
          ),
        ],
      ),
      body: state.isSubmitting
          ? const LoadingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O título é obrigatório';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'A descrição é obrigatória';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _rewardController,
                      decoration: const InputDecoration(
                        labelText: 'Recompensa (pontos)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'A recompensa é obrigatória';
                        }
                        try {
                          final reward = int.parse(value);
                          if (reward < 0) {
                            return 'A recompensa não pode ser negativa';
                          }
                        } catch (_) {
                          return 'Informe um número válido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL da imagem (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Período do desafio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data de início',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(state.startDate),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data de término',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(state.endDate),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting ? null : _saveChallenge,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('SALVAR'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 
