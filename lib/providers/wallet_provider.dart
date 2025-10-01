import 'package:flutter/foundation.dart';
import '../services/wallet_service.dart';
import '../models/transaction.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  double _availableForWithdrawal = 0.0;
  double _totalEarned = 0.0;
  double _pendingWithdrawals = 0.0;
  double _totalCommissions = 0.0;
  double _totalQuizAndBonus = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  double get availableForWithdrawal => _availableForWithdrawal;
  double get totalEarned => _totalEarned;
  double get pendingWithdrawals => _pendingWithdrawals;
  double get totalCommissions => _totalCommissions;
  double get totalQuizAndBonus => _totalQuizAndBonus;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final walletData = await WalletService.getWalletInfo();
      print('Données du portefeuille reçues: $walletData');
      _balance = walletData['balance']?.toDouble() ?? 0.0;
      _availableForWithdrawal = walletData['available_for_withdrawal']?.toDouble() ?? 0.0;
      _totalEarned = walletData['total_earned']?.toDouble() ?? 0.0;
      _pendingWithdrawals = walletData['pending_withdrawals']?.toDouble() ?? 0.0;
      _totalCommissions = walletData['total_commissions']?.toDouble() ?? 0.0;
      _totalQuizAndBonus = walletData['total_quiz_and_bonus']?.toDouble() ?? 0.0;
    } catch (e) {
      print('Erreur lors du chargement du solde: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await WalletService.getTransactions();

      // Recalculer les commissions et quiz/bonus depuis les transactions
      // UNIQUEMENT si les valeurs du backend sont à 0
      final calculatedCommissions = _transactions
          .where((t) => t.type == TransactionType.commission && t.isCredit)
          .map((t) => t.amount)
          .fold(0.0, (prev, amount) => prev + amount);

      final calculatedQuizAndBonus = _transactions
          .where((t) => (t.type == TransactionType.quiz_reward || t.type == TransactionType.bonus) && t.isCredit)
          .map((t) => t.amount)
          .fold(0.0, (prev, amount) => prev + amount);

      // Utiliser les valeurs calculées seulement si les valeurs du backend sont à 0
      if (_totalCommissions == 0.0 && calculatedCommissions > 0.0) {
        _totalCommissions = calculatedCommissions;
      }

      if (_totalQuizAndBonus == 0.0 && calculatedQuizAndBonus > 0.0) {
        _totalQuizAndBonus = calculatedQuizAndBonus;
      }

      // Calculer total earned si à 0
      if (_totalEarned == 0.0) {
        _totalEarned = _transactions
            .where((t) => t.isCredit && t.type != TransactionType.deposit)
            .map((t) => t.amount)
            .fold(0.0, (prev, amount) => prev + amount);
      }
    } catch (e) {
      print('Erreur lors du chargement des transactions: $e');
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestWithdrawal(double amount, String phoneNumber) async {
    if (amount > _availableForWithdrawal) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final success = await WalletService.requestWithdrawal(amount, phoneNumber);
      if (success) {
        await loadBalance();
        await loadTransactions();
      }
      return success;
    } catch (e) {
      print('Erreur lors de la demande de retrait: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> deposit(double amount, {String? phoneNumber}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await WalletService.deposit(amount, phoneNumber: phoneNumber);
      if (result['success'] == true) {
        await loadBalance();
        await loadTransactions();
      }
      return result;
    } catch (e) {
      print('Erreur lors du dépôt: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addBalance(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void subtractBalance(double amount) {
    _balance -= amount;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }
}
