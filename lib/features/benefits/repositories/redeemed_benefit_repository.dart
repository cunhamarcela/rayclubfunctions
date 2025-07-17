// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import '../../../core/utils/debug_data_inspector.dart';

/// Interface do repositório para benefícios resgatados
abstract class RedeemedBenefitRepository {
  /// Obtém todos os benefícios resgatados pelo usuário
  Future<List<RedeemedBenefit>> getUserRedeemedBenefits();
  
  /// Resgata um novo benefício
  Future<RedeemedBenefit> redeemBenefit(String benefitId);
  
  /// Marca um benefício como usado
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId);
}

/// Implementação mock do repositório para desenvolvimento
class MockRedeemedBenefitRepository implements RedeemedBenefitRepository {
  final List<RedeemedBenefit> _mockBenefits = [];
  
  MockRedeemedBenefitRepository() {
    _initMockData();
  }
  
  void _initMockData() {
    final now = DateTime.now();
    
    // Benefício ativo
    _mockBenefits.add(
      RedeemedBenefit(
        id: 'rb-1',
        userId: 'user123',
        benefitId: 'benefit-1',
        title: 'Desconto Smart Fit',
        description: 'Desconto mensal de 15%',
        code: 'SMARTFIT2025',
        status: BenefitStatus.active,
        expirationDate: now.add(const Duration(days: 30)),
        redeemedAt: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    );
    
    // Benefício expirado
    _mockBenefits.add(
      RedeemedBenefit(
        id: 'rb-2',
        userId: 'user123',
        benefitId: 'benefit-2',
        title: 'Protein Shop',
        description: '10% OFF na primeira compra',
        code: 'PROTEIN10',
        status: BenefitStatus.expired,
        expirationDate: now.subtract(const Duration(days: 5)),
        redeemedAt: now.subtract(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    );
  }

  @override
  Future<List<RedeemedBenefit>> getUserRedeemedBenefits() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Verificar e atualizar benefícios expirados
    _updateExpiredBenefits();
    
    return List<RedeemedBenefit>.from(_mockBenefits);
  }

  @override
  Future<RedeemedBenefit> redeemBenefit(String benefitId) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Verificar se já resgatou este benefício antes
    final existingBenefit = _mockBenefits.firstWhere(
      (b) => b.benefitId == benefitId && b.status == BenefitStatus.active,
      orElse: () => _createMockBenefit(benefitId),
    );
    
    if (existingBenefit.id != 'temp') {
      throw ValidationException(
        message: 'Benefício já resgatado e ainda ativo',
        code: 'benefit_already_redeemed',
      );
    }
    
    // Adicionar à lista de resgatados
    _mockBenefits.add(existingBenefit);
    
    return existingBenefit;
  }

  @override
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId) async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    final benefitIndex = _mockBenefits.indexWhere((b) => b.id == redeemedBenefitId);
    
    if (benefitIndex == -1) {
      throw NotFoundException(
        message: 'Benefício resgatado não encontrado',
        code: 'redeemed_benefit_not_found',
      );
    }
    
    final benefit = _mockBenefits[benefitIndex];
    
    if (benefit.status != BenefitStatus.active) {
      throw ValidationException(
        message: 'Apenas benefícios ativos podem ser marcados como usados',
        code: 'benefit_not_active',
      );
    }
    
    final now = DateTime.now();
    final updated = benefit.copyWith(
      status: BenefitStatus.used,
      usedAt: now,
      updatedAt: now,
    );
    
    // Atualizar na lista
    _mockBenefits[benefitIndex] = updated;
    
    return updated;
  }
  
  /// Atualiza o status de benefícios expirados
  void _updateExpiredBenefits() {
    final now = DateTime.now();
    
    for (int i = 0; i < _mockBenefits.length; i++) {
      final benefit = _mockBenefits[i];
      
      if (benefit.status == BenefitStatus.active && 
          benefit.expirationDate != null &&
          now.isAfter(benefit.expirationDate!)) {
        _mockBenefits[i] = benefit.copyWith(
          status: BenefitStatus.expired,
          updatedAt: now,
        );
      }
    }
  }
  
  /// Cria um benefício mockado com base no ID
  RedeemedBenefit _createMockBenefit(String benefitId) {
    final now = DateTime.now();
    
    return RedeemedBenefit(
      id: 'temp',
      userId: 'user123',
      benefitId: benefitId,
      title: benefitId == 'benefit-3' 
          ? 'Desconto Academia XYZ' 
          : 'Benefício Resgatado',
      description: benefitId == 'benefit-3'
          ? '20% de desconto na mensalidade'
          : 'Detalhes do benefício',
      code: 'CODE${now.millisecondsSinceEpoch.toString().substring(8)}',
      status: BenefitStatus.active,
      expirationDate: now.add(const Duration(days: 60)),
      redeemedAt: now,
      createdAt: now,
    );
  }
}

/// Implementação com Supabase
class SupabaseRedeemedBenefitRepository implements RedeemedBenefitRepository {
  final SupabaseClient _supabaseClient;

  SupabaseRedeemedBenefitRepository(this._supabaseClient);

  @override
  Future<List<RedeemedBenefit>> getUserRedeemedBenefits() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      final response = await _supabaseClient
          .from('redeemed_benefits')
          .select('*, benefit:benefit_id(*)')
          .eq('user_id', userId)
          .order('redeemed_at', ascending: false);
      
