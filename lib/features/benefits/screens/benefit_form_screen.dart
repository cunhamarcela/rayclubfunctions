// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/benefit.dart';
import '../viewmodels/benefit_view_model.dart';

/// Tela de formulário para criação/edição de benefícios
@RoutePage()
class BenefitFormScreen extends ConsumerStatefulWidget {
  /// ID do benefício (opcional, para edição)
  final String? benefitId;

  const BenefitFormScreen({Key? key, @QueryParam() this.benefitId}) : super(key: key);

  @override
  ConsumerState<BenefitFormScreen> createState() => _BenefitFormScreenState();
}

class _BenefitFormScreenState extends ConsumerState<BenefitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _partnerController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _termsController = TextEditingController();
  final _pointsController = TextEditingController();
  
  DateTime? _expirationDate;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _benefitId;
  
  @override
  void initState() {
    super.initState();
    _benefitId = widget.benefitId;
    _isEditing = _benefitId != null;
    
    if (_isEditing) {
      _loadBenefitData();
    }
  }
  
  /// Carrega dados do benefício para edição
  Future<void> _loadBenefitData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final benefit = await ref.read(benefitViewModelProvider.notifier).getBenefitById(_benefitId!);
      
      if (benefit != null && mounted) {
        setState(() {
          _titleController.text = benefit.title;
          _descriptionController.text = benefit.description;
          _partnerController.text = benefit.partner;
          _imageUrlController.text = benefit.imageUrl ?? '';
          _termsController.text = benefit.terms ?? '';
          _pointsController.text = benefit.pointsRequired.toString();
          _expirationDate = benefit.expirationDate;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar dados do benefício'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _partnerController.dispose();
    _imageUrlController.dispose();
    _termsController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Benefício' : 'Novo Benefício'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Digite o título do benefício',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite um título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Digite a descrição do benefício',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite uma descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _partnerController,
                      decoration: const InputDecoration(
                        labelText: 'Parceiro',
                        hintText: 'Digite o nome do parceiro',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite o nome do parceiro';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL da Imagem',
                        hintText: 'Digite a URL da imagem do benefício',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pointsController,
                      decoration: const InputDecoration(
                        labelText: 'Pontos Necessários',
                        hintText: 'Digite a quantidade de pontos necessários',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite a quantidade de pontos';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor, digite um número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _termsController,
                      decoration: const InputDecoration(
                        labelText: 'Termos e Condições',
                        hintText: 'Digite os termos e condições do benefício',
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    _buildExpirationDateField(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveBenefit,
                        child: Text(_isEditing ? 'Atualizar Benefício' : 'Criar Benefício'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  /// Constrói o campo de data de expiração
  Widget _buildExpirationDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data de Expiração (opcional)'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            
            if (date != null) {
              setState(() {
                _expirationDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _expirationDate != null
                        ? 'Expira em: ${_formatDate(_expirationDate!)}'
                        : 'Sem data de expiração',
                  ),
                ),
                if (_expirationDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _expirationDate = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Formata a data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Salva o benefício no banco de dados
  Future<void> _saveBenefit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final benefit = Benefit(
        id: _benefitId ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        partner: _partnerController.text,
        imageUrl: _imageUrlController.text.isEmpty ? '' : _imageUrlController.text,
        terms: _termsController.text.isEmpty ? null : _termsController.text,
        expirationDate: _expirationDate ?? DateTime.now().add(const Duration(days: 30)),
        pointsRequired: int.parse(_pointsController.text),
        availableQuantity: 10, // Valor padrão
      );
      
      bool success;
      if (_isEditing) {
        success = await ref.read(benefitViewModelProvider.notifier).updateBenefit(benefit);
      } else {
        success = await ref.read(benefitViewModelProvider.notifier).createBenefit(benefit);
      }
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                  ? 'Benefício atualizado com sucesso' 
                  : 'Benefício criado com sucesso'
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing 
                  ? 'Erro ao atualizar benefício' 
                  : 'Erro ao criar benefício'
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 