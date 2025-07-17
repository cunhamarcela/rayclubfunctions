// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:io';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_record_view_model.dart';
import 'package:ray_club_app/core/widgets/loading_indicator.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';

@RoutePage()
class WorkoutRecordFormScreen extends ConsumerStatefulWidget {
  const WorkoutRecordFormScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkoutRecordFormScreen> createState() => _WorkoutRecordFormScreenState();
}

class _WorkoutRecordFormScreenState extends ConsumerState<WorkoutRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos de texto
  final _workoutNameController = TextEditingController();
  final _durationController = TextEditingController();
  
  @override
  void dispose() {
    _workoutNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Estado do ViewModel
    final viewModelState = ref.watch(workoutRecordViewModelProvider);
    final viewModel = ref.watch(workoutRecordViewModelProvider.notifier);
    final isLoading = viewModelState.isLoading;

    // Valores do ViewModel para uso na UI
    final selectedWorkoutType = viewModelState.selectedWorkoutType;
    final intensity = viewModelState.intensity;
    final selectedImages = viewModelState.selectedImages;
    final intensityText = viewModel.intensityText;
    final workoutTypes = viewModel.workoutTypes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Registrar Treino', style: AppTypography.headingMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Opacidade baixa para não interferir na leitura
              child: Image.asset(
                'assets/images/logos/app/padronagem_3.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Conteúdo da tela
          isLoading
              ? const Center(child: LoadingIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome do exercício
                          _buildSectionTitle('Nome do exercício'),
                          _buildTextField(
                            controller: _workoutNameController,
                            hintText: 'Ex: Agachamento, Supino, Yoga...',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe o nome do exercício';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Tipo de exercício
                          _buildSectionTitle('Tipo de exercício'),
                          _buildDropdown(
                            selectedWorkoutType: selectedWorkoutType,
                            workoutTypes: workoutTypes,
                            onChanged: (newValue) {
                              if (newValue != null) {
                                viewModel.updateWorkoutType(newValue);
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          // Duração
                          _buildSectionTitle('Duração (minutos)'),
                          _buildTextField(
                            controller: _durationController,
                            hintText: 'Ex: 30',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe a duração';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return 'Informe um número válido de minutos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Intensidade
                          _buildSectionTitle('Intensidade'),
                          _buildIntensitySlider(
                            intensity: intensity,
                            onChanged: (value) {
                              viewModel.updateIntensity(value);
                            },
                          ),
                          const SizedBox(height: 24),

                          // Upload de imagem
                          _buildSectionTitle('Imagem do treino (opcional)'),
                          _buildImagePicker(
                            selectedImages: selectedImages,
                            onTap: () => viewModel.pickImage(),
                          ),
                          if (selectedImages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${selectedImages.length}/3 imagens selecionadas',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textLight,
                                  fontStyle: FontStyle.italic
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          const SizedBox(height: 32),

                          // Botão de salvar
                          _buildSaveButton(
                            onPressed: () => _saveWorkoutRecord(
                              viewModel, 
                              intensityText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String selectedWorkoutType,
    required List<String> workoutTypes,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedWorkoutType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textDark),
          onChanged: onChanged,
          items: workoutTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIntensitySlider({
    required double intensity,
    required void Function(double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leve',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
            ),
            Text(
              'Moderada',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
            ),
            Text(
              'Intensa',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: intensity,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker({
    required List<XFile> selectedImages,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: selectedImages.isNotEmpty
            ? _buildImagePreview(selectedImages)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Toque para adicionar uma foto',
                    style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    'Registre visualmente seu progresso',
                    style: AppTypography.bodySmall.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImagePreview(List<XFile> selectedImages) {
    if (selectedImages.isEmpty) {
      return Container();
    }
    
    // Se tivermos apenas uma imagem, exibimos full
    if (selectedImages.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(selectedImages[0].path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'Erro ao carregar imagem',
                style: AppTypography.bodySmall.copyWith(color: Colors.red),
              ),
            );
          },
        ),
      );
    }
    
    // Se tivermos múltiplas imagens, mostramos uma grade
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: selectedImages.length >= 3 ? 3 : 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: selectedImages.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(selectedImages[index].path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(Icons.broken_image, color: Colors.red[300]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSaveButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Salvar',
          style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveWorkoutRecord(WorkoutRecordViewModel viewModel, String intensityText) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Salvar o registro usando o ViewModel
        // Passando as imagens selecionadas para o viewModel
        await viewModel.addWorkoutRecord(
          workoutName: _workoutNameController.text,
          workoutType: viewModel.state.selectedWorkoutType,
          date: DateTime.now(),
          durationMinutes: int.parse(_durationController.text),
          isCompleted: true,
          notes: "intensidade: $intensityText", // Armazenar a intensidade como nota
          workoutId: const Uuid().v4(), // Gera ID único
          imagesToUpload: viewModel.state.selectedImages,
        );
        
        // Forçar atualização dos outros ViewModels para manter os dados sincronizados
        ref.refresh(dashboardViewModelProvider);
        ref.refresh(workoutViewModelProvider);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino registrado com sucesso!')),
        );
        
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar treino: $e')),
        );
      }
    }
  }
} 