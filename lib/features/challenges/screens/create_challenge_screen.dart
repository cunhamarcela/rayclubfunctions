// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../core/router/app_router.dart';
import '../viewmodels/create_challenge_view_model.dart';
import '../widgets/user_selection_list.dart';

@RoutePage()
class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _rulesController = TextEditingController();
  final _rewardController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Adicionar listeners para atualizar o ViewModel quando o usuário digitar
    _titleController.addListener(() {
      ref.read(createChallengeViewModelProvider.notifier).updateTitle(_titleController.text);
    });
    
    _rulesController.addListener(() {
      ref.read(createChallengeViewModelProvider.notifier).updateRules(_rulesController.text);
    });
    
    _rewardController.addListener(() {
      ref.read(createChallengeViewModelProvider.notifier).updateReward(_rewardController.text);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Atualizar controladores quando o estado do ViewModel mudar
    final state = ref.read(createChallengeViewModelProvider);
    _updateControllersFromState(state);
  }
  
  void _updateControllersFromState(state) {
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
    }
    
    if (_rulesController.text != state.rules) {
      _rulesController.text = state.rules;
    }
    
    if (_rewardController.text != state.reward) {
      _rewardController.text = state.reward;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _rulesController.dispose();
    _rewardController.dispose();
    super.dispose();
  }
  
  void _selectDate(BuildContext context, bool isStartDate) async {
    final state = ref.read(createChallengeViewModelProvider);
    final initialDate = isStartDate ? state.startDate : state.endDate;
    final firstDate = isStartDate ? DateTime.now() : state.startDate;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      helpText: isStartDate ? 'Selecione a data de início' : 'Selecione a data de fim',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: isStartDate ? 'Data de início' : 'Data de fim',
      errorFormatText: 'Digite uma data válida no formato dd/mm/aaaa',
      errorInvalidText: 'Digite uma data válida',
    );
    
    if (pickedDate != null) {
      if (isStartDate) {
        ref.read(createChallengeViewModelProvider.notifier).updateStartDate(pickedDate);
      } else {
        ref.read(createChallengeViewModelProvider.notifier).updateEndDate(pickedDate);
      }
    }
  }
  
  void _navigateToInviteUsers() async {
    // Navegar para a tela de convite de usuários
    final selectedUsers = await context.router.push<List<String>>(
      InviteUsersRoute(),
    );
    
    if (selectedUsers != null) {
      ref.read(createChallengeViewModelProvider.notifier).updateInvitedUsers(selectedUsers);
    }
  }
  
  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await ref.read(createChallengeViewModelProvider.notifier).saveChallenge();
      
      if (mounted) {
        // Se não houve erro, navega de volta
        final state = ref.read(createChallengeViewModelProvider);
        if (state.error == null && !state.isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desafio criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
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
    final state = ref.watch(createChallengeViewModelProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Atualizar controladores quando o estado do ViewModel mudar
    _updateControllersFromState(state);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Novo Desafio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: state.isLoading || state.isSaving ? null : _saveChallenge,
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                    // Nome do desafio
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Desafio',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'O nome do desafio é obrigatório';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Regras do desafio
                    TextFormField(
                      controller: _rulesController,
                      decoration: const InputDecoration(
                        labelText: 'Regras do Desafio',
                        border: OutlineInputBorder(),
                        hintText: 'Descreva as regras e objetivos deste desafio',
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'As regras do desafio são obrigatórias';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Recompensa
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
                          if (reward <= 0) {
                            return 'A recompensa deve ser maior que zero';
                          }
                        } catch (_) {
                          return 'Informe um número válido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Período do desafio
                    const Text(
                      'Período do Desafio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text('Início: ${dateFormat.format(state.startDate)}'),
                            onPressed: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text('Fim: ${dateFormat.format(state.endDate)}'),
                            onPressed: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Convidar usuários
                    const Text(
                      'Participantes Convidados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Convidar Usuários'),
                      onPressed: _navigateToInviteUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    if (state.invitedUsers.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.invitedUsers.length} usuário(s) selecionado(s)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.invitedUsers
                                  .map((userId) => Chip(
                                        label: Text('Usuário $userId'),
                                        deleteIcon: const Icon(Icons.close, size: 16),
                                        onDeleted: () {
                                          ref.read(createChallengeViewModelProvider.notifier)
                                              .removeInvitedUser(userId);
                                        },
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isSaving ? null : _saveChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: state.isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'CRIAR DESAFIO',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 