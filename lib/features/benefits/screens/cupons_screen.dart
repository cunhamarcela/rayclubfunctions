import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

/// Tela de Cupons de Desconto
/// 
/// Exibe uma lista de cupons de desconto disponíveis para parceiros
@RoutePage()
class CuponsScreen extends ConsumerWidget {
  const CuponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cupons = _getCupons();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333333)),
          onPressed: () => context.router.back(),
        ),
        title: const Text(
          'Cupons de Desconto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontFamily: 'CenturyGothic',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Lista de cupons
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cupons.length,
              itemBuilder: (context, index) {
                final cupom = cupons[index];
                return _buildCupomCard(context, cupom);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o card de cada cupom
  Widget _buildCupomCard(BuildContext context, Map<String, String> cupom) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone da marca
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF38638).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store,
                color: Color(0xFFF38638),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Informações do cupom
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cupom['marca'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      fontFamily: 'CenturyGothic',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Cupom: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          fontFamily: 'CenturyGothic',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF38638).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cupom['cupom'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF38638),
                            fontFamily: 'CenturyGothic',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botão de copiar
            IconButton(
              onPressed: () => _copiarCupom(context, cupom['cupom'] ?? ''),
              icon: const Icon(
                Icons.copy,
                color: Color(0xFFF38638),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Copia o código do cupom para a área de transferência
  void _copiarCupom(BuildContext context, String cupom) {
    Clipboard.setData(ClipboardData(text: cupom));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cupom "$cupom" copiado!'),
        backgroundColor: const Color(0xFFF38638),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Retorna a lista de cupons disponíveis
  List<Map<String, String>> _getCupons() {
    return [
      {'marca': 'Super Coffee | Sublyme | Koala', 'cupom': 'rayricardo'},
      {'marca': 'Haoma', 'cupom': 'Ray'},
      {'marca': 'Bold', 'cupom': 'Raiany'},
      {'marca': 'PureWave', 'cupom': 'Ray'},
      {'marca': 'Desinchá', 'cupom': 'Ray'},
      {'marca': 'Soon', 'cupom': 'Ray'},
      {'marca': 'Guday', 'cupom': 'Ray'},
      {'marca': 'Pura Vida', 'cupom': 'RayPv'},
      {'marca': 'Açaizim', 'cupom': 'RayClub'},
      {'marca': 'Hidratei | Bumbum Cream', 'cupom': 'rayricardo'},
      {'marca': 'Meu Ollie', 'cupom': 'Ray10'},
      {'marca': 'Magia do Mar', 'cupom': 'RAY'},
      {'marca': 'Hope Resort', 'cupom': 'RESORTRAIANY'},
      {'marca': 'Lacci Brand', 'cupom': 'Raiany'},
      {'marca': 'Dress4U', 'cupom': 'Ray'},
      {'marca': 'Sollar Swim', 'cupom': 'Raiany'},
      {'marca': 'Lilo Beachwear', 'cupom': 'Ray10'},
      {'marca': 'Flow Yoga', 'cupom': 'Ray'},
      {'marca': 'Velocity', 'cupom': 'Raynavelocity'},
      {'marca': 'ZiYou', 'cupom': 'ZiYouRay'},
      {'marca': 'Criare', 'cupom': 'Ray10'},
      {'marca': 'Theta Movement', 'cupom': 'Ray'},
    ];
  }
} 