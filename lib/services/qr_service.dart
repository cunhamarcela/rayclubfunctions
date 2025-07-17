// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import '../core/services/connectivity_service.dart';
import 'secure_storage_service.dart';
import '../features/benefits/models/benefit.dart';
import '../features/benefits/models/redeemed_benefit_model.dart';
import '../core/errors/app_exception.dart' as app_errors;

/// Resultado da geração de um QR code
class QRCodeResult {
  final String data;
  final DateTime expiresAt;
  
  QRCodeResult({
    required this.data,
    required this.expiresAt,
  });
}

/// Serviço para geração e gerenciamento de QR Codes
class QRService {
  final SecureStorageService _secureStorage;
  final ConnectivityService _connectivityService;
  
  /// Chave usada para assinar dados do QR code
  static const String _qrSignatureKey = 'ray_club_qr_signature';
  
  QRService({
    required SecureStorageService secureStorage,
    required ConnectivityService connectivityService,
  }) : _secureStorage = secureStorage,
       _connectivityService = connectivityService;
  
  /// Gera dados formatados para um QR Code
  /// Este formato é usado para gerar QR Codes de benefícios resgatados
  Future<String> generateQRCodeData({
    required String userId,
    required String benefitId,
    required String redemptionCode,
    required int timestamp,
  }) async {
    // Criar payload com dados
    final Map<String, dynamic> payload = {
      'userId': userId,
      'benefitId': benefitId,
      'redemptionCode': redemptionCode,
      'timestamp': timestamp,
      'expires': timestamp + 600000, // 10 minutos em milissegundos
    };
    
    // Assinar o payload para segurança
    final signature = await _generateSignature(payload);
    
    final fullPayload = {
      ...payload,
      'signature': signature,
    };
    
    // Retornar JSON codificado em base64 para uso no QR code
    return base64Encode(utf8.encode(jsonEncode(fullPayload)));
  }
  
  /// Gera um QR Code para um benefício resgatado
  Future<String> generateRedeemedBenefitQRCode(RedeemedBenefit redeemedBenefit) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Usando valores mock para userId e redemptionCode quando não disponíveis no modelo atual
    return generateQRCodeData(
      userId: 'user-id', // Como userId não existe mais no modelo, usamos um valor fixo
      benefitId: redeemedBenefit.benefitId,
      redemptionCode: redeemedBenefit.redemptionCode ?? 'code-not-available', // Usando valor padrão quando nulo
      timestamp: now,
    );
  }
  
  /// Gera dados QR para um benefício com expiração
  Future<QRCodeResult> generateQRDataForBenefit({
    required String benefitId, 
    required String code
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 10));
    
    final qrData = await generateQRCodeData(
      userId: 'user-id',
      benefitId: benefitId,
      redemptionCode: code,
      timestamp: now.millisecondsSinceEpoch,
    );
    
    return QRCodeResult(
      data: qrData,
      expiresAt: expiresAt,
    );
  }
  
  /// Verifica a validade dos dados de um QR code (usado pelo lado do parceiro)
  Future<bool> verifyQRCodeData(String qrCodeData) async {
    try {
      // Decodificar dados
      final decoded = jsonDecode(utf8.decode(base64Decode(qrCodeData)));
      
      // Extrair assinatura e verificar
      final signature = decoded['signature'];
      final payload = Map<String, dynamic>.from(decoded)..remove('signature');
      
      // Verificar expiração
      final expiresAt = decoded['expires'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now > expiresAt) {
        return false; // QR code expirado
      }
      
      // Gerar nova assinatura e comparar
      final calculatedSignature = await _generateSignature(payload);
      
      return signature == calculatedSignature;
    } catch (e) {
      return false;
    }
  }
  
  /// Gera uma assinatura para os dados do QR code
  Future<String> _generateSignature(Map<String, dynamic> payload) async {
    // Em uma implementação real, usaríamos criptografia forte
    // Aqui estamos apenas simulando com um hash simples
    final payloadString = jsonEncode(payload);
    final bytes = utf8.encode(payloadString);
    
    // Simplificação para demonstração - em produção usaríamos HMAC
    var signature = 0;
    for (var byte in bytes) {
      signature = (signature + byte) % 0xFFFFFFFF;
    }
    
    return signature.toRadixString(16).padLeft(8, '0');
  }
} 