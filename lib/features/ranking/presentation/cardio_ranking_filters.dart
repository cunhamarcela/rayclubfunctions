import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CardioWindow { all, d7, d30, d90 }

final cardioWindowProvider = StateProvider<CardioWindow>((_) => CardioWindow.all);

final cardioParticipationProvider = StateProvider<bool>((_) => false);


