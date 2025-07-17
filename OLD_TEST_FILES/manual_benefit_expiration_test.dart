// Package imports:
import 'package:flutter_test/flutter_test.dart';

/// Simulação da enumeração de status de resgate
enum SimulatedRedemptionStatus {
  active,
  used,
  expired,
  cancelled
}

/// Simulação da classe de benefício resgatado para testar o fluxo de expiração
class SimulatedRedeemedBenefit {
  final String id;
  final String benefitId;
  final String userId;
  final DateTime redeemedAt;
  final DateTime? expiresAt;
  final String redemptionCode;
  final SimulatedRedemptionStatus status;
  final Map<String, dynamic> benefitSnapshot;
  
  const SimulatedRedeemedBenefit({
    required this.id,
    required this.benefitId,
    required this.userId,
    required this.redeemedAt,
    this.expiresAt,
    required this.redemptionCode,
    required this.status,
    required this.benefitSnapshot,
  });
  
  /// Método para simular a extensão de validade de um benefício
  SimulatedRedeemedBenefit extendValidity(DateTime newExpirationDate) {
    // Sempre reativa um benefício expirado quando a nova data é futura
    final newStatus = newExpirationDate.isAfter(DateTime.now())
      ? SimulatedRedemptionStatus.active
      : status;
      
    return SimulatedRedeemedBenefit(
      id: id,
      benefitId: benefitId,
      userId: userId,
      redeemedAt: redeemedAt,
      expiresAt: newExpirationDate,
      redemptionCode: redemptionCode,
      status: newStatus,
      benefitSnapshot: benefitSnapshot,
    );
  }
  
  /// Método para verificar e atualizar o status com base na data de expiração
  SimulatedRedeemedBenefit checkExpiration() {
    // Se já está expirado ou foi usado/cancelado, não alterar o status
    if (status == SimulatedRedemptionStatus.expired ||
        status == SimulatedRedemptionStatus.used ||
        status == SimulatedRedemptionStatus.cancelled) {
      return this;
    }
    
    // Verificar se o benefício expirou
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) {
      return SimulatedRedeemedBenefit(
        id: id,
        benefitId: benefitId,
        userId: userId,
        redeemedAt: redeemedAt,
        expiresAt: expiresAt,
        redemptionCode: redemptionCode,
        status: SimulatedRedemptionStatus.expired,
        benefitSnapshot: benefitSnapshot,
      );
    }
    
    // Nenhuma alteração necessária
    return this;
  }
}

