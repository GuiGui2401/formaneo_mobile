import 'package:flutter/foundation.dart';
import '../services/wallet_service.dart';
import '../models/transaction.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  double _availableForWithdrawal = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  double get availableForWithdrawal => _availableForWithdrawal;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final walletData = await WalletService.getWalletInfo();
      print('Données du portefeuille reçues: $walletData');
      _balance = walletData['balance'] ?? 0.0;
      _availableForWithdrawal = walletData['available_for_withdrawal'] ?? 0.0;
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
    } catch (e) {
      print('Erreur lors du chargement des transactions: $e');
    } finally {
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
