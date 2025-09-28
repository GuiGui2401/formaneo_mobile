import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/formation_provider.dart';
import '../../models/formation_pack.dart';
import '../../models/formation.dart';
import '../../utils/formatters.dart';
import 'pack_detail_screen.dart';

class FormationPacksScreen extends StatefulWidget {
  @override
  _FormationPacksScreenState createState() => _FormationPacksScreenState();
}

class _FormationPacksScreenState extends State<FormationPacksScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadPacks();
  }
  
  Future<void> _loadPacks() async {
    setState(() => _isLoading = true);
    
    final provider = Provider.of<FormationProvider>(context, listen: false);
    await provider.loadFormationPacks();
    
    // Vérifier s'il y a une erreur
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des packs: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _handleRefresh() async {
    await _loadPacks();
  }

  List<FormationPack> _getFilteredPacks(List<FormationPack> packs) {
    return packs.where((pack) {
      final matchesSearch = _searchQuery.isEmpty ||
          pack.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pack.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (pack.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final formationProvider = Provider.of<FormationProvider>(context);
    final filteredPacks = _getFilteredPacks(formationProvider.formationPacks);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar moderne avec dégradé
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Packs de Formations',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                      AppTheme.accentColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Motif décoratif
                    Positioned(
                      right: -80,
                      top: -80,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -40,
                      bottom: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Contenu
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school, color: Colors.white, size: 32),
                              SizedBox(width: 16),
                              Text(
                                'Formations Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Accédez à des packs complets avec 15% de cashback',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Barre de recherche
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Rechercher un pack de formation...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _isLoading
                  ? Container(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : filteredPacks.isEmpty && _searchQuery.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            _buildBenefitsSection(),
                            _buildPacksList(filteredPacks),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats rapides
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.school,
                  title: 'Formations',
                  subtitle: 'Professionnelles',
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.monetization_on,
                  title: '15%',
                  subtitle: 'Cashback',
                  color: AppTheme.accentColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.security,
                  title: 'Sécurisé',
                  subtitle: '100%',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final formationProvider = Provider.of<FormationProvider>(context);
    
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'Aucun pack trouvé'
                  : 'Aucun pack disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Essayez avec d\'autres mots-clés'
                  : formationProvider.error != null
                      ? 'Erreur: \\${formationProvider.error}'
                      : 'Les packs de formations seront bientôt disponibles',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPacks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('Actualiser'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPacksList(List<FormationPack> packs) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nos packs disponibles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: packs.length,
            itemBuilder: (context, index) {
              return _buildPackCard(packs[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(FormationPack pack) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackDetailScreen(pack: pack),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec image/gradient
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: pack.fullThumbnailUrl != null && pack.fullThumbnailUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(pack.fullThumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: pack.fullThumbnailUrl == null || pack.fullThumbnailUrl!.isEmpty
                          ? LinearGradient(
                              colors: _getPackGradientColors(pack.name),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Par ${pack.author}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              pack.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Badge de statut
                  if (pack.isPurchased)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Acheté',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  else if (pack.isFeatured)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Populaire',
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
              
              // Contenu de la carte
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    if (pack.description != null && pack.description!.isNotEmpty)
                      Text(
                        pack.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    SizedBox(height: 16),
                    
                    // Statistiques
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.star,
                          pack.rating.toString(),
                          Colors.amber,
                        ),
                        SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.people,
                          '${pack.studentsCount}',
                          AppTheme.primaryColor,
                        ),
                        SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.video_library,
                          '${pack.formationsCount} formations',
                          AppTheme.accentColor,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.access_time,
                          Formatters.formatDuration(pack.totalDuration),
                          Colors.blue,
                        ),
                        Spacer(),
                        // Prix ou progression
                        if (!pack.isPurchased)
                          Text(
                            Formatters.formatAmount(pack.price),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    value: pack.completion_percentage / 100,
                                    strokeWidth: 2,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${pack.completion_percentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    // Barre de progression pour les packs achetés
                    if (pack.isPurchased) ...[
                      SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: pack.completion_percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '${pack.completedFormationsCount}/${pack.formationsCount} formations complétées',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getPackGradientColors(String packName) {
    if (packName.toLowerCase().contains('dropskills')) {
      return [Colors.purple, Colors.purple.withOpacity(0.7)];
    } else if (packName.toLowerCase().contains('business')) {
      return [Colors.orange, Colors.orange.withOpacity(0.7)];
    } else if (packName.toLowerCase().contains('marketing')) {
      return [Colors.blue, Colors.blue.withOpacity(0.7)];
    } else {
      return [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)];
    }
  }
}