/// Teste manual para verificar o fluxo de expiração de benefícios
void main() {
  group('Fluxo de Expiração de Benefícios - Testes Manuais', () {
    test('Benefício ativo não deve expirar quando data futura', () {
      // Criar um benefício com data de expiração futura
      final benefit = SimulatedRedeemedBenefit(
        id: 'benefit-1',
        benefitId: 'original-1',
        userId: 'user-1',
        redeemedAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        redemptionCode: 'ABC123',
        status: SimulatedRedemptionStatus.active,
        benefitSnapshot: {'title': 'Test Benefit'},
      );
      
      // Verificar expiração
      final checkedBenefit = benefit.checkExpiration();
      
      // Assert
      expect(checkedBenefit.status, SimulatedRedemptionStatus.active);
    });
    
    test('Benefício ativo deve expirar quando data passada', () {
      // Criar um benefício com data de expiração no passado
      final benefit = SimulatedRedeemedBenefit(
        id: 'benefit-2',
        benefitId: 'original-2',
        userId: 'user-1',
        redeemedAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        redemptionCode: 'DEF456',
        status: SimulatedRedemptionStatus.active,
        benefitSnapshot: {'title': 'Expired Benefit'},
      );
      
      // Verificar expiração
      final checkedBenefit = benefit.checkExpiration();
      
      // Assert
      expect(checkedBenefit.status, SimulatedRedemptionStatus.expired);
    });
    
    test('Benefício expirado deve ser reativado ao estender validade', () {
      // Criar um benefício expirado
      final expiredBenefit = SimulatedRedeemedBenefit(
        id: 'benefit-3',
        benefitId: 'original-3',
        userId: 'user-2',
        redeemedAt: DateTime.now().subtract(const Duration(days: 15)),
        expiresAt: DateTime.now().subtract(const Duration(days: 5)),
        redemptionCode: 'GHI789',
        status: SimulatedRedemptionStatus.expired,
        benefitSnapshot: {'title': 'Reactivated Benefit'},
      );
      
      // Simular ação de administrador estendendo a validade
      final newExpirationDate = DateTime.now().add(const Duration(days: 15));
      final extendedBenefit = expiredBenefit.extendValidity(newExpirationDate);
      
      // Assert
      expect(expiredBenefit.status, SimulatedRedemptionStatus.expired);
      expect(extendedBenefit.status, SimulatedRedemptionStatus.active);
      expect(extendedBenefit.expiresAt, newExpirationDate);
    });
    
    test('Benefícios usados ou cancelados não devem mudar de status ao verificar expiração', () {
      // Criar benefício usado
      final usedBenefit = SimulatedRedeemedBenefit(
        id: 'benefit-4',
        benefitId: 'original-4',
        userId: 'user-1',
        redeemedAt: DateTime.now().subtract(const Duration(days: 3)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)), // Já passada
        redemptionCode: 'JKL012',
        status: SimulatedRedemptionStatus.used,
        benefitSnapshot: {'title': 'Used Benefit'},
      );
      
      // Criar benefício cancelado
      final cancelledBenefit = SimulatedRedeemedBenefit(
        id: 'benefit-5',
        benefitId: 'original-5',
        userId: 'user-1',
        redeemedAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)), // Já passada
        redemptionCode: 'MNO345',
        status: SimulatedRedemptionStatus.cancelled,
        benefitSnapshot: {'title': 'Cancelled Benefit'},
      );
      
      // Verificar expiração
      final checkedUsedBenefit = usedBenefit.checkExpiration();
      final checkedCancelledBenefit = cancelledBenefit.checkExpiration();
      
      // Assert - status não deve mudar
      expect(checkedUsedBenefit.status, SimulatedRedemptionStatus.used);
      expect(checkedCancelledBenefit.status, SimulatedRedemptionStatus.cancelled);
    });
    
    test('Verificação em lote de benefícios expirados', () {
      // Criar uma lista de benefícios com datas variadas
      final benefits = [
        // Benefício ativo com data futura
        SimulatedRedeemedBenefit(
          id: 'benefit-6',
          benefitId: 'original-6',
          userId: 'user-1',
          redeemedAt: DateTime.now().subtract(const Duration(days: 1)),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
          redemptionCode: 'PQR678',
          status: SimulatedRedemptionStatus.active,
          benefitSnapshot: {'title': 'Active Benefit'},
        ),
        // Benefício ativo com data passada (deve expirar)
        SimulatedRedeemedBenefit(
          id: 'benefit-7',
          benefitId: 'original-7',
          userId: 'user-2',
          redeemedAt: DateTime.now().subtract(const Duration(days: 10)),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          redemptionCode: 'STU901',
          status: SimulatedRedemptionStatus.active,
          benefitSnapshot: {'title': 'Should Expire Benefit'},
        ),
        // Benefício já usado (não deve mudar)
        SimulatedRedeemedBenefit(
          id: 'benefit-8',
          benefitId: 'original-8',
          userId: 'user-3',
          redeemedAt: DateTime.now().subtract(const Duration(days: 5)),
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          redemptionCode: 'VWX234',
          status: SimulatedRedemptionStatus.used,
          benefitSnapshot: {'title': 'Used Benefit'},
        ),
      ];
      
      // Verificar expiração em todos os benefícios
      final updatedBenefits = benefits.map((benefit) => benefit.checkExpiration()).toList();
      
      // Assert
      expect(updatedBenefits[0].status, SimulatedRedemptionStatus.active); // Permanece ativo
      expect(updatedBenefits[1].status, SimulatedRedemptionStatus.expired); // Se torna expirado
      expect(updatedBenefits[2].status, SimulatedRedemptionStatus.used); // Permanece usado
      
      // Contar quantos estão expirados
      final expiredCount = updatedBenefits.where(
        (b) => b.status == SimulatedRedemptionStatus.expired
      ).length;
      
      expect(expiredCount, 1);
    });
  });
} 
