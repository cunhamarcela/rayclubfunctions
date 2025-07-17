// Flutter imports:
import 'package:flutter/material.dart';

/// Utilitários para DatePickers padronizados com localização brasileira
class DatePickerUtils {
  DatePickerUtils._();

  /// Mostra um DatePicker configurado para o padrão brasileiro
  /// 
  /// Parâmetros:
  /// - [context]: Contexto do BuildContext
  /// - [initialDate]: Data inicial (padrão: hoje)
  /// - [firstDate]: Data mínima (padrão: 1900)
  /// - [lastDate]: Data máxima (padrão: hoje)
  /// - [helpText]: Texto de ajuda personalizado
  /// - [fieldLabelText]: Label do campo personalizado
  /// - [theme]: Tema personalizado para o DatePicker
  static Future<DateTime?> showBrazilianDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? fieldLabelText,
    ThemeData? theme,
  }) async {
    final now = DateTime.now();
    
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? now,
      locale: const Locale('pt', 'BR'),
      helpText: helpText ?? 'Selecione uma data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: fieldLabelText ?? 'Data',
      errorFormatText: 'Digite uma data válida no formato dd/mm/aaaa',
      errorInvalidText: 'Digite uma data válida',
      builder: theme != null ? (context, child) {
        return Theme(
          data: theme,
          child: child!,
        );
      } : null,
    );
  }

  /// Mostra um DatePicker para data de nascimento
  static Future<DateTime?> showBirthDatePicker({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    return await showBrazilianDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecione sua data de nascimento',
      fieldLabelText: 'Data de nascimento',
    );
  }

  /// Mostra um DatePicker para datas de refeições
  static Future<DateTime?> showMealDatePicker({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    return await showBrazilianDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Selecione a data da refeição',
      fieldLabelText: 'Data da refeição',
    );
  }

  /// Mostra um DatePicker para datas de treinos
  static Future<DateTime?> showWorkoutDatePicker({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    return await showBrazilianDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: 'Selecione a data do treino',
      fieldLabelText: 'Data do treino',
    );
  }

  /// Mostra um DatePicker para prazos de metas
  static Future<DateTime?> showGoalDeadlinePicker({
    required BuildContext context,
    DateTime? initialDate,
    ThemeData? theme,
  }) async {
    return await showBrazilianDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione o prazo da meta',
      fieldLabelText: 'Prazo da meta',
      theme: theme,
    );
  }

  /// Mostra um DatePicker para datas de desafios
  static Future<DateTime?> showChallengeDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required bool isStartDate,
  }) async {
    return await showBrazilianDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      helpText: isStartDate ? 'Selecione a data de início' : 'Selecione a data de fim',
      fieldLabelText: isStartDate ? 'Data de início' : 'Data de fim',
    );
  }

  /// Mostra um DatePicker para exercícios recentes
  static Future<DateTime?> showExerciseDatePicker({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    return await showBrazilianDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 14)),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data do exercício',
      fieldLabelText: 'Data do exercício',
    );
  }

  /// Mostra um TimePicker configurado para o padrão brasileiro
  static Future<TimeOfDay?> showBrazilianTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    String? helpText,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: helpText ?? 'Selecione uma hora',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      errorInvalidText: 'Digite uma hora válida',
    );
  }
} 