      // Inspecionar os dados retornados pelo Supabase
      DebugDataInspector.logResponse('RedeemedBenefits', response);
      
      return response.map<RedeemedBenefit>((data) => RedeemedBenefit.fromJson(data)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(
        message: 'Erro ao buscar benefícios resgatados',
        originalError: e,
        code: e.code,
      );
    } catch (e) {
      if (e is AppAuthException) rethrow;
      
      throw StorageException(
        message: 'Erro ao carregar benefícios resgatados: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<RedeemedBenefit> redeemBenefit(String benefitId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se já resgatou este benefício antes
      final existingResponse = await _supabaseClient
          .from('redeemed_benefits')
          .select()
          .eq('benefit_id', benefitId)
          .eq('user_id', userId)
          .eq('status', BenefitStatus.active.toString().split('.').last)
          .maybeSingle();
      
      if (existingResponse != null) {
        throw ValidationException(
          message: 'Benefício já resgatado e ainda ativo',
          code: 'benefit_already_redeemed',
        );
      }
      
      // Buscar informações do benefício
      final benefitResponse = await _supabaseClient
          .from('benefits')
          .select()
          .eq('id', benefitId)
          .single();
      
      // Criar código único
      final code = _generateUniqueCode(benefitResponse['code_prefix'] ?? 'CODE');
      
      final now = DateTime.now();
      
      // Calcular data de expiração com base na configuração do benefício
      final daysValid = benefitResponse['expiration_days'] ?? 30;
      final expirationDate = now.add(Duration(days: daysValid));
      
      // Inserir o benefício resgatado
      final redeemedBenefit = {
        'user_id': userId,
        'benefit_id': benefitId,
        'code': code,
        'status': BenefitStatus.active.toString().split('.').last,
        'expiration_date': expirationDate.toIso8601String(),
        'redeemed_at': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      };
      
      final response = await _supabaseClient
          .from('redeemed_benefits')
          .insert(redeemedBenefit)
          .select('*, benefits!inner(title, description, logo_url)')
          .single();
      
      return _mapResponseToBenefit(response);
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao resgatar benefício: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<RedeemedBenefit> markBenefitAsUsed(String redeemedBenefitId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      
      if (userId == null) {
        throw AppAuthException(
          message: 'Usuário não autenticado',
          code: 'not_authenticated',
        );
      }
      
      // Verificar se o benefício existe e está ativo
      final benefitResponse = await _supabaseClient
          .from('redeemed_benefits')
          .select('*, benefits!inner(title, description, logo_url)')
          .eq('id', redeemedBenefitId)
          .eq('user_id', userId)
          .single();
      
      final benefit = _mapResponseToBenefit(benefitResponse);
      
      if (benefit.status != BenefitStatus.active) {
        throw ValidationException(
          message: 'Apenas benefícios ativos podem ser marcados como usados',
          code: 'benefit_not_active',
        );
      }
      
      final now = DateTime.now();
      
      // Atualizar o status
      final response = await _supabaseClient
          .from('redeemed_benefits')
          .update({
            'status': BenefitStatus.used.toString().split('.').last,
            'used_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .eq('id', redeemedBenefitId)
          .eq('user_id', userId)
          .select('*, benefits!inner(title, description, logo_url)')
          .single();
      
      return _mapResponseToBenefit(response);
    } catch (e) {
      if (e is AppAuthException || e is ValidationException) rethrow;
      
      throw StorageException(
        message: 'Erro ao marcar benefício como usado: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  /// Atualiza automaticamente o status de benefícios expirados
  Future<void> _updateExpiredBenefits(String userId) async {
    final now = DateTime.now().toIso8601String();
    
    // Atualizar benefícios expirados
    await _supabaseClient
        .from('redeemed_benefits')
        .update({
          'status': BenefitStatus.expired.toString().split('.').last,
          'updated_at': now,
        })
        .eq('user_id', userId)
        .eq('status', BenefitStatus.active.toString().split('.').last)
        .lt('expiration_date', now);
  }
  
  /// Gera um código único para o benefício
  String _generateUniqueCode(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final random = (1000 + (DateTime.now().microsecond % 9000)).toString();
    return '$prefix$timestamp$random';
  }
  
  /// Mapeia a resposta da API para o modelo RedeemedBenefit
  RedeemedBenefit _mapResponseToBenefit(Map<String, dynamic> json) {
    final benefitData = json['benefits'] as Map<String, dynamic>;
    
    return RedeemedBenefit(
      id: json['id'],
      userId: json['user_id'],
      benefitId: json['benefit_id'],
      title: benefitData['title'],
      description: benefitData['description'],
      logoUrl: benefitData['logo_url'],
      code: json['code'],
      status: BenefitStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => BenefitStatus.active,
      ),
      expirationDate: DateTime.parse(json['expiration_date']),
      redeemedAt: DateTime.parse(json['redeemed_at']),
      usedAt: json['used_at'] != null 
          ? DateTime.parse(json['used_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}

/// Provider para o repositório de benefícios resgatados
final redeemedBenefitRepositoryProvider = Provider<RedeemedBenefitRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseRedeemedBenefitRepository(supabase);
}); 