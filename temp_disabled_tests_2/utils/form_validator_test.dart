// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/utils/form_validator.dart';

void main() {
  group('FormValidator:', () {
    group('validateEmail:', () {
      test('deve retornar null para e-mails válidos', () {
        expect(FormValidator.validateEmail('usuario@example.com'), isNull);
        expect(FormValidator.validateEmail('teste.123@gmail.com'), isNull);
        expect(FormValidator.validateEmail('nome-usuario@dominio.com.br'), isNull);
      });
      
      test('deve retornar mensagem de erro para e-mails inválidos', () {
        expect(FormValidator.validateEmail(''), isNotNull);
        expect(FormValidator.validateEmail(null), isNotNull);
        expect(FormValidator.validateEmail('usuario@'), isNotNull);
        expect(FormValidator.validateEmail('usuario@dominio'), isNotNull);
        expect(FormValidator.validateEmail('usuario.dominio.com'), isNotNull);
      });
    });
    
    group('validatePassword:', () {
      test('deve retornar null para senhas válidas', () {
        expect(FormValidator.validatePassword('Senha123'), isNull);
        expect(FormValidator.validatePassword('senha123'), isNull);
      });
      
      test('deve aceitar senha menos rígida no modo login', () {
        expect(FormValidator.validatePassword('senha', isLogin: true), isNull);
      });
      
      test('deve retornar mensagem de erro para senhas inválidas', () {
        expect(FormValidator.validatePassword(''), isNotNull);
        expect(FormValidator.validatePassword(null), isNotNull);
        expect(FormValidator.validatePassword('123'), isNotNull);
        expect(FormValidator.validatePassword('senha'), isNotNull);
      });
    });
    
    group('validateName:', () {
      test('deve retornar null para nomes válidos', () {
        expect(FormValidator.validateName('João Silva'), isNull);
        expect(FormValidator.validateName('Maria Souza'), isNull);
      });
      
      test('deve retornar mensagem de erro para nomes inválidos', () {
        expect(FormValidator.validateName(''), isNotNull);
        expect(FormValidator.validateName(null), isNotNull);
        expect(FormValidator.validateName('João123'), isNotNull);
        expect(FormValidator.validateName('João@Silva'), isNotNull);
      });
    });
    
    group('validatePhone:', () {
      test('deve retornar null para telefones válidos', () {
        expect(FormValidator.validatePhone('(11) 98765-4321'), isNull);
        expect(FormValidator.validatePhone('11987654321'), isNull);
      });
      
      test('deve retornar mensagem de erro para telefones inválidos', () {
        expect(FormValidator.validatePhone(''), isNotNull);
        expect(FormValidator.validatePhone(null), isNotNull);
        expect(FormValidator.validatePhone('1234567'), isNotNull);
        expect(FormValidator.validatePhone('(11) 1234-567'), isNotNull);
      });
    });
    
    group('validateNumeric:', () {
      test('deve retornar null para valores numéricos válidos', () {
        expect(FormValidator.validateNumeric('123'), isNull);
        expect(FormValidator.validateNumeric('0'), isNull);
      });
      
      test('deve retornar mensagem de erro para valores não numéricos', () {
        expect(FormValidator.validateNumeric(''), isNotNull);
        expect(FormValidator.validateNumeric(null), isNotNull);
        expect(FormValidator.validateNumeric('abc'), isNotNull);
        expect(FormValidator.validateNumeric('1a2b3c'), isNotNull);
      });
    });
    
    group('validateWeight:', () {
      test('deve retornar null para pesos válidos', () {
        expect(FormValidator.validateWeight('70'), isNull);
        expect(FormValidator.validateWeight('70.5'), isNull);
        expect(FormValidator.validateWeight('70,5'), isNull);
      });
      
      test('deve retornar mensagem de erro para pesos inválidos', () {
        expect(FormValidator.validateWeight(''), isNotNull);
        expect(FormValidator.validateWeight(null), isNotNull);
        expect(FormValidator.validateWeight('abc'), isNotNull);
        expect(FormValidator.validateWeight('10'), isNotNull); // Abaixo do mínimo (20kg)
        expect(FormValidator.validateWeight('350'), isNotNull); // Acima do máximo (300kg)
      });
    });
    
    group('validateHeight:', () {
      test('deve retornar null para alturas válidas', () {
        expect(FormValidator.validateHeight('1.75'), isNull);
        expect(FormValidator.validateHeight('1,75'), isNull);
        expect(FormValidator.validateHeight('175'), isNull); // em cm
      });
      
      test('deve retornar mensagem de erro para alturas inválidas', () {
        expect(FormValidator.validateHeight(''), isNotNull);
        expect(FormValidator.validateHeight(null), isNotNull);
        expect(FormValidator.validateHeight('abc'), isNotNull);
        expect(FormValidator.validateHeight('0.5'), isNotNull); // Abaixo do mínimo (1m)
        expect(FormValidator.validateHeight('3'), isNotNull); // Acima do máximo (2.5m)
      });
    });
    
    group('validateConfirmation:', () {
      test('deve retornar null quando os valores correspondem', () {
        expect(FormValidator.validateConfirmation('senha123', 'senha123'), isNull);
      });
      
      test('deve retornar mensagem de erro quando os valores não correspondem', () {
        expect(FormValidator.validateConfirmation('senha123', 'senha456'), isNotNull);
        expect(FormValidator.validateConfirmation('', null), isNotNull);
        expect(FormValidator.validateConfirmation(null, ''), isNotNull);
      });
    });
    
    group('validateRequired:', () {
      test('deve retornar null para valores não vazios', () {
        expect(FormValidator.validateRequired('valor'), isNull);
        expect(FormValidator.validateRequired('0'), isNull);
      });
      
      test('deve retornar mensagem de erro para valores vazios', () {
        expect(FormValidator.validateRequired(''), isNotNull);
        expect(FormValidator.validateRequired(null), isNotNull);
        expect(FormValidator.validateRequired('  '), isNotNull);
      });
    });
    
    group('validateMinLength:', () {
      test('deve retornar null para valores com tamanho mínimo', () {
        expect(FormValidator.validateMinLength('12345', 5), isNull);
        expect(FormValidator.validateMinLength('123456', 5), isNull);
      });
      
      test('deve retornar mensagem de erro para valores com tamanho inferior', () {
        expect(FormValidator.validateMinLength('1234', 5), isNotNull);
        expect(FormValidator.validateMinLength('', 5), isNotNull);
        expect(FormValidator.validateMinLength(null, 5), isNotNull);
      });
    });
    
    group('validateMaxLength:', () {
      test('deve retornar null para valores não maiores que o tamanho máximo', () {
        expect(FormValidator.validateMaxLength('12345', 5), isNull);
        expect(FormValidator.validateMaxLength('1234', 5), isNull);
        expect(FormValidator.validateMaxLength('', 5), isNull);
        expect(FormValidator.validateMaxLength(null, 5), isNull);
      });
      
      test('deve retornar mensagem de erro para valores maiores que o tamanho máximo', () {
        expect(FormValidator.validateMaxLength('123456', 5), isNotNull);
      });
    });
    
    group('sanitizeMap:', () {
      test('deve sanitizar valores string em um mapa', () {
        final map = {
          'nome': 'João <script>alert("xss")</script>',
          'idade': 30,
          'email': 'joao@exemplo.com onclick="alert(1)"',
        };
        
        final sanitized = FormValidator.sanitizeMap(map);
        
        expect(sanitized['nome'], 'João alert("xss")');
        expect(sanitized['idade'], 30);
        expect(sanitized['email'], 'joao@exemplo.com ');
      });
    });
  });
} 
