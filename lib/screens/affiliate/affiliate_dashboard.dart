import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/affiliate_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/formatters.dart';

class AffiliateDashboard extends StatefulWidget {
  @override
  _AffiliateDashboardState createState() => _AffiliateDashboardState();
}

class _AffiliateDashboardState extends State<AffiliateDashboard> {
  String selectedChartType = 'bar'; // bar, line, area
  String selectedPeriod = 'Hebdomadaire'; // Journalière, Hebdomadaire, Mensuelle, Annuelle
  bool _isRefreshing = false;
  bool _showAffiliateTools = false;

  // Variables pour l'interaction tactile sur le graphique
  Offset? _tapPosition;
  bool _showTooltip = false;
  Map<String, int> _tooltipData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final provider = Provider.of<AffiliateProvider>(context, listen: false);
      await provider.loadAffiliateData();
      
      // Vérifier s'il y a une erreur
      if (provider.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données d\'affiliation: $e');
      // Afficher un message d'erreur à l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des données'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      await _loadData();
    } catch (e) {
      print('Erreur lors du rafraîchissement: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du rafraîchissement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final affiliateProvider = Provider.of<AffiliateProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    
    // Vérifier s'il y a une erreur critique
    if (affiliateProvider.error != null && affiliateProvider.affiliateData == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  affiliateProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleRefresh,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWithdrawalAvailability(walletProvider.balance),
              SizedBox(height: AppSpacing.lg),
              _buildHeaderStats(affiliateProvider),
              SizedBox(height: AppSpacing.lg),
              _buildTotalCommissionCard(affiliateProvider),
              SizedBox(height: AppSpacing.lg),
              _buildEarningsChart(affiliateProvider),
              SizedBox(height: AppSpacing.lg),
              _buildAffiliateStats(affiliateProvider),
              SizedBox(height: AppSpacing.lg),
              _buildToolsAndTipsSection(affiliateProvider),
              SizedBox(height: AppSpacing.lg),
              _buildPromoBanners(),
              SizedBox(height: AppSpacing.lg),
              _buildTopAffiliates(),
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(Icons.people, color: Colors.white, size: 18),
          ),
          SizedBox(width: AppSpacing.md),
          Text('Affiliation'),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: AppSpacing.md),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dashboard, color: Colors.white, size: 16),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalAvailability(double balance) {
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
            Icons.account_balance_wallet,
            color: canWithdraw ? AppTheme.accentColor : Colors.grey,
            size: 24,
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
                    fontSize: 16,
                  ),
                ),
                Text(
                  canWithdraw
                      ? 'Solde: ${Formatters.formatAmount(balance)}'
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
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            child: Text(
              'Retirer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(AffiliateProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - AppSpacing.md) / 2;
        final cardHeight = cardWidth * 0.7;
        
        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: cardWidth / cardHeight,
          children: [
            _buildStatCard(
              title: 'Aujourd\'hui',
              amount: Formatters.formatAmount(provider.earnings?['today'] ?? 0),
              color: AppTheme.primaryColor,
              icon: Icons.today,
            ),
            _buildStatCard(
              title: 'Hier',
              amount: Formatters.formatAmount(provider.earnings?['yesterday'] ?? 0),
              color: Colors.orange,
              icon: Icons.history,
            ),
            _buildStatCard(
              title: 'Mois en cours',
              amount: Formatters.formatAmount(
                provider.earnings?['currentMonth'] ?? 0,
              ),
              color: AppTheme.accentColor,
              icon: Icons.calendar_month,
            ),
            _buildStatCard(
              title: 'Mois dernier',
              amount: Formatters.formatAmount(provider.earnings?['lastMonth'] ?? 0),
              color: AppTheme.secondaryColor,
              icon: Icons.calendar_today,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Spacer(),
              Icon(Icons.trending_up, color: AppTheme.accentColor, size: 14),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Flexible(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCommissionCard(AffiliateProvider provider) {
    final affiliateCount = provider.stats?['totalAffiliates'] ?? 0;
    final commissionRate = affiliateCount > 100
        ? AppConstants.level1CommissionPremium
        : AppConstants.level1CommissionBasic;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
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
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
          SizedBox(height: AppSpacing.md),
          Text(
            Formatters.formatAmount(provider.earnings?['total'] ?? 0),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            ),
            child: Text(
              'TOTAL COMMISSION',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              'Commission actuelle: ${Formatters.formatAmount(commissionRate)}/inscription',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat('Total affiliés', '$affiliateCount'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildMiniStat(
                'Ce mois',
                '${provider.stats?['monthlyAffiliates'] ?? 0}',
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildMiniStat(
                'Niveau',
                affiliateCount > 100 ? 'Premium' : 'Basic',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEarningsChart(AffiliateProvider provider) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Évolution des gains',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              _buildChartTypeSelector(),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildPeriodSelector(),
          SizedBox(height: AppSpacing.md),
          Container(
            height: 200,
            child: GestureDetector(
              onTapDown: (details) => _handleChartTap(details.localPosition),
              onTapCancel: () => setState(() => _showTooltip = false),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: selectedChartType == 'bar'
                        ? BarChartPainter()
                        : selectedChartType == 'line'
                        ? LineChartPainter()
                        : AreaChartPainter(),
                    size: Size.infinite,
                  ),
                  if (_showTooltip && _tapPosition != null)
                    Positioned(
                      left: _tapPosition!.dx - 50,
                      top: _tapPosition!.dy - 80,
                      child: _buildTooltip(),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildLegendItem('Clics sur lien', AppTheme.accentColor),
              _buildLegendItem('Inscriptions', AppTheme.primaryColor),
              _buildLegendItem('Achats', Colors.orange),
              _buildLegendItem('Commissions', Colors.red),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          _buildChartStats(),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChartTypeButton('bar', Icons.bar_chart),
          _buildChartTypeButton('line', Icons.show_chart),
          _buildChartTypeButton('area', Icons.area_chart),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(String type, IconData icon) {
    final isSelected = selectedChartType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedChartType = type),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Journalière', 'Hebdomadaire', 'Mensuelle', 'Annuelle'];
    
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = selectedPeriod == period;
          
          return Container(
            margin: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedPeriod = period;
                });
              },
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTooltip() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semaine 12',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          SizedBox(height: 2),
          Text('Clics: ${_tooltipData['clics'] ?? 45}', style: TextStyle(color: Colors.white, fontSize: 10)),
          Text('Inscriptions: ${_tooltipData['inscriptions'] ?? 12}', style: TextStyle(color: Colors.white, fontSize: 10)),
          Text('Achats: ${_tooltipData['achats'] ?? 8}', style: TextStyle(color: Colors.white, fontSize: 10)),
          Text('Commission: ${_tooltipData['commission'] ?? 2400} FCFA', style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildChartStats() {
    final stats = _getStatsForPeriod();
    
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques - $selectedPeriod',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Inscriptions', '${stats['inscriptions']}', Icons.person_add),
              ),
              Expanded(
                child: _buildStatItem('Achats formations', '${stats['achats']}', Icons.shopping_cart),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Non-achats', '${stats['nonAchats']}', Icons.cancel),
              ),
              Expanded(
                child: _buildStatItem('Sous-filleuls', '${stats['sousFilleuls']}', Icons.people_outline),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Sous-filleuls actifs', '${stats['sousFilleulsActifs']}', Icons.people),
              ),
              Expanded(
                child: Container(), // Espacement
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, int> _getStatsForPeriod() {
    switch (selectedPeriod) {
      case 'Journalière':
        return {
          'inscriptions': 3,
          'achats': 2,
          'nonAchats': 1,
          'sousFilleuls': 1,
          'sousFilleulsActifs': 1,
        };
      case 'Hebdomadaire':
        return {
          'inscriptions': 18,
          'achats': 12,
          'nonAchats': 6,
          'sousFilleuls': 5,
          'sousFilleulsActifs': 3,
        };
      case 'Mensuelle':
        return {
          'inscriptions': 75,
          'achats': 45,
          'nonAchats': 30,
          'sousFilleuls': 18,
          'sousFilleulsActifs': 12,
        };
      case 'Annuelle':
        return {
          'inscriptions': 850,
          'achats': 520,
          'nonAchats': 330,
          'sousFilleuls': 180,
          'sousFilleulsActifs': 125,
        };
      default:
        return {
          'inscriptions': 18,
          'achats': 12,
          'nonAchats': 6,
          'sousFilleuls': 5,
          'sousFilleulsActifs': 3,
        };
    }
  }

  void _handleChartTap(Offset position) {
    setState(() {
      _tapPosition = position;
      _showTooltip = true;
      // Simuler des données basées sur la position
      final weekIndex = (position.dx / 200 * 12).round();
      _tooltipData = {
        'clics': 35 + (weekIndex * 3),
        'inscriptions': 10 + (weekIndex * 2),
        'achats': 6 + weekIndex,
        'commission': (6 + weekIndex) * 300,
      };
    });
    
    // Masquer le tooltip après 3 secondes
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showTooltip = false);
      }
    });
  }

  Widget _buildAffiliateStats(AffiliateProvider provider) {
    final monthlyAffiliates = provider.stats?['monthlyAffiliates'] ?? 0;
    final level = monthlyAffiliates > 100 ? 'Premium' : 'Basic';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Système d\'affiliation à 2 niveaux',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildLevelCard(
            'Niveau Basic',
            '0 à 100 affiliés/mois',
            Formatters.formatAmount(AppConstants.level1CommissionBasic),
            AppTheme.primaryColor,
            monthlyAffiliates <= 100,
          ),
          SizedBox(height: AppSpacing.md),
          _buildLevelCard(
            'Niveau Premium',
            'Plus de 100 affiliés/mois',
            Formatters.formatAmount(AppConstants.level1CommissionPremium),
            AppTheme.accentColor,
            monthlyAffiliates > 100,
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: AppTheme.primaryColor),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Votre niveau actuel: $level (${monthlyAffiliates} affiliés ce mois)',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    String title,
    String description,
    String commission,
    Color color,
    bool isActive,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isActive
            ? color.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: isActive ? color : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(
              isActive ? Icons.check_circle : Icons.lock,
              color: isActive ? color : Colors.grey,
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
                    color: isActive ? AppTheme.textPrimary : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppTheme.textSecondary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            commission,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsAndTipsSection(AffiliateProvider provider) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ressources d\'affiliation',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAffiliateTools = !_showAffiliateTools;
                    });
                  },
                  icon: Icon(_showAffiliateTools ? Icons.expand_less : Icons.expand_more),
                  label: Text('Outils d\'affiliation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showTips,
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text('Conseils'),
                ),
              ),
            ],
          ),
          if (_showAffiliateTools) ...[
            SizedBox(height: AppSpacing.lg),
            _buildAffiliateTools(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildAffiliateTools(AffiliateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Text(
            'Vos outils personnalisés',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildToolItem(
          'Mon lien d\'affiliation',
          provider.affiliateLink,
          Icons.link,
          () => _copyToClipboard(provider.affiliateLink, 'Lien copié !'),
        ),
        SizedBox(height: AppSpacing.md),
        _buildToolItem(
          'Mon code promo',
          provider.promoCode,
          Icons.card_membership,
          () => _copyToClipboard(provider.promoCode, 'Code copié !'),
        ),
        SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareAffiliateLink,
            icon: Icon(Icons.share),
            label: Text('Partager mes liens'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolItem(
    String title,
    String value,
    IconData icon,
    VoidCallback onCopy,
  ) {
    return Column(
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
        SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Icon(icon, color: AppTheme.textSecondary, size: 20),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    'Copier',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanners() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
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
              Icon(Icons.image, color: AppTheme.primaryColor),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Matériel promotionnel',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Téléchargez nos bannières publicitaires pour faciliter votre promotion',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - AppSpacing.md) / 2;
              final cardHeight = cardWidth * 0.8;
              
              return GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: cardWidth / cardHeight,
                children: [
                  _buildBannerCard('Bannière 1080x1080', 'Instagram'),
                  _buildBannerCard('Bannière 1200x630', 'Facebook'),
                  _buildBannerCard('Bannière 1024x512', 'Twitter'),
                  _buildBannerCard('Story 1080x1920', 'Stories'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(String size, String platform) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image, color: AppTheme.primaryColor, size: 24),
          SizedBox(height: AppSpacing.sm),
          Flexible(
            child: Text(
              platform,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              size,
              style: TextStyle(fontSize: 9, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _downloadBanner(platform),
              child: Text('Télécharger', style: TextStyle(fontSize: 10)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAffiliates() {
    final topAffiliates = [
      {'name': 'Marie K.', 'earnings': '45,000.00 FCFA', 'affiliates': 15},
      {'name': 'Jean B.', 'earnings': '38,500.00 FCFA', 'affiliates': 12},
      {'name': 'Sophie L.', 'earnings': '32,000.00 FCFA', 'affiliates': 10},
      {'name': 'Vous', 'earnings': '25,000.00 FCFA', 'affiliates': 8},
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
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
              Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Top Affiliés cette semaine',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ...topAffiliates.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> affiliate = entry.value;
            bool isCurrentUser = affiliate['name'] == 'Vous';

            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: isCurrentUser
                    ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index < 3 ? Colors.amber : AppTheme.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          affiliate['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isCurrentUser
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${affiliate['affiliates']} affiliés',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    affiliate['earnings'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                      fontSize: 12,
                    ),
                  ),
                  if (index < 3)
                    Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final TextEditingController amountController = TextEditingController();

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Demande de retrait envoyée'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAffiliateLink() {
    final provider = Provider.of<AffiliateProvider>(context, listen: false);
    _copyToClipboard(
      'Rejoins-moi sur Formaneo et commence à apprendre ! Utilise mon code ${provider.promoCode} ou mon lien ${provider.affiliateLink}',
      'Texte de partage copié !',
    );
  }

  void _showTips() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppBorderRadius.xl),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.white),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Conseils pour réussir votre affiliation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  _buildTipCard(
                    '1. Partagez votre expérience',
                    'Racontez comment Formaneo vous a aidé dans votre apprentissage. L\'authenticité attire !',
                    Icons.favorite,
                    Colors.pink,
                  ),
                  _buildTipCard(
                    '2. Utilisez les réseaux sociaux',
                    'Partagez votre lien sur WhatsApp, Facebook, Instagram. N\'oubliez pas vos stories !',
                    Icons.share,
                    AppTheme.primaryColor,
                  ),
                  _buildTipCard(
                    '3. Aidez vos affiliés',
                    'Guidez vos affiliés dans leurs premiers pas. Plus ils réussissent, plus vous gagnez !',
                    Icons.help,
                    AppTheme.accentColor,
                  ),
                  _buildTipCard(
                    '4. Soyez régulier',
                    'Partagez régulièrement mais sans spammer. La consistance paye !',
                    Icons.schedule,
                    Colors.orange,
                  ),
                  _buildTipCard(
                    '5. Montrez vos résultats',
                    'Partagez vos gains et certificats. Les preuves sociales sont puissantes !',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
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
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _downloadBanner(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de la bannière $platform...'),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Painters pour les graphiques
class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final barWidth = size.width / 16;

    final data = [
      [15, 12, 8, 5],
      [20, 15, 12, 8],
      [18, 14, 10, 6],
      [25, 20, 15, 10],
      [22, 18, 13, 9],
      [30, 25, 18, 12],
      [28, 22, 16, 11],
      [35, 28, 20, 14],
      [32, 25, 18, 13],
      [40, 32, 22, 16],
      [38, 30, 21, 15],
      [45, 35, 25, 18],
    ];

    final colors = [
      AppTheme.accentColor,
      AppTheme.primaryColor,
      Colors.orange,
      Colors.red,
    ];

    for (int week = 0; week < data.length; week++) {
      for (int bar = 0; bar < data[week].length; bar++) {
        paint.color = colors[bar];
        final barHeight = (data[week][bar] / 50.0) * size.height;
        final x = week * barWidth + bar * (barWidth / 4);
        final rect = Rect.fromLTWH(
          x,
          size.height - barHeight,
          barWidth / 4 - 1,
          barHeight,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(2)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final data = [
      [15, 20, 18, 25, 22, 30, 28, 35, 32, 40, 38, 45],
      [12, 15, 14, 20, 18, 25, 22, 28, 25, 32, 30, 35],
      [8, 12, 10, 15, 13, 18, 16, 20, 18, 22, 21, 25],
      [5, 8, 6, 10, 9, 12, 11, 14, 13, 16, 15, 18],
    ];

    final colors = [
      AppTheme.accentColor,
      AppTheme.primaryColor,
      Colors.orange,
      Colors.red,
    ];

    for (int line = 0; line < data.length; line++) {
      paint.color = colors[line];
      final path = Path();

      for (int i = 0; i < data[line].length; i++) {
        final x = (i / (data[line].length - 1)) * size.width;
        final y = size.height - (data[line][i] / 50.0) * size.height;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final data = [
      [15, 20, 18, 25, 22, 30, 28, 35, 32, 40, 38, 45],
      [12, 15, 14, 20, 18, 25, 22, 28, 25, 32, 30, 35],
      [8, 12, 10, 15, 13, 18, 16, 20, 18, 22, 21, 25],
      [5, 8, 6, 10, 9, 12, 11, 14, 13, 16, 15, 18],
    ];

    final colors = [
      AppTheme.accentColor.withOpacity(0.3),
      AppTheme.primaryColor.withOpacity(0.3),
      Colors.orange.withOpacity(0.3),
      Colors.red.withOpacity(0.3),
    ];

    for (int area = data.length - 1; area >= 0; area--) {
      paint.color = colors[area];
      final path = Path();

      path.moveTo(0, size.height);

      for (int i = 0; i < data[area].length; i++) {
        final x = (i / (data[area].length - 1)) * size.width;
        final y = size.height - (data[area][i] / 50.0) * size.height;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}