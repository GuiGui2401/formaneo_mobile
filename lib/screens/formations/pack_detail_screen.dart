import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/formation_pack.dart';
import '../../models/formation.dart';
import '../../providers/formation_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/ai_assistant/ai_assistant_modal.dart';
import 'formation_player_screen.dart';

class PackDetailScreen extends StatefulWidget {
  final FormationPack pack;

  const PackDetailScreen({Key? key, required this.pack}) : super(key: key);

  @override
  _PackDetailScreenState createState() => _PackDetailScreenState();
}

class _PackDetailScreenState extends State<PackDetailScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackDetails();
  }

  Future<void> _loadPackDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<FormationProvider>(context, listen: false);
      await provider.loadFormationPackDetails(widget.pack.id);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      print('Erreur lors du chargement des détails du pack: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildPackInfo(),
                _buildFormationsGrid(),
                _buildPurchaseSection(),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.pack.isPurchased ? _buildAssistantFAB() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: widget.pack.fullThumbnailUrl != null && widget.pack.fullThumbnailUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.pack.fullThumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: widget.pack.fullThumbnailUrl == null || widget.pack.fullThumbnailUrl!.isEmpty
                ? LinearGradient(
                    colors: _getPackGradientColors(widget.pack.name),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Stack(
            children: [
              // Overlay sombre
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Contenu
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge auteur
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.pack.author,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    // Titre du pack
                    Text(
                      widget.pack.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Stats rapides
                    Row(
                      children: [
                        _buildQuickStat(Icons.star, widget.pack.rating.toString()),
                        SizedBox(width: 16),
                        _buildQuickStat(Icons.people, '${widget.pack.studentsCount}'),
                        SizedBox(width: 16),
                        _buildQuickStat(Icons.video_library, '${widget.pack.formationsCount}'),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge de statut
              if (!widget.pack.isPurchased)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.white.withOpacity(0.8),
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackInfo() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prix et durée
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Durée totale',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      Formatters.formatDuration(widget.pack.totalDuration),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.pack.isPurchased)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Prix',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      Formatters.formatAmount(widget.pack.price),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${widget.pack.completion_percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Avantages du pack
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.accentColor),
                    SizedBox(width: 8),
                    Text(
                      '15% de cashback à chaque formation terminée',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.security, color: AppTheme.accentColor, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Accès à vie • Certificats • Support inclus',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Description du pack
          Text(
            'À propos de ce pack',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.pack.description ?? 'Découvrez ce pack de formations conçu pour tu accompagner dans ton apprentissage. Contenu de qualité, exercices pratiques et support inclus.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 20),
          
          // Statistiques détaillées
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailedStat(
                  Icons.school,
                  '${widget.pack.studentsCount}',
                  'Étudiants',
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildDetailedStat(
                  Icons.star,
                  '${widget.pack.rating}',
                  'Note moyenne',
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildDetailedStat(
                  Icons.access_time,
                  Formatters.formatDuration(widget.pack.totalDuration),
                  'Durée totale',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
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
    );
  }

  Widget _buildFormationsGrid() {
    if (_isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPackDetails,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.pack.formations.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, color: AppTheme.textSecondary, size: 48),
              SizedBox(height: 16),
              Text(
                'Aucune formation disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ce pack ne contient pas encore de formations',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formations incluses (${widget.pack.formations.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: widget.pack.formations.length,
            itemBuilder: (context, index) {
              return _buildFormationCard(widget.pack.formations[index], index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormationCard(Formation formation, int number) {
    final isAccessible = widget.pack.isPurchased;
    final progress = (widget.pack.progress != null && widget.pack.progress![formation.id] != null) 
        ? widget.pack.progress![formation.id]! 
        : 0.0;
    final isCompleted = progress >= 100.0;

    return GestureDetector(
      onTap: isAccessible
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormationPlayerScreen(formation: formation),
                ),
              );
            }
          : () => _showLockedDialog(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond ou gradient
              Container(
                decoration: BoxDecoration(
                  image: formation.thumbnailUrl != null && formation.thumbnailUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(formation.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: formation.thumbnailUrl == null || formation.thumbnailUrl!.isEmpty
                      ? LinearGradient(
                          colors: _getFormationGradientColors(formation.title, number),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
              ),
              
              // Overlay sombre
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Contenu
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec numéro ou statut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCompleted 
                                ? AppTheme.accentColor 
                                : (isAccessible 
                                    ? AppTheme.primaryColor 
                                    : Colors.grey),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : Text(
                                    '$number',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        ),
                        if (!isAccessible)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    
                    Spacer(),
                    
                    // Informations de la formation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formation.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle,
                              color: Colors.white.withOpacity(0.8),
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${formation.modules.length} modules',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.8),
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              Formatters.formatDuration(formation.duration),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        
                        // Barre de progression si accessible et en cours
                        if (isAccessible && progress > 0 && !isCompleted) ...[
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                        ],
                        
                        // Badge "Terminé" si complété
                        if (isCompleted) ...[
                          SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Terminé',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseSection() {
    if (widget.pack.isPurchased) {
      return Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.accentColor, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pack acheté avec succès !',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.pack.completedFormationsCount}/${widget.pack.formationsCount} formations terminées',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.pack.formations.isNotEmpty) {
                    // Trouver la première formation non terminée ou la première
                    Formation targetFormation = widget.pack.formations.first;
                    for (Formation formation in widget.pack.formations) {
                      final progress = (widget.pack.progress != null && widget.pack.progress![formation.id] != null) 
                          ? widget.pack.progress![formation.id]! 
                          : 0.0;
                      if (progress < 100.0) {
                        targetFormation = formation;
                        break;
                      }
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormationPlayerScreen(
                          formation: targetFormation,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Continuer l\'apprentissage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _showPurchaseDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Acheter ${Formatters.formatAmount(widget.pack.price)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Paiement 100% sécurisé • Garantie 14 jours',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantFAB() {
    return FloatingActionButton.extended(
      onPressed: _showAssistant,
      backgroundColor: AppTheme.primaryColor,
      icon: Icon(Icons.psychology, color: Colors.white),
      label: Text(
        'Prof IA',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  List<Color> _getFormationGradientColors(String title, int index) {
    final colors = [
      [Colors.blue, Colors.blue.shade300],
      [Colors.green, Colors.green.shade300],
      [Colors.orange, Colors.orange.shade300],
      [Colors.red, Colors.red.shade300],
      [Colors.purple, Colors.purple.shade300],
      [Colors.teal, Colors.teal.shade300],
      [Colors.indigo, Colors.indigo.shade300],
      [Colors.pink, Colors.pink.shade300],
    ];
    
    return colors[index % colors.length];
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock, color: AppTheme.accentColor),
            SizedBox(width: 8),
            Text('Formation verrouillée'),
          ],
        ),
        content: Text(
          'Cette formation fait partie du pack "${widget.pack.name}". Achète le pack complet pour y accéder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPurchaseDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: Text('Acheter le pack'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final canPurchase = walletProvider.balance >= widget.pack.price;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmer l\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pack: ${widget.pack.name}'),
            SizedBox(height: 8),
            Text('Prix: ${Formatters.formatAmount(widget.pack.price)}'),
            SizedBox(height: 8),
            Text('Solde actuel: ${Formatters.formatAmount(walletProvider.balance)}'),
            SizedBox(height: 16),
            if (!canPurchase)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text(
                      'Solde insuffisant',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu obtiendras :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('• ${widget.pack.formationsCount} formations complètes'),
                    Text('• Accès à vie'),
                    Text('• Certificats à la fin'),
                    Text('• 15% de cashback par formation terminée'),
                  ],
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
            onPressed: canPurchase
                ? () {
                    Navigator.pop(context);
                    _processPurchase();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: Text('Acheter avec le solde'),
          ),
        ],
      ),
    );
  }

  void _processPurchase() async {
    Navigator.pop(context);
    
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Traitement de l\'achat...'),
            ],
        ),
      ),
    );
    
    final formationProvider = Provider.of<FormationProvider>(context, listen: false);
    final success = await formationProvider.purchaseFormationPack(widget.pack.id);
    
    Navigator.pop(context); // Fermer le dialogue de chargement
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Pack acheté avec succès !'),
            ],
          ),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Mettre à jour l'état d'achat du pack
      setState(() {
        widget.pack.isPurchased = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erreur lors de l\'achat'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantModal(
        packName: widget.pack.name,
      ),
    );
  }
}