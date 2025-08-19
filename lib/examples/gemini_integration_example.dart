import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

/// Exemple d'utilisation de l'intégration Firebase AI Logic avec Gemini
/// Ce fichier montre comment utiliser le service Gemini dans l'application
class GeminiIntegrationExample extends StatefulWidget {
  const GeminiIntegrationExample({super.key});

  @override
  State<GeminiIntegrationExample> createState() => _GeminiIntegrationExampleState();
}

class _GeminiIntegrationExampleState extends State<GeminiIntegrationExample> {
  List<String> _conseils = [];
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Intégration Gemini'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Test des conseils IA
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧠 Test des Conseils IA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Testez la fonction centrale getConseilsIA() avec des données d\'exemple',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testConseilsIA,
                      icon: _isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.psychology),
                      label: Text(_isLoading ? 'Génération...' : 'Tester les Conseils IA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Affichage des conseils
            if (_conseils.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 Conseils Générés',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._conseils.asMap().entries.map((entry) {
                        final index = entry.key;
                        final conseil = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    conseil,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],

            // Section 3: Affichage des erreurs
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '❌ Erreur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Section 4: Informations sur l'intégration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ℹ️ Informations sur l\'Intégration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Service', 'GeminiService'),
                    _buildInfoRow('Modèle', 'gemini-1.5-flash'),
                    _buildInfoRow('Configuration', 'Firebase AI Logic'),
                    _buildInfoRow('Sécurité', 'Proxy Firebase (pas d\'exposition de clé API)'),
                    _buildInfoRow('Langue', 'Français (contexte ivoirien)'),
                    _buildInfoRow('Fallback', 'Conseils locaux en cas d\'erreur'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Test de la fonction centrale getConseilsIA
  Future<void> _testConseilsIA() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _conseils = [];
    });

    try {
      final geminiService = context.read<GeminiService>();
      
      // Données d'exemple pour le test
      const budget = 100000.0; // 100k FCFA
      const depenses = 65000.0; // 65k FCFA dépensés
      const nouvelleDepense = 15000.0; // 15k FCFA nouvelle dépense

      // Appel de la fonction centrale
      final conseils = await geminiService.getConseilsIA(budget, depenses, nouvelleDepense);

      if (mounted) {
        setState(() {
          _conseils = conseils;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du test: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}

/// Exemple d'utilisation dans un widget existant
class ExampleUsageInWidget extends StatelessWidget {
  const ExampleUsageInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthService, TransactionService, GeminiService>(
      builder: (context, authService, transactionService, geminiService, child) {
        // Vérifier si les conseils IA sont activés
        if (authService.currentUser?.aiAdviceEnabled != true) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Les conseils IA sont désactivés dans les paramètres'),
            ),
          );
        }

        return FutureBuilder<List<String>>(
          future: geminiService.getFinancialTips(
            currentBalance: transactionService.getCurrentMonthBalance(authService.currentUser?.monthlyBudget ?? 0),
            monthlyBudget: authService.currentUser?.monthlyBudget ?? 0,
            transactions: transactionService.currentMonthTransactions,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Génération des conseils...'),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Erreur: ${snapshot.error}'),
                ),
              );
            }

            final conseils = snapshot.data ?? [];
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Conseils Financiers IA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...conseils.map((conseil) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('• $conseil'),
                    )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
