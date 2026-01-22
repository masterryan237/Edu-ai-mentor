// lib/providers/ai_service_provider.dart
import 'package:eduai_mentor/implementations/ai_service_implementations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ai_service.dart';

class AiServiceProvider extends ChangeNotifier {
  late AiService _aiService;
  AiServiceImplementation? _currentImplementation;

  AiServiceProvider() {
    // Initialisation avec l'implémentation par défaut
    _currentImplementation = AiServiceImplementation();
    _aiService = AiService(implementation: _currentImplementation);
  }

  AiService get aiService => _aiService;

  // Méthode pour changer d'implémentation (si besoin de multiples implémentations)
  void switchImplementation(AiServiceImplementation newImplementation) {
    _currentImplementation = newImplementation;
    _aiService.setImplementation(newImplementation);
    notifyListeners();
  }

  // Provider statique
  static AiService of(BuildContext context) {
    return context.read<AiServiceProvider>().aiService;
  }
}
