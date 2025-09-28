import 'package:flutter/material.dart';
import 'package:formaneo/models/formation.dart';
import 'package:provider/provider.dart';
import '../../models/formation_pack.dart';
import '../../config/theme.dart';
import '../../providers/formation_provider.dart';
import '../../utils/formatters.dart';
import 'formation_player_screen.dart';

class FormationListScreen extends StatefulWidget {
  final String packId;

  const FormationListScreen({Key? key, required this.packId}) : super(key: key);

  @override
  _FormationListScreenState createState() => _FormationListScreenState();
}

class _FormationListScreenState extends State<FormationListScreen> {
  String searchQuery = '';
  String selectedFilter = 'Toutes';
  FormationPack? currentPack;

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  void _loadFormations() {
    final provider = Provider.of<FormationProvider>(context, listen: false);
    currentPack = provider.formationPacks.firstWhere(
      (pack) => pack.id == widget.packId,
      orElse: () => provider.formationPacks.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: currentPack == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                _buildPackInfo(),
                _buildFilterChips(),
                Expanded(
                  child: _buildFormationsList(),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Formations'),
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: _showSortOptions,
          icon: Icon(Icons.sort),
        ),
        IconButton(
          onPressed: _showFilterOptions,
          icon: Icon(Icons.filter_list),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      color: Colors.white,
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher une formation...',
          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          filled: true,
          fillColor: AppTheme.backgroundColor,
        ),
      ),
    );
  }

  Widget _buildPackInfo() {
    if (currentPack == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPack!.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Par ${currentPack!.author}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  '${currentPack!.formations.length} formations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                Formatters.formatDuration(currentPack!.totalDuration),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(width: AppSpacing.md),
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                currentPack!.rating.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(width: AppSpacing.md),
              Icon(Icons.people, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                '${currentPack!.studentsCount} étudiants',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          if (currentPack!.isPurchased) ...[
            SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: currentPack!.completionPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Progression: ${currentPack!.completionPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Toutes', 'En cours', 'Complétées', 'Non commencées'];
    
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Container(
            margin: EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormationsList() {
    if (currentPack == null) return SizedBox.shrink();

    final filteredFormations = _getFilteredFormations();

    if (filteredFormations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: AppSpacing.md),
            Text(
              'Aucune formation trouvée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Essayez de modifier vos critères de recherche',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: filteredFormations.length,
      itemBuilder: (context, index) {
        return _buildFormationCard(filteredFormations[index], index + 1);
      },
    );
  }

  Widget _buildFormationCard(Formation formation, int number) {
    final progress = currentPack!.progress![formation.id] ?? 0.0;
    final isCompleted = progress >= 100.0;
    final isStarted = progress > 0.0;
    final isAccessible = currentPack!.isPurchased;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isAccessible
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormationPlayerScreen(formation: formation),
                  ),
                );
              }
            : _showPurchaseDialog,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.accentColor
                            : isStarted
                                ? AppTheme.primaryColor
                                : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                '$number',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Text(
                        Formatters.formatDuration(formation.duration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isAccessible ? Icons.play_circle_fill : Icons.lock,
                          color: Colors.white.withOpacity(0.9),
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          formation.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formation.description ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(Icons.video_library, size: 16, color: AppTheme.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        '${formation.modules.length} modules',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Spacer(),
                      if (isCompleted)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                          ),
                          child: Text(
                            'Complété',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else if (isStarted)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                          ),
                          child: Text(
                            'En cours',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else if (!isAccessible)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                          ),
                          child: Text(
                            'Verrouillé',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isAccessible && progress > 0) ...[
                    SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppTheme.accentColor : AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${progress.toStringAsFixed(0)}% terminé',
                      style: TextStyle(
                        fontSize: 10,
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
    );
  }

  List<Formation> _getFilteredFormations() {
    if (currentPack == null) return [];

    List<Formation> formations = currentPack!.formations;

    // Filtrer par recherche
    if (searchQuery.isNotEmpty) {
      formations = formations.where((formation) {
        return formation.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               formation.description!.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrer par statut
    switch (selectedFilter) {
      case 'En cours':
        formations = formations.where((formation) {
          final progress = currentPack!.progress![formation.id] ?? 0.0;
          return progress > 0.0 && progress < 100.0;
        }).toList();
        break;
      case 'Complétées':
        formations = formations.where((formation) {
          final progress = currentPack!.progress![formation.id] ?? 0.0;
          return progress >= 100.0;
        }).toList();
        break;
      case 'Non commencées':
        formations = formations.where((formation) {
          final progress = currentPack!.progress![formation.id] ?? 0.0;
          return progress == 0.0;
        }).toList();
        break;
    }

    return formations;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trier par',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Icon(Icons.sort_by_alpha),
              title: Text('Ordre alphabétique'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentPack!.formations.sort((a, b) => a.title.compareTo(b.title));
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Durée (croissante)'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentPack!.formations.sort((a, b) => a.duration.compareTo(b.duration));
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Progression'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  currentPack!.formations.sort((a, b) {
                    final progressA = currentPack!.progress![a.id] ?? 0.0;
                    final progressB = currentPack!.progress![b.id] ?? 0.0;
                    return progressB.compareTo(progressA);
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Options de filtrage',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Vous pouvez filtrer les formations en utilisant les puces ci-dessus ou en utilisant la barre de recherche.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedFilter = 'Toutes';
                  searchQuery = '';
                });
                Navigator.pop(context);
              },
              child: Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pack non acheté'),
        content: Text(
          'Vous devez acheter ce pack pour accéder aux formations. '
          'Voulez-vous retourner à la page du pack ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Voir le pack'),
          ),
        ],
      ),
    );
  }
}