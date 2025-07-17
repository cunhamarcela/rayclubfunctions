// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Widget que exibe um banner informando o status de conectividade
class ConnectivityBanner extends StatelessWidget {
  final List<ConnectivityResult>? connectivityResults;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  
  const ConnectivityBanner({
    Key? key,
    required this.connectivityResults,
    this.onRetry,
    this.onClose,
  }) : super(key: key);
  
  bool get _isOnline {
    if (connectivityResults == null || connectivityResults!.isEmpty) {
      return false;
    }
    return connectivityResults!.any((result) => 
        result == ConnectivityResult.wifi || 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }
  
  @override
  Widget build(BuildContext context) {
    // Não exibir nada se estiver online
    if (_isOnline) {
      return const SizedBox.shrink();
    }
    
    // Exibir banner para modo offline
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange[700],
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você está offline. Algumas funcionalidades podem estar limitadas.',
              style: AppTextStyles.smallText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(40, 24),
                foregroundColor: Colors.white,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Tentar novamente'),
            ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

/// Widget que monitora o status de conectividade e exibe um banner quando offline
class ConnectivityBannerWrapper extends StatefulWidget {
  final Widget child;
  final bool showBanner;
  final VoidCallback? onConnectivityChanged;
  
  const ConnectivityBannerWrapper({
    Key? key,
    required this.child,
    this.showBanner = true,
    this.onConnectivityChanged,
  }) : super(key: key);
  
  @override
  State<ConnectivityBannerWrapper> createState() => _ConnectivityBannerWrapperState();
}

class _ConnectivityBannerWrapperState extends State<ConnectivityBannerWrapper> {
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult>? _connectivityResults;
  bool _bannerDismissed = false;
  bool _isConnected = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.any((result) => 
            result != ConnectivityResult.none);
        setState(() {
          _connectivityResults = results;
          _isConnected = isConnected;
          // Reset banner dismissed state when connectivity changes
          if (isConnected) {
            _bannerDismissed = false;
          }
        });
        widget.onConnectivityChanged?.call();
      },
    );
  }
  
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  
  void _checkConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    // Verifica se há pelo menos uma conexão que não seja 'none'
    final isConnected = connectivityResults.any((result) => 
        result != ConnectivityResult.none);
    setState(() {
      _connectivityResults = connectivityResults;
      _isConnected = isConnected;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.showBanner || _bannerDismissed) {
      return widget.child;
    }
    
    return Column(
      children: [
        ConnectivityBanner(
          connectivityResults: _connectivityResults,
          onRetry: _checkConnectivity,
          onClose: _dismissBanner,
        ),
        Expanded(child: widget.child),
      ],
    );
  }
  
  void _dismissBanner() {
    if (mounted) {
      setState(() {
        _bannerDismissed = true;
      });
    }
  }
} 
