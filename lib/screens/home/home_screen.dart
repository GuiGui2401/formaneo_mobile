import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/recent_activity_provider.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _notificationTimer;
  int _currentNotificationIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startNotificationRotation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _startNotificationRotation() {
    _notificationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentNotificationIndex =
              (_currentNotificationIndex + 1) %
              FictiveNotifications.notifications.length;
        });
      }
    });
  }

  void _loadData() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final recentActivityProvider = Provider.of<RecentActivityProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      authProvider.loadUserData(),
      walletProvider.loadBalance(),
      recentActivityProvider.loadRecentActivities(),
    ]);

    setState(() => _isLoading = false);
  }

  Future<void> _handleRefresh() async {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final recentActivityProvider = Provider.of<RecentActivityProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user?.name ?? 'Utilisateur'),
                      SizedBox(height: AppSpacing.lg),
                      _buildBalanceCard(walletProvider.balance),
                      //SizedBox(height: AppSpacing.lg),
                      //_buildWithdrawalAvailability(walletProvider.balance),
                      SizedBox(height: AppSpacing.lg),
                      _buildNotificationBar(),
                      SizedBox(height: AppSpacing.lg),
                      _buildServicesGrid(),
                      SizedBox(height: AppSpacing.lg),
                      _buildRecentActivity(recentActivityProvider),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, color: AppTheme.primaryColor, size: 28),
            ),
            SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: _showNotifications,
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 28,
                    color: AppTheme.textSecondary,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          // Carte principale avec gradient
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.85),
                ],
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
          ),

          // Formes géométriques décoratives en arrière-plan
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 30,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 80,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 2,
                ),
              ),
            ),
          ),

          // Contenu de la carte
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // En-tête avec icône
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Solde du compte',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Badge décoratif
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Actif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Montant du solde
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatAmount(balance),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Disponible immédiatement',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Bouton de retrait modernisé
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showWithdrawDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_circle_down, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Retirer',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Action pour voir l'historique ou les détails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Historique des transactions'),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildWithdrawalAvailability(double balance) {
    final canWithdraw = balance >= AppConstants.minWithdrawalAmount;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: canWithdraw
            ? AppTheme.accentColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: canWithdraw
              ? AppTheme.accentColor
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: canWithdraw ? AppTheme.accentColor : Colors.grey,
            size: 20,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canWithdraw
                      ? 'Disponible pour retrait'
                      : 'Retrait non disponible',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: canWithdraw ? AppTheme.accentColor : Colors.grey,
                  ),
                ),
                Text(
                  canWithdraw
                      ? 'Vous pouvez retirer vos gains'
                      : 'Minimum requis: ${Formatters.formatAmount(AppConstants.minWithdrawalAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: canWithdraw ? AppTheme.textSecondary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canWithdraw ? _showWithdrawDialog : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canWithdraw ? AppTheme.accentColor : Colors.grey,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text('Retirer', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }*/

  Widget _buildNotificationBar() {
    final notification =
        FictiveNotifications.notifications[_currentNotificationIndex];

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_currentNotificationIndex),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.campaign, color: Colors.orange, size: 20),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '🎉 ${notification['name']} ${notification['action']} ${notification['amount']} ${notification['source']}',
                style: TextStyle(color: Colors.orange[800], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nos Services', style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculer la largeur disponible pour chaque carte
            final cardWidth = (constraints.maxWidth - (2 * AppSpacing.md)) / 3;
            final cardHeight =
                cardWidth + 20; // Ajuster la hauteur selon le contenu

            return GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: cardWidth / cardHeight,
              children: [
                _buildServiceCard(
                  'Quiz Rémunérés',
                  'Testez vos connaissances',
                  AppTheme.primaryColor,
                  Icons.quiz,
                  () => Navigator.pushNamed(context, '/quiz'),
                ),
                _buildServiceCard(
                  'Formations',
                  'Packs de formations',
                  AppTheme.primaryColor,
                  Icons.school,
                  () => Navigator.pushNamed(context, '/formations'),
                ),
                _buildServiceCard(
                  'Ebooks',
                  'Bibliothèque numérique',
                  AppTheme.primaryColor,
                  Icons.menu_book,
                  () => Navigator.pushNamed(context, '/ebooks'),
                ),
                _buildServiceCard(
                  'Programme d\'Affiliation',
                  'Invitez et gagnez',
                  AppTheme.primaryColor,
                  Icons.people,
                  () => Navigator.pushNamed(context, '/affiliate'),
                ),
                _buildServiceCard(
                  'Défis & Récompenses',
                  'Participez aux défis',
                  AppTheme.primaryColor,
                  Icons.emoji_events,
                  () => _showDefisModal(),
                ),
                _buildServiceCard(
                  'Mes Cartes Bancaires',
                  'Bientôt disponible',
                  AppTheme.primaryColor,
                  Icons.credit_card,
                  () => _showComingSoon('Mes Cartes Bancaires'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              SizedBox(height: AppSpacing.xs),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(RecentActivityProvider provider) {
    final activities = provider.recentActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activité récente',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/transactions'),
              child: Text('Voir tout'),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: activities.asMap().entries.map((entry) {
              int index = entry.key;
              Transaction activity = entry.value;

              return Column(
                children: [
                  _buildActivityItem(
                    activity.description,
                    activity.isCredit
                        ? '+${Formatters.formatAmount(activity.amount)}'
                        : '-${Formatters.formatAmount(activity.amount.abs())}',
                    '${activity.createdAt.day}/${activity.createdAt.month}/${activity.createdAt.year}',
                  ),
                  if (index <
                      activities.length -
                          1) // Divider sauf pour le dernier élément
                    Divider(height: 1, color: Colors.grey[200]),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String amount, String date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    final recentActivityProvider = Provider.of<RecentActivityProvider>(context, listen: false);
    final activities = recentActivityProvider.recentActivities;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'Activités récentes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: activities.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune activité récente',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: activities.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: activity.isCredit
                                  ? AppTheme.accentColor.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                            ),
                            child: Icon(
                              activity.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: activity.isCredit ? AppTheme.accentColor : Colors.red,
                            ),
                          ),
                          title: Text(
                            activity.description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${activity.createdAt.day}/${activity.createdAt.month}/${activity.createdAt.year}',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          trailing: Text(
                            activity.isCredit
                                ? '+${Formatters.formatAmount(activity.amount)}'
                                : '-${Formatters.formatAmount(activity.amount.abs())}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: activity.isCredit ? AppTheme.accentColor : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
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
            Text(
              'Solde disponible: ${Formatters.formatAmount(walletProvider.balance)}',
            ),
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
                  SnackBar(
                    content: Text('Veuillez fournir votre numéro de téléphone'),
                  ),
                );
                return;
              }

              // Effectuer la demande de retrait
              _processWithdrawal(
                double.tryParse(amountController.text) ?? 0,
                phoneController.text,
              );
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
      final success = await walletProvider.requestWithdrawal(
        amount,
        phoneNumber,
      );

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

  void _showDefisModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'Défis & Récompenses',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                children: [
                  _buildDefiCard(
                    'Première formation complétée',
                    'Terminez votre première formation',
                    '+1,000 FCFA',
                    Icons.school,
                    false,
                  ),
                  _buildDefiCard(
                    'Quiz Master',
                    'Réussissez 5 quiz d\'affilée',
                    '+500 FCFA',
                    Icons.quiz,
                    false,
                  ),
                  _buildDefiCard(
                    'Parrain actif',
                    'Invitez 3 amis qui s\'inscrivent',
                    '+2,000 FCFA',
                    Icons.people,
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefiCard(
    String title,
    String description,
    String reward,
    IconData icon,
    bool isCompleted,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.accentColor.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : icon,
                color: isCompleted
                    ? AppTheme.accentColor
                    : AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              reward,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fonctionnalité bientôt disponible !'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}

// Classe pour les notifications fictives
class FictiveNotifications {
  static final List<Map<String, String>> notifications = [
    {
      'name': 'Marie K.',
      'action': 'a gagné',
      'amount': '2,500 FCFA',
      'source': 'en complétant une formation',
    },
    {
      'name': 'Jean-Paul M.',
      'action': 'a reçu',
      'amount': '1,000 FCFA',
      'source': 'de bonus d\'affiliation',
    },
    {
      'name': 'Sophie L.',
      'action': 'a obtenu',
      'amount': '500 FCFA',
      'source': 'pour un quiz réussi',
    },
    {
      'name': 'Ahmed B.',
      'action': 'a encaissé',
      'amount': '3,200 FCFA',
      'source': 'de cashback formations',
    },
    {
      'name': 'Fatou D.',
      'action': 'a gagné',
      'amount': '1,500 FCFA',
      'source': 'en parrainant un ami',
    },
    {
      'name': 'Ibrahim T.',
      'action': 'a reçu',
      'amount': '750 FCFA',
      'source': 'pour avoir terminé un ebook',
    },
    {
      'name': 'Aïcha N.',
      'action': 'a obtenu',
      'amount': '4,000 FCFA',
      'source': 'en complétant 3 formations',
    },
    {
      'name': 'Pierre D.',
      'action': 'a gagné',
      'amount': '1,800 FCFA',
      'source': 'avec le programme d\'affiliation',
    },
    {
      'name': 'Aminata S.',
      'action': 'a encaissé',
      'amount': '600 FCFA',
      'source': 'de bonus de bienvenue',
    },
    {
      'name': 'Claude M.',
      'action': 'a reçu',
      'amount': '2,200 FCFA',
      'source': 'pour 5 quiz réussis',
    },
    {
      'name': 'Yasmine H.',
      'action': 'a obtenu',
      'amount': '3,500 FCFA',
      'source': 'en parrainant 2 amis',
    },
    {
      'name': 'Moussa F.',
      'action': 'a gagné',
      'amount': '900 FCFA',
      'source': 'de cashback sur achat',
    },
    {
      'name': 'Élise B.',
      'action': 'a encaissé',
      'amount': '1,300 FCFA',
      'source': 'pour défi hebdomadaire réussi',
    },
    {
      'name': 'Mamadou K.',
      'action': 'a reçu',
      'amount': '2,800 FCFA',
      'source': 'en complétant un pack formation',
    },
    {
      'name': 'Sarah L.',
      'action': 'a obtenu',
      'amount': '1,100 FCFA',
      'source': 'de bonus de fidélité',
    },
    {
      'name': 'Abdoulaye D.',
      'action': 'a gagné',
      'amount': '4,500 FCFA',
      'source': 'pour 10 quiz parfaits',
    },
    {
      'name': 'Nadia R.',
      'action': 'a encaissé',
      'amount': '800 FCFA',
      'source': 'en participant à un défi',
    },
    {
      'name': 'Thomas G.',
      'action': 'a reçu',
      'amount': '1,950 FCFA',
      'source': 'de commission d\'affiliation',
    },
    {
      'name': 'Khadija A.',
      'action': 'a obtenu',
      'amount': '650 FCFA',
      'source': 'pour quiz du jour réussi',
    },
    {
      'name': 'Olivier P.',
      'action': 'a gagné',
      'amount': '3,100 FCFA',
      'source': 'en complétant toutes les formations',
    },
    {
      'name': 'Mariam Y.',
      'action': 'a encaissé',
      'amount': '1,450 FCFA',
      'source': 'de cashback mensuel',
    },
    {
      'name': 'David K.',
      'action': 'a reçu',
      'amount': '2,700 FCFA',
      'source': 'en parrainant 3 nouveaux membres',
    },
    {
      'name': 'Rachida M.',
      'action': 'a obtenu',
      'amount': '550 FCFA',
      'source': 'pour connexion quotidienne',
    },
    {
      'name': 'Serge N.',
      'action': 'a gagné',
      'amount': '1,600 FCFA',
      'source': 'de bonus spécial formation',
    },
    {
      'name': 'Fatoumata B.',
      'action': 'a encaissé',
      'amount': '2,400 FCFA',
      'source': 'pour participation active',
    },
    {
      'name': 'Laurent C.',
      'action': 'a reçu',
      'amount': '950 FCFA',
      'source': 'de récompense hebdomadaire',
    },
    {
      'name': 'Awa S.',
      'action': 'a obtenu',
      'amount': '3,800 FCFA',
      'source': 'en terminant un parcours complet',
    },
    {
      'name': 'Karim H.',
      'action': 'a gagné',
      'amount': '1,250 FCFA',
      'source': 'pour 3 ebooks terminés',
    },
    {
      'name': 'Cécile V.',
      'action': 'a encaissé',
      'amount': '700 FCFA',
      'source': 'de bonus surprise',
    },
    {
      'name': 'Boubacar T.',
      'action': 'a reçu',
      'amount': '4,200 FCFA',
      'source': 'en complétant le défi du mois',
    },
  ];
}