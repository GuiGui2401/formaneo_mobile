import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme.dart';

class ParrainageDashboard extends StatefulWidget {
  @override
  _ParrainageDashboardState createState() => _ParrainageDashboardState();
}

class _ParrainageDashboardState extends State<ParrainageDashboard> {
  final String referralCode = 'WB001';
  final String referralLink = 'http://cleanestuaire.com/invite/WB001';

  // Données exemple
  final Map<String, double> earnings = {
    'today': 2500.00,
    'yesterday': 11878.00,
    'currentMonth': 51660.00,
    'lastMonth': 31700.00,
    'total': 115566.00,
  };

  final Map<String, int> stats = {
    'directReferrals': 20,
    'indirectReferrals': 43,
    'level2Referrals': 3,
    'totalReferrals': 66,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderStats(),
            SizedBox(height: AppSpacing.lg),
            _buildTotalCommissionCard(),
            SizedBox(height: AppSpacing.lg),
            _buildEarningsChart(),
            SizedBox(height: AppSpacing.lg),
            _buildReferralStats(),
            SizedBox(height: AppSpacing.lg),
            _buildReferralTools(),
            SizedBox(height: AppSpacing.lg),
            _buildTopReferrers(),
          ],
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
          Text('Parrainage'),
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

  Widget _buildHeaderStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Aujourd\'hui',
          amount: '${earnings['today']!.toStringAsFixed(0)} FCFA',
          color: AppTheme.primaryColor,
          icon: Icons.today,
        ),
        _buildStatCard(
          title: 'Hier',
          amount: '${earnings['yesterday']!.toStringAsFixed(0)} FCFA',
          color: Colors.orange,
          icon: Icons.history,
        ),
        _buildStatCard(
          title: 'Mois en cours',
          amount: '${earnings['currentMonth']!.toStringAsFixed(0)} FCFA',
          color: AppTheme.accentColor,
          icon: Icons.calendar_month,
        ),
        _buildStatCard(
          title: 'Mois dernier',
          amount: '${earnings['lastMonth']!.toStringAsFixed(0)} FCFA',
          color: AppTheme.secondaryColor,
          icon: Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
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
        children: [
          Row(
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
              Spacer(),
              Icon(Icons.trending_up, color: AppTheme.accentColor, size: 16),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCommissionCard() {
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
            '${earnings['total']!.toStringAsFixed(0)} FCFA',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat('Filleuls directs', '${stats['directReferrals']}'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildMiniStat('Niveau 2', '${stats['level2Referrals']}'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildMiniStat('Total', '${stats['totalReferrals']}'),
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

  Widget _buildEarningsChart() {
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
            'Évolution des gains',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            height: 200,
            child: CustomPaint(
              painter: SimpleBarChartPainter(),
              size: Size.infinite,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            children: [
              _buildLegendItem('Clics sur lien', AppTheme.accentColor),
              _buildLegendItem('Inscriptions', AppTheme.primaryColor),
              _buildLegendItem('Achats', Colors.orange),
              _buildLegendItem('Commissions', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildReferralStats() {
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
            'Statistiques d\'inscription',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildDetailedStatCard(
                  '${stats['directReferrals']}',
                  'Inscriptions avec achat',
                  Colors.red,
                  Icons.shopping_cart,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildDetailedStatCard(
                  '${stats['indirectReferrals']}',
                  'Inscriptions sans achat',
                  AppTheme.primaryColor,
                  Icons.person_add,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildDetailedStatCard(
            '${stats['level2Referrals']}',
            'Inscriptions Sous-filleuls avec dépôt',
            AppTheme.accentColor,
            Icons.groups,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatCard(
    String number,
    String label,
    Color color,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
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
          SizedBox(height: AppSpacing.md),
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralTools() {
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
            'Outils de parrainage',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildReferralItem(
            'Mon lien de parrainage',
            referralLink,
            Icons.link,
            () => _copyToClipboard(referralLink, 'Lien copié !'),
          ),
          SizedBox(height: AppSpacing.md),
          _buildReferralItem(
            'Mon code de parrainage',
            referralCode,
            Icons.card_membership,
            () => _copyToClipboard(referralCode, 'Code copié !'),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareReferralLink,
                  icon: Icon(Icons.share),
                  label: Text('Partager'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showReferralTips,
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text('Conseils'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralItem(
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

  Widget _buildTopReferrers() {
    final topReferrers = [
      {'name': 'Marie K.', 'earnings': '45,000 FCFA', 'referrals': 15},
      {'name': 'Jean B.', 'earnings': '38,500 FCFA', 'referrals': 12},
      {'name': 'Sophie L.', 'earnings': '32,000 FCFA', 'referrals': 10},
      {
        'name': 'Vous',
        'earnings': '${earnings['total']!.toStringAsFixed(0)} FCFA',
        'referrals': stats['totalReferrals'],
      },
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
                'Top Parrains cette semaine',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ...topReferrers.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> referrer = entry.value;
            bool isCurrentUser = referrer['name'] == 'Vous';

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
                          referrer['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isCurrentUser
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${referrer['referrals']} filleuls',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    referrer['earnings'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  if (index < 3)
                    Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                ],
              ),
            );
          }).toList(),
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

  void _shareReferralLink() {
    // Dans une vraie app, utiliser share_plus package
    _copyToClipboard(
      'Rejoins-moi sur Formaneo et commence à apprendre ! Utilise mon code $referralCode ou mon lien $referralLink',
      'Texte de partage copié !',
    );
  }

  void _showReferralTips() {
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
                  Text(
                    'Conseils pour réussir son parrainage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
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
                    '1. Partage ton expérience',
                    'Raconte comment Formaneo t\'a aidé dans ton apprentissage. L\'authenticité attire !',
                    Icons.favorite,
                    Colors.pink,
                  ),
                  _buildTipCard(
                    '2. Utilise les réseaux sociaux',
                    'Partage ton lien sur WhatsApp, Facebook, Instagram. N\'oublie pas tes stories !',
                    Icons.share,
                    AppTheme.primaryColor,
                  ),
                  _buildTipCard(
                    '3. Aide tes filleuls',
                    'Guide tes filleuls dans leurs premiers pas. Plus ils réussissent, plus tu gagnes !',
                    Icons.help,
                    AppTheme.accentColor,
                  ),
                  _buildTipCard(
                    '4. Sois régulier',
                    'Partage régulièrement mais sans spammer. La consistance paye !',
                    Icons.schedule,
                    Colors.orange,
                  ),
                  _buildTipCard(
                    '5. Montre tes résultats',
                    'Partage tes gains et certificats. Les preuves sociales sont puissantes !',
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
}

class SimpleBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final barWidth = size.width / 16;

    // Données exemple pour les barres (4 catégories x 12 semaines)
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
