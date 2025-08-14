// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../widgets/benefits_pdf_viewer.dart';

/// The Benefits Screen - Visualizador exclusivo de PDF para usuários EXPERT
/// 
/// 📌 Feature: Visualização exclusiva do PDF de benefícios
/// 🗓️ Data: 2025-01-21 às 23:45
/// 🧠 Autor: IA
/// 📄 Contexto: Transformação da tela em visualizador de PDF exclusivo para EXPERT
/// 
/// Funcionalidades:
/// - ✅ Verifica automaticamente se usuário é EXPERT
/// - ✅ Exibe PDF de benefícios com visualização fluida via WebView + Google Docs Viewer
/// - ✅ Mostra tela de evolução motivacional para usuários não-EXPERT
/// - ✅ Acesso direto ao arquivo beneficios.pdf no bucket do Supabase
/// - ✅ Linguagem acolhedora e otimista conforme padrões do projeto
@RoutePage()
class BenefitsScreen extends ConsumerWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retorna diretamente o visualizador especializado
    // Toda a lógica de verificação EXPERT e exibição está no BenefitsPdfViewer
    return const BenefitsPdfViewer();
  }
} 
