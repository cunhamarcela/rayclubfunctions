import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar App Tracking Transparency
class AppTrackingService {
  static const String _trackingRequestedKey = 'tracking_permission_requested';
  
  /// Solicita permissão de tracking se ainda não foi solicitada
  static Future<void> requestTrackingPermissionIfNeeded() async {
    // Só executa em iOS
    if (!Platform.isIOS) {
      debugPrint('📱 AppTracking: Não é iOS, pulando solicitação');
      return;
    }
    
    try {
      // Verificar se já foi solicitado antes
      final prefs = await SharedPreferences.getInstance();
      final alreadyRequested = prefs.getBool(_trackingRequestedKey) ?? false;
      
      if (alreadyRequested) {
        debugPrint('📱 AppTracking: Permissão já foi solicitada anteriormente');
        return;
      }
      
      // Verificar o status atual
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('📱 AppTracking: Status atual = $status');
      
      // Só solicita se o status for notDetermined
      if (status == TrackingStatus.notDetermined) {
        debugPrint('📱 AppTracking: Solicitando permissão...');
        
        // Aguardar um pequeno delay para garantir que o app esteja totalmente carregado
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Solicitar permissão
        final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('📱 AppTracking: Nova permissão = $newStatus');
        
        // Marcar como solicitado
        await prefs.setBool(_trackingRequestedKey, true);
      } else {
        debugPrint('📱 AppTracking: Status já determinado, não solicitando novamente');
        // Marcar como solicitado mesmo se já estava determinado
        await prefs.setBool(_trackingRequestedKey, true);
      }
    } catch (e) {
      debugPrint('❌ AppTracking: Erro ao solicitar permissão: $e');
    }
  }
  
  /// Verifica se o tracking está autorizado
  static Future<bool> isTrackingAuthorized() async {
    if (!Platform.isIOS) return false;
    
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return status == TrackingStatus.authorized;
    } catch (e) {
      debugPrint('❌ AppTracking: Erro ao verificar status: $e');
      return false;
    }
  }
  
  /// Obtém o status atual do tracking
  static Future<TrackingStatus> getTrackingStatus() async {
    if (!Platform.isIOS) return TrackingStatus.notSupported;
    
    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      debugPrint('❌ AppTracking: Erro ao obter status: $e');
      return TrackingStatus.notSupported;
    }
  }
} 