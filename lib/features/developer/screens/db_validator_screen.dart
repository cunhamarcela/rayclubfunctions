import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/database_verification_service.dart';

@RoutePage()
class DbValidatorScreen extends ConsumerWidget {
  const DbValidatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbService = ref.watch(databaseVerificationServiceProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Diagnóstico do Banco de Dados', style: AppTypography.headingMedium),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.router.maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: () {
              ref.invalidate(databaseVerificationServiceProvider);
            },
          ),
        ],
      ),
      body: FutureBuilder<DatabaseIntegrityReport>(
        future: dbService.checkDatabaseIntegrity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Verificando integridade do banco de dados...',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao verificar o banco de dados',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(databaseVerificationServiceProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Tentar novamente',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          
          final report = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(report),
                const SizedBox(height: 24),
                Text(
                  'Detalhes da Verificação',
                  style: AppTypography.headingSmall.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 16),
                _buildTablesList(report),
                if (report.missingTables.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildMissingTablesList(report),
                ],
                const SizedBox(height: 24),
                _buildTimestampCard(report),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatusCard(DatabaseIntegrityReport report) {
    return Card(
      elevation: 4,
      color: report.isValid ? Colors.green.shade800 : Colors.red.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              report.isValid ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 42,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.isValid ? 'Banco de Dados Íntegro' : 'Problemas Detectados',
                    style: AppTypography.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.isValid
                        ? 'Todas as tabelas requeridas foram encontradas'
                        : '${report.missingTables.length} tabela(s) ausente(s)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTablesList(DatabaseIntegrityReport report) {
    return Card(
      elevation: 2,
      color: AppColors.backgroundMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: report.verifiedTables.length,
        separatorBuilder: (context, index) => const Divider(
          color: AppColors.divider,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final entry = report.verifiedTables.entries.elementAt(index);
          return ListTile(
            title: Text(
              entry.key,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              entry.value ? Icons.check_circle : Icons.cancel,
              color: entry.value ? Colors.green : Colors.red,
              size: 24,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMissingTablesList(DatabaseIntegrityReport report) {
    return Card(
      elevation: 2,
      color: Colors.red.shade900.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Tabelas Ausentes',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...report.missingTables.map((table) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    table,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Text(
              'AÇÃO REQUERIDA: Execute os scripts de migração para criar as tabelas ausentes.',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.amber,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimestampCard(DatabaseIntegrityReport report) {
    return Card(
      elevation: 2,
      color: AppColors.backgroundMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.textLight),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última verificação',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
                  ),
                  Text(
                    '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year} - ${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 