// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:ray_club_app/core/viewmodels/base_view_model.dart';
import 'package:ray_club_app/features/profile/models/profile_model.dart';
import 'package:ray_club_app/features/profile/viewmodels/profile_view_model.dart';
import 'package:ray_club_app/features/profile/providers/profile_providers.dart';
import 'package:ray_club_app/utils/form_validator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_picker_utils.dart';

@RoutePage()
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instagramController = TextEditingController();
  
  DateTime? _birthDate;
  String? _gender;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<String> _genderOptions = [
    'Masculino', 
    'Feminino', 
    'Não binário', 
    'Prefiro não informar'
  ];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    debugPrint('🔍 ProfileEditScreen - _loadUserData chamado');
    
    final profileState = ref.read(profileViewModelProvider);
    debugPrint('   - Estado atual: ${profileState.runtimeType}');
    
    if (profileState is BaseStateData<Profile>) {
      final profile = profileState.data;
      
      debugPrint('📋 Dados do perfil carregados:');
      debugPrint('   - Nome: ${profile.name}');
      debugPrint('   - Email: ${profile.email}');
      debugPrint('   - Telefone: ${profile.phone}');
      debugPrint('   - Instagram: ${profile.instagram}');
      debugPrint('   - Gênero: ${profile.gender}');
      debugPrint('   - Data nascimento: ${profile.birthDate}');
      
      // ✅ Só atualiza os controllers se os valores mudaram para evitar loops
      if (_nameController.text != (profile.name ?? '')) {
        debugPrint('🔄 Atualizando campo nome: "${_nameController.text}" -> "${profile.name ?? ''}"');
        _nameController.text = profile.name ?? '';
      }
      if (_emailController.text != (profile.email ?? '')) {
        debugPrint('🔄 Atualizando campo email: "${_emailController.text}" -> "${profile.email ?? ''}"');
        _emailController.text = profile.email ?? '';
      }
      if (_phoneController.text != (profile.phone ?? '')) {
        debugPrint('🔄 Atualizando campo telefone: "${_phoneController.text}" -> "${profile.phone ?? ''}"');
        _phoneController.text = profile.phone ?? '';
      }
      if (_instagramController.text != (profile.instagram ?? '')) {
        debugPrint('🔄 Atualizando campo instagram: "${_instagramController.text}" -> "${profile.instagram ?? ''}"');
        _instagramController.text = profile.instagram ?? '';
      }
      if (_gender != profile.gender) {
        debugPrint('🔄 Atualizando gênero: "$_gender" -> "${profile.gender}"');
        setState(() {
          _gender = profile.gender;
        });
      }
      if (_birthDate != profile.birthDate) {
        debugPrint('🔄 Atualizando data nascimento: "$_birthDate" -> "${profile.birthDate}"');
        setState(() {
          _birthDate = profile.birthDate;
        });
      }
      
      debugPrint('✅ _loadUserData concluído');
    } else {
      debugPrint('⚠️ Estado do perfil não é BaseStateData: ${profileState.runtimeType}');
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      debugPrint('🔍 Iniciando salvamento do perfil...');
      
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final instagram = _instagramController.text.trim();
      final gender = _gender;
      final birthDate = _birthDate;
      
      debugPrint('📋 Dados a serem salvos:');
      debugPrint('   - Nome: ${name.isNotEmpty ? name : 'vazio'}');
      debugPrint('   - Telefone: ${phone.isNotEmpty ? phone : 'vazio'}');
      debugPrint('   - Instagram: ${instagram.isNotEmpty ? instagram : 'vazio'}');
      debugPrint('   - Gênero: ${gender ?? 'não selecionado'}');
      debugPrint('   - Data nascimento: ${birthDate?.toString() ?? 'não selecionada'}');
      
      await ref.read(profileViewModelProvider.notifier).updateProfile(
        name: name.isNotEmpty ? name : null,
        phone: phone.isNotEmpty ? phone : null,
        gender: gender,
        birthDate: birthDate,
        instagram: instagram.isNotEmpty ? instagram : null,
      );
      
      final currentState = ref.read(profileViewModelProvider);
      final currentEmail = currentState is BaseStateData<Profile>
                          ? currentState.data.email
                          : null;
      final newEmail = _emailController.text.trim();
      
      if (newEmail != currentEmail && newEmail.isNotEmpty) {
        debugPrint('🔄 Atualizando email...');
        await ref.read(profileViewModelProvider.notifier).updateEmail(newEmail);
        debugPrint('✅ Email atualizado');
      }
      
      debugPrint('✅ Perfil salvo com sucesso');
      
      // 🔄 FORÇA INVALIDAÇÃO COMPLETA DE TODOS OS PROVIDERS
      debugPrint('🔄 Forçando invalidação completa de providers...');
      ref.invalidate(profileViewModelProvider);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(userDisplayNameProvider);
      ref.invalidate(userPhotoUrlProvider);
      
      // Aguardar um pouco para garantir que as invalidações sejam processadas
      await Future.delayed(const Duration(milliseconds: 500));
      
      // ✅ Forçar recarregamento dos dados após invalidação
      debugPrint('🔄 Recarregando dados após invalidação...');
      await ref.read(profileViewModelProvider.notifier).loadData();
      
      // Recarregar dados locais também
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserData();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // 🔄 AGUARDAR MAIS UM POUCO ANTES DE SAIR DA TELA
        await Future.delayed(const Duration(milliseconds: 300));
        
        debugPrint('🔄 Saindo da tela de edição...');
        context.router.maybePop();
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar perfil: $e');
      
      setState(() {
        _errorMessage = 'Erro ao atualizar perfil: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
  
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, informe um email válido para redefinir a senha';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(profileViewModelProvider.notifier)
          .sendPasswordResetLink(_emailController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Um link para redefinir sua senha foi enviado ao seu email'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar link de redefinição: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Data de nascimento',
      errorFormatText: 'Digite uma data válida no formato dd/mm/aaaa',
      errorInvalidText: 'Digite uma data válida',
    );
    
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    
    // ✅ Recarregar dados automaticamente quando o perfil for atualizado
    ref.listen<BaseState<Profile>>(profileViewModelProvider, (previous, next) {
      debugPrint('🔍 ProfileEditScreen - Listener acionado:');
      debugPrint('   - Previous: ${previous.runtimeType}');
      debugPrint('   - Next: ${next.runtimeType}');
      
      // ✅ Verificação mais específica para detectar mudanças
      if (next is BaseStateData<Profile>) {
        if (previous is BaseStateLoading<Profile> || 
            (previous is BaseStateData<Profile> && previous.data != next.data)) {
          debugPrint('✅ Detectada mudança no perfil, recarregando dados...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadUserData();
          });
        } else {
          debugPrint('⚠️ Dados do perfil não mudaram');
        }
      } else {
        debugPrint('⚠️ Estado não é BaseStateData');
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            fontFamily: 'Century',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.pastelYellow,
        foregroundColor: Colors.white,
      ),
      body: profileState is BaseStateLoading<Profile>
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileImage(context, profileState),
                      
                      const SizedBox(height: 30),
                      
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      
                      TextFormField(
                        key: const Key('name_field'),
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Digite seu nome completo',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => FormValidator.validateName(value),
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => FormValidator.validateEmail(value),
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone),
                          hintText: '(XX) XXXXX-XXXX',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) => validatePhoneNumber(value),
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      TextFormField(
                        controller: _instagramController,
                        decoration: const InputDecoration(
                          labelText: 'Instagram',
                          prefixIcon: Icon(Icons.alternate_email),
                          hintText: '@seuuser',
                        ),
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      InkWell(
                        onTap: _isLoading ? null : _selectBirthDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data de Nascimento',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _birthDate != null 
                                ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                                : 'Selecione sua data de nascimento',
                            style: TextStyle(
                              color: _birthDate != null 
                                  ? AppColors.darkGray
                                  : AppColors.darkGray.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gênero',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _genderOptions.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: _isLoading ? null : (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      TextButton.icon(
                        onPressed: _isLoading ? null : _resetPassword,
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Redefinir minha senha'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.purple,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Salvar Alterações',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildProfileImage(BuildContext context, BaseState<Profile> profileState) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.lightGray,
                width: 4,
              ),
              image: profileState is BaseStateData<Profile> && 
                      profileState.data.photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profileState.data.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileState is BaseStateData<Profile> && 
                    profileState.data.photoUrl == null
                ? Center(
                    child: Text(
                      _getInitials(profileState.data.name),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showImagePickerOptions(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
  
  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.orange),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.orange),
                title: const Text('Tirar uma foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.orangeDark),
                title: const Text('Remover foto'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      debugPrint('🔍 Iniciando seleção de imagem...');
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        debugPrint('✅ Imagem selecionada: ${pickedFile.path}');
        
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        debugPrint('📋 Tamanho do arquivo: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Arquivo muito grande. Máximo permitido: 5MB');
        }
        
        debugPrint('🔄 Fazendo upload da foto...');
        await ref.read(profileViewModelProvider.notifier).uploadProfilePhoto(pickedFile.path);
        
        debugPrint('✅ Upload concluído com sucesso!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil atualizada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('⚠️ Nenhuma imagem foi selecionada');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar foto: $e');
      
      setState(() {
        _errorMessage = 'Erro ao atualizar foto: ${e.toString()}';
      });
      
      if (mounted) {
        String errorMessage = 'Erro ao atualizar foto';
        
        if (e.toString().contains('não autenticado')) {
          errorMessage = 'Usuário não autenticado. Faça login novamente.';
        } else if (e.toString().contains('muito grande')) {
          errorMessage = 'Arquivo muito grande. Selecione uma imagem menor que 5MB.';
        } else if (e.toString().contains('não encontrado')) {
          errorMessage = 'Arquivo de imagem não encontrado.';
        } else if (e.toString().contains('bucket')) {
          errorMessage = 'Erro no servidor de armazenamento. Tente novamente.';
        } else {
          errorMessage = 'Erro inesperado: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: () => _showImagePickerOptions(context),
            ),
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
  
  void _removeProfilePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de remover foto ainda não está disponível'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericValue.length < 10 || numericValue.length > 11) {
      return 'Telefone inválido';
    }
    
    return null;
  }
} 