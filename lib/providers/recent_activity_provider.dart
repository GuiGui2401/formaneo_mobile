import 'package:flutter/foundation.dart';
import '../services/wallet_service.dart';
import '../models/transaction.dart';

class RecentActivityProvider extends ChangeNotifier {
  List<Transaction> _recentActivities = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecentActivities({int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recentActivities = await WalletService.getTransactions(limit: limit);
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des activités récentes: $e');
      // En cas d'erreur, on utilise des transactions fictives
      _recentActivities = [
        Transaction(
          id: '1',
          userId: '1',
          type: TransactionType.bonus,
          amount: 1000.00,
          description: 'Bonus de bienvenue',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(Duration(days: 7)),
          completedAt: DateTime.now().subtract(Duration(days: 7)),
        ),
        Transaction(
          id: '2',
          userId: '1',
          type: TransactionType.commission,
          amount: 2000.00,
          description: 'Commission affiliation - Marie K.',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          completedAt: DateTime.now().subtract(Duration(days: 5)),
        ),
        Transaction(
          id: '3',
          userId: '1',
          type: TransactionType.quiz_reward,
          amount: 100.00,
          description: 'Récompense Quiz - Culture générale',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          completedAt: DateTime.now().subtract(Duration(days: 3)),
        ),
        Transaction(
          id: '4',
          userId: '1',
          type: TransactionType.cashback,
          amount: 500.00,
          description: 'Cashback formation - Dropshipping 2025',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          completedAt: DateTime.now().subtract(Duration(days: 2)),
        ),
        Transaction(
          id: '5',
          userId: '1',
          type: TransactionType.purchase,
          amount: -45000.00,
          description: 'Achat pack Business Mastery',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          completedAt: DateTime.now().subtract(Duration(days: 1)),
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}