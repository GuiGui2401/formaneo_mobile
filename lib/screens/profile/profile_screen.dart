import 'package:flutter/material.dart';
import 'package:formaneo/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/formatters.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildProfileInfo(user),
                  SizedBox(height: AppSpacing.lg),
                  _buildStatsSection(),
                  SizedBox(height: AppSpacing.lg),
                  _buildMenuSection(),
                  SizedBox(height: AppSpacing.lg),
                  _buildSettingsSection(),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Mon Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(dynamic user) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person, color: AppTheme.primaryColor),
            title: Text('Nom'),
            subtitle: Text(user?.name ?? 'N/A'),
            contentPadding: EdgeInsets.zero,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.email, color: AppTheme.primaryColor),
            title: Text('Email'),
            subtitle: Text(user?.email ?? 'N/A'),
            contentPadding: EdgeInsets.zero,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.card_membership, color: AppTheme.primaryColor),
            title: Text('Code promo'),
            subtitle: Text(user?.promoCode ?? 'N/A'),
            trailing: IconButton(
              icon: Icon(Icons.copy, size: 20),
              onPressed: () => _copyPromoCode(user?.promoCode ?? ''),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            title: Text('Membre depuis'),
            subtitle: Text(user != null ? Formatters.formatDate(user.createdAt) : 'N/A'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final user = Provider.of<AuthProvider>(context).currentUser;
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
            'Mes Statistiques',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Formations',
                  user?.metadata?['completed_formations_count']?.toString() ?? '0',
                  Icons.school,
                  Colors.purple,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Quiz réussis',
                  user?.passedQuizzes.toString() ?? '0',
                  Icons.quiz,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Affiliés',
                  user?.totalAffiliates.toString() ?? '0',
                  Icons.people,
                  AppTheme.accentColor,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Certificats',
                  '0', // Missing from user model
                  Icons.workspace_premium,
                  Colors.orange,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            'Mes Formations',
            Icons.school,
            AppTheme.primaryColor,
            () => Navigator.pushNamed(context, '/my-formations'),
          ),
          Divider(height: 1),
          _buildMenuItem(
            'Mes Certificats',
            Icons.workspace_premium,
            Colors.orange,
            () => _showCertificates(),
          ),
          Divider(height: 1),
          _buildMenuItem(
            'Historique des transactions',
            Icons.history,
            AppTheme.secondaryColor,
            () => Navigator.pushNamed(context, '/transactions'),
          ),
          Divider(height: 1),
          _buildMenuItem(
            'Programme d\'affiliation',
            Icons.people,
            AppTheme.accentColor,
            () => Navigator.pushNamed(context, '/affiliate'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            'Paramètres',
            Icons.settings,
            AppTheme.textSecondary,
            () => _showSettings(),
          ),
          Divider(height: 1),
          _buildMenuItem(
            'Aide & Support',
            Icons.help,
            Colors.blue,
            () => _showSupport(),
          ),
          Divider(height: 1),
          _buildMenuItem(
            'À propos',
            Icons.info,
            Colors.grey,
            () => _showAbout(),
          ),
          Divider(height: 1),
          _buildMenuItem(
            'Déconnexion',
            Icons.logout,
            AppTheme.errorColor,
            () => _handleLogout(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textLight,
      ),
      onTap: onTap,
    );
  }

  void _copyPromoCode(String code) {
    // Copier le code
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code promo copié !'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _showCertificates() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Certificats - Fonctionnalité bientôt disponible'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paramètres - Fonctionnalité bientôt disponible'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showSupport() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Centre d\'aide',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Icon(Icons.email, color: AppTheme.primaryColor),
              title: Text('Email'),
              subtitle: Text('support@formaneo.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: AppTheme.accentColor),
              title: Text('Téléphone'),
              subtitle: Text('+237 691 59 28 82'),
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.green),
              title: Text('WhatsApp'),
              subtitle: Text('Chat instantané'),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('À propos de Formaneo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Formaneo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Votre plateforme d\'apprentissage et de gains',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (Route<dynamic> route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}