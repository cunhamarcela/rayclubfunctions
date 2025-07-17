import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RayClubHeader extends StatelessWidget {
  final String username;
  final VoidCallback onMenuPressed;

  const RayClubHeader({
    Key? key,
    required this.username,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Deixar o status bar transparente
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, statusBarHeight + 10, 20, 20),
        height: statusBarHeight + 100,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão de menu
            GestureDetector(
              onTap: () {
                print('DEBUG: Menu button tapped');
                onMenuPressed();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(4),
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

            // Logo centralizado entre os ícones
            SizedBox(
              width: 120, // Tamanho reduzido
              height: 40,
              child: Image.asset(
                'assets/images/logos/app/header.png',
                fit: BoxFit.contain,
              ),
            ),

            // Botão de notificação
            GestureDetector(
              onTap: () {
                print('DEBUG: Notification button tapped');
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(8),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}