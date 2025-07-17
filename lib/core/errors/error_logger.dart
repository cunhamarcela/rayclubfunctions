import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../errors/app_exception.dart';

/// Classe responsável por registrar erros automaticamente em um arquivo Markdown
class ErrorLogger {
  static const String _logFileName = 'erro_log.md';
  static const String _logRelativePath = 'docs';
  static bool _initialized = false;
  static late String _logFilePath;
  static String _appName = 'Ray Club App';
  static String _appVersion = 'Unknown';
  
  /// Inicializa o serviço de log
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Obter informações do app
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _appVersion = packageInfo.version;
      
      // Determinar o caminho do arquivo de log
      if (kReleaseMode) {
        // Em release mode, salvar no diretório de documentos
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        _logFilePath = path.join(appDocDir.path, _logFileName);
      } else {
        // Em debug mode, salvar no diretório do projeto
        // Detectar o diretório da aplicação
        Directory currentDir = Directory.current;
        _logFilePath = path.join(currentDir.path, _logRelativePath, _logFileName);
        
        // Garantir que o diretório docs existe
        final docsDir = Directory(path.join(currentDir.path, _logRelativePath));
        if (!await docsDir.exists()) {
          await docsDir.create(recursive: true);
        }
      }
      
      _initialized = true;
      debugPrint('✅ ErrorLogger inicializado: $_logFilePath');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar ErrorLogger: $e');
    }
  }
  
  /// Registra um erro no arquivo de log
  static Future<void> logError(
    Object error, {
    required String location,
    StackTrace? stackTrace,
    String? recommendation,
  }) async {
    if (!_initialized) await initialize();
    
    try {
      final timestamp = DateTime.now().toIso8601String();
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
      final formattedDate = dateFormat.format(DateTime.now());
      
      // Extrair informações do erro
      final AppException appException = error is AppException 
          ? error 
          : AppException(
              message: error.toString(),
              originalError: error,
              stackTrace: stackTrace,
            );
            
      // Determinar a causa raiz
      final String rootCause = _determineRootCause(appException);
      
      // Gerar uma sugestão de correção se não for fornecida
      final String fixSuggestion = recommendation ?? _generateFixSuggestion(appException);
      
      // Criar conteúdo do log em Markdown
      final StringBuffer logEntry = StringBuffer();
      logEntry.writeln('## 🐞 Erro Detectado ($formattedDate)');
      logEntry.writeln('- **App Versão:** $_appVersion');
      logEntry.writeln('- **Localização:** $location');
      logEntry.writeln('- **Tipo de Erro:** ${_getErrorType(appException)}');
      logEntry.writeln('- **Mensagem Completa do Erro:** ${appException.message}');
      logEntry.writeln('- **Código de Erro:** ${appException.code ?? "N/A"}');
      logEntry.writeln('- **Causa Raiz:** $rootCause');
      
      if (appException.stackTrace != null) {
        final String stackTracePreview = _formatStackTrace(appException.stackTrace.toString());
        logEntry.writeln('- **Stack Trace:** \n```\n$stackTracePreview\n```');
      }
      
      logEntry.writeln('- **Sugestão de Correção:** $fixSuggestion');
      logEntry.writeln('- **Status:** Não Resolvido ⚠️');
      logEntry.writeln('\n---\n');
      
      // Adicionar ao arquivo de log
      final File logFile = File(_logFilePath);
      
      if (await logFile.exists()) {
        // Adicionar ao início do arquivo existente
        final String existingContent = await logFile.readAsString();
        await logFile.writeAsString('${logEntry.toString()}$existingContent');
      } else {
        // Criar novo arquivo
        await logFile.writeAsString(
          '# Log de Erros - $_appName\n\n${logEntry.toString()}',
        );
      }
      
      debugPrint('✅ Erro registrado no log: $location');
    } catch (e) {
      debugPrint('❌ Falha ao registrar erro no log: $e');
    }
  }
  
  /// Determina o tipo de erro com base na exceção
  static String _getErrorType(AppException error) {
    if (error is NetworkException) return 'Erro de Rede';
    if (error is AuthException) return 'Erro de Autenticação';
    if (error is StorageException) return 'Erro de Armazenamento';
    if (error is ValidationException) return 'Erro de Validação';
    if (error is DatabaseException) return 'Erro de Banco de Dados';
    if (error is ResourceNotFoundException) return 'Recurso Não Encontrado';
    return 'Exceção da Aplicação';
  }
  
  /// Determina a causa raiz provável do erro
  static String _determineRootCause(AppException error) {
    final String errorMsg = error.message.toLowerCase();
    final String? originalErrorStr = error.originalError?.toString().toLowerCase();
    
    // Verificar padrões comuns
    if (errorMsg.contains('internet') || errorMsg.contains('rede') || 
        errorMsg.contains('conexão') || errorMsg.contains('timeout')) {
      return 'Problema de conectividade ou timeout na rede.';
    }
    
    if (errorMsg.contains('not found') || errorMsg.contains('não encontrado')) {
      return 'Recurso solicitado não existe ou foi movido.';
    }
    
    if (errorMsg.contains('permission') || errorMsg.contains('permissão') || 
        errorMsg.contains('acesso negado') || errorMsg.contains('access denied')) {
      return 'Permissões insuficientes para realizar a operação.';
    }
    
    if (errorMsg.contains('syntax') || errorMsg.contains('sintaxe') || errorMsg.contains('invalid')) {
      return 'Sintaxe inválida na consulta ou operação.';
    }
    
    if (errorMsg.contains('database') || errorMsg.contains('banco de dados')) {
      return 'Erro interno no banco de dados ou conflito de dados.';
    }
    
    if (errorMsg.contains('null') && (errorMsg.contains('not') || errorMsg.contains('não'))) {
      return 'Valor nulo em campo que requer valor não-nulo.';
    }
    
    if (originalErrorStr != null && originalErrorStr.contains('ambiguous')) {
      return 'Referência ambígua a uma coluna ou campo que existe em múltiplas tabelas/contextos.';
    }
    
    if (originalErrorStr != null && originalErrorStr.contains('recursion')) {
      return 'Recursão infinita detectada, possivelmente em uma query ou função SQL.';
    }
    
    // Causa genérica
    return 'Erro não categorizado. Verificar detalhes completos na mensagem e stack trace.';
  }
  
  /// Gera uma sugestão de correção com base no tipo de erro
  static String _generateFixSuggestion(AppException error) {
    if (error is NetworkException) {
      if (error.statusCode == 404) {
        return 'Verificar se o endpoint está correto e o recurso existe.';
      } else if (error.statusCode == 401 || error.statusCode == 403) {
        return 'Verificar credenciais de autenticação ou permissões de acesso.';
      } else if (error.statusCode == 500) {
        return 'Problema no servidor. Verificar logs do backend e tentar novamente mais tarde.';
      } else {
        return 'Verificar conexão com a internet e tentar novamente. Se persistir, validar os parâmetros da requisição.';
      }
    }
    
    if (error is AuthException) {
      return 'Verificar credenciais de usuário. Pode ser necessário fazer login novamente ou atualizar o token.';
    }
    
    if (error is ValidationException) {
      return 'Verificar os dados de entrada. Garantir que todos os campos obrigatórios estão preenchidos e com valores válidos.';
    }
    
    if (error is DatabaseException) {
      String errorStr = error.toString().toLowerCase();
      if (errorStr.contains('ambiguous')) {
        return 'Adicionar aliases às tabelas nas consultas SQL para evitar referências ambíguas a colunas.';
      } else if (errorStr.contains('foreign key')) {
        return 'Verificar integridade referencial. A operação pode estar tentando violar uma restrição de chave estrangeira.';
      } else if (errorStr.contains('unique')) {
        return 'Verificar unicidade. A operação pode estar tentando inserir um valor duplicado em um campo único.';
      } else {
        return 'Verificar a consulta SQL e o estado atual do banco de dados. Pode ser necessário corrigir o schema ou a lógica de acesso.';
      }
    }
    
    // Sugestão genérica
    return 'Revisar a lógica associada a esta operação. Verificar logs e mensagens de erro completas para mais detalhes.';
  }
  
  /// Formata o stack trace para exibição mais clara
  static String _formatStackTrace(String stackTrace) {
    final lines = stackTrace.split('\n');
    
    // Limitar a 10 linhas e filtrar linhas mais relevantes
    final relevantLines = lines
        .where((line) => 
          line.contains('/lib/') && 
          !line.contains('/flutter/') &&
          !line.contains('/dart-sdk/'))
        .take(10)
        .join('\n');
    
    return relevantLines.isEmpty ? lines.take(10).join('\n') : relevantLines;
  }
} 