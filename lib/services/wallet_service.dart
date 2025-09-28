import '../models/transaction.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class WalletService {
  // Obtenir les informations du portefeuille
  static Future<Map<String, dynamic>> getWalletInfo() async {
    try {
      final response = await ApiService.get('${ApiConfig.walletEndpoint}/info');
      print('Réponse brute de getWalletInfo: $response');

      return {
        'balance': response['balance'] is double
            ? response['balance'] as double
            : double.tryParse(response['balance']?.toString() ?? '0.0') ?? 0.0,
        'available_for_withdrawal': response['available_for_withdrawal'] is int
            ? (response['available_for_withdrawal'] as int).toDouble()
            : double.tryParse(
                    response['available_for_withdrawal']?.toString() ?? '0.0',
                  ) ??
                  0.0,
        'pending_withdrawals': response['pending_withdrawals'] is int
            ? (response['pending_withdrawals'] as int).toDouble()
            : double.tryParse(
                    response['pending_withdrawals']?.toString() ?? '0.0',
                  ) ??
                  0.0,
        'total_earned': response['total_earned'] is int
            ? (response['total_earned'] as int).toDouble()
            : double.tryParse(response['total_earned']?.toString() ?? '0.0') ??
                  0.0,
      };
    } catch (e) {
      print(
        'Erreur lors de la récupération des informations du portefeuille: $e',
      );
      return {
        'balance': 1000.0, // Bonus de bienvenue
        'available_for_withdrawal': 0.0,
        'pending_withdrawals': 0.0,
        'total_earned': 1000.0,
      };
    }
  }

  // Obtenir l'historique des transactions
  static Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.transactionsEndpoint}?page=$page&limit=$limit',
      );

      if (response['transactions'] != null) {
        return (response['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList();
      }

      return [];
    } catch (e) {
      // Retourner des transactions fictives en cas d'erreur
      return _getMockTransactions();
    }
  }

  // Demander un retrait
  static Future<bool> requestWithdrawal(double amount, String phoneNumber) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.walletEndpoint}/withdraw',
        {
          'amount': amount,
          'method': 'mobile_money', // ou 'bank_transfer'
          'phone_number': phoneNumber
        },
      );

      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Effectuer un dépôt
  static Future<Map<String, dynamic>> deposit(
    double amount,
  ) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.walletEndpoint}/deposit',
        {'amount': amount},
      );

      return {
        'success': response['success'] == true,
        'transaction_id': response['transaction_id'],
      };
    } catch (e) {
      return {'success': false};
    }
  }

  // Vérifier le statut d'une transaction
  static Future<Transaction?> checkTransactionStatus(
    String transactionId,
  ) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.transactionsEndpoint}/$transactionId',
      );

      if (response['transaction'] != null) {
        return Transaction.fromJson(response['transaction']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Transférer vers un autre utilisateur
  static Future<bool> transfer(String recipientCode, double amount) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.walletEndpoint}/transfer',
        {'recipient_code': recipientCode, 'amount': amount},
      );

      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Données fictives pour les tests
  static List<Transaction> _getMockTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        userId: '1',
        type: TransactionType.bonus,
        amount: 1000.00,
        description: 'Bonus de bienvenue',
        status: TransactionStatus.completed,
        createdAt: now.subtract(Duration(days: 7)),
        completedAt: now.subtract(Duration(days: 7)),
      ),
      Transaction(
        id: '2',
        userId: '1',
        type: TransactionType.commission,
        amount: 2000.00,
        description: 'Commission affiliation - Marie K.',
        status: TransactionStatus.completed,
        createdAt: now.subtract(Duration(days: 5)),
        completedAt: now.subtract(Duration(days: 5)),
      ),
      Transaction(
        id: '3',
        userId: '1',
        type: TransactionType.quiz_reward,
        amount: 100.00,
        description: 'Récompense Quiz - Culture générale',
        status: TransactionStatus.completed,
        createdAt: now.subtract(Duration(days: 3)),
        completedAt: now.subtract(Duration(days: 3)),
      ),
      Transaction(
        id: '4',
        userId: '1',
        type: TransactionType.cashback,
        amount: 500.00,
        description: 'Cashback formation - Dropshipping 2025',
        status: TransactionStatus.completed,
        createdAt: now.subtract(Duration(days: 2)),
        completedAt: now.subtract(Duration(days: 2)),
      ),
      Transaction(
        id: '5',
        userId: '1',
        type: TransactionType.purchase,
        amount: -45000.00,
        description: 'Achat pack Business Mastery',
        status: TransactionStatus.completed,
        createdAt: now.subtract(Duration(days: 1)),
        completedAt: now.subtract(Duration(days: 1)),
      ),
    ];
  }
}
