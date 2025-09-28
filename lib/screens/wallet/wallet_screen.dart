import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/wallet_provider.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    await walletProvider.loadBalance();
    await walletProvider.loadTransactions();
  }

  Future<void> _handleRefresh() async {
    await _loadWalletData();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Portefeuille'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(walletProvider),
                    SizedBox(height: AppSpacing.lg),
                    _buildWithdrawalSection(walletProvider),
                    SizedBox(height: AppSpacing.lg),
                    _buildQuickActions(),
                    SizedBox(height: AppSpacing.lg),
                    _buildStatistics(walletProvider),
                    SizedBox(height: AppSpacing.lg),
                    _buildTransactionHistory(walletProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
              SizedBox(width: AppSpacing.md),
              Text(
                'Solde Total',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            Formatters.formatAmount(provider.balance),
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 16),
                SizedBox(width: AppSpacing.sm),
                Text(
                  '+15% ce mois',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalSection(WalletProvider provider) {
    final canWithdraw = provider.availableForWithdrawal >= AppConstants.minWithdrawalAmount;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.money,
                color: canWithdraw ? AppTheme.accentColor : Colors.grey,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Disponible pour retrait',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            Formatters.formatAmount(provider.availableForWithdrawal),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: canWithdraw ? AppTheme.accentColor : Colors.grey,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          if (!canWithdraw)
            Text(
              'Minimum requis: ${Formatters.formatAmount(AppConstants.minWithdrawalAmount)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: canWithdraw ? () => _showWithdrawDialog() : null,
              icon: Icon(Icons.send),
              label: Text('Effectuer un retrait'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canWithdraw ? AppTheme.accentColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Déposer',
                  Icons.add_circle,
                  AppTheme.primaryColor,
                  _showDepositDialog,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionButton(
                  'Transférer',
                  Icons.swap_horiz,
                  AppTheme.secondaryColor,
                  _showTransferDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(WalletProvider provider) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Gains totaux',
                  Formatters.formatAmount(115566.00),
                  Icons.trending_up,
                  AppTheme.accentColor,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Retraits',
                  Formatters.formatAmount(15566.00),
                  Icons.download,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Commissions',
                  Formatters.formatAmount(51660.00),
                  Icons.people,
                  AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Quiz & Bonus',
                  Formatters.formatAmount(3600.00),
                  Icons.card_giftcard,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(WalletProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique des transactions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/transactions'),
                  child: Text('Voir tout'),
                ),
              ],
            ),
          ),
          if (provider.transactions.isEmpty)
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  'Aucune transaction',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: provider.transactions.take(5).length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = provider.transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppTheme.accentColor : AppTheme.errorColor;
    final icon = _getTransactionIcon(transaction.type);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        transaction.description,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        Formatters.formatDateTime(transaction.createdAt),
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isCredit ? '+' : '-'}${Formatters.formatAmount(transaction.amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              transaction.statusLabel,
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(transaction.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.add_circle;
      case TransactionType.withdrawal:
        return Icons.remove_circle;
      case TransactionType.bonus:
        return Icons.card_giftcard;
      case TransactionType.commission:
        return Icons.people;
      case TransactionType.cashback:
        return Icons.replay;
      case TransactionType.purchase:
        return Icons.shopping_cart;
      case TransactionType.quiz_reward:
        return Icons.quiz;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.completed:
        return AppTheme.accentColor;
      case TransactionStatus.failed:
        return AppTheme.errorColor;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  void _showWithdrawDialog() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final TextEditingController amountController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Demande de retrait'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solde disponible: ${Formatters.formatAmount(walletProvider.balance)}'),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant à retirer',
                suffixText: 'FCFA',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: 'Ex: 0102030405',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Vérifier que le numéro de téléphone est fourni
              if (phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez fournir votre numéro de téléphone')),
                );
                return;
              }
              
              // Effectuer la demande de retrait
              _processWithdrawal(double.tryParse(amountController.text) ?? 0, phoneController.text);
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _processWithdrawal(double amount, String phoneNumber) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir un montant valide')),
      );
      return;
    }

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    try {
      final success = await walletProvider.requestWithdrawal(amount, phoneNumber);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande de retrait envoyée avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la demande de retrait')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la demande de retrait: $e')),
      );
    }
  }


  void _showDepositDialog() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déposer des fonds'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Solde actuel: ${Formatters.formatAmount(walletProvider.balance)}'),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant à déposer',
                suffixText: 'FCFA',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Vous serez redirigé vers CinetPay pour effectuer le paiement.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount >= 500) {
                _processDeposit(amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez saisir un montant valide (minimum 500 FCFA)')),
                );
              }
            },
            child: Text('Procéder au paiement'),
          ),
        ],
      ),
    );
  }

  void _processDeposit(double amount) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    try {
      final result = await walletProvider.deposit(amount);
      
      if (result['success'] == true) {
        // Rediriger vers CinetPay pour le paiement
        // Note: Vous devrez implémenter la logique d'intégration CinetPay ici
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirection vers CinetPay...')),
        );
        // Ajoutez ici la logique pour ouvrir l'URL de paiement CinetPay
        // Par exemple: launch(result['payment_url']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'initiation du dépôt')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du dépôt: $e')),
      );
    }
  }

  void _showTransferDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transfert - Fonctionnalité bientôt disponible'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}