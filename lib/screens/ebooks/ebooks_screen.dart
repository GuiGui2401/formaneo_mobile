import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinetpay/cinetpay.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/ebook.dart';
import '../../providers/ebook_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/formatters.dart';
import 'pdf_viewer_screen.dart';

class EbooksScreen extends StatefulWidget {
  @override
  _EbooksScreenState createState() => _EbooksScreenState();
}

class _EbooksScreenState extends State<EbooksScreen> {
  String selectedCategory = 'all';
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEbooks();
    });
  }

  Future<void> _loadEbooks() async {
    final provider = Provider.of<EbookProvider>(context, listen: false);
    setState(() => _isLoading = true);
    await provider.loadEbooks();
    setState(() => _isLoading = false);
  }

  Future<void> _handleRefresh() async {
    await _loadEbooks();
  }

  List<Ebook> _getFilteredEbooks(List<Ebook> ebooks) {
    return ebooks.where((ebook) {
      final matchesSearch = _searchQuery.isEmpty ||
          ebook.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (ebook.author?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesCategory = selectedCategory == 'all' ||
          ebook.category == selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ebookProvider = Provider.of<EbookProvider>(context);
    final filteredEbooks = _getFilteredEbooks(ebookProvider.ebooks);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar avec recherche
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Bibliothèque',
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
                      AppTheme.primaryColor.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                      hintText: 'Rechercher un livre...',
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
                  : ebookProvider.ebooks.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            // Filtres de catégorie
                            _buildCategoryFilter(ebookProvider.ebooks),
                            // Grille des livres
                            _buildEbookGrid(filteredEbooks),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(List<Ebook> ebooks) {
    final categories = ['all'] + 
        ebooks.map((e) => e.category).where((c) => c != null).cast<String>().toSet().toList();

    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Container(
            margin: EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category == 'all' ? 'Tous' : category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'Aucun livre trouvé'
                  : 'Aucun ebook disponible',
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
                  : 'Revenez plus tard pour découvrir nos ebooks',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadEbooks,
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

  Widget _buildEbookGrid(List<Ebook> ebooks) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6, // Plus grand pour ressembler aux vraies couvertures
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        itemCount: ebooks.length,
        itemBuilder: (context, index) {
          return _buildBookCard(ebooks[index]);
        },
      ),
    );
  }

  Widget _buildBookCard(Ebook ebook) {
    return GestureDetector(
      onTap: () => _showEbookDetails(ebook),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Couverture du livre (style moderne)
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image de couverture
                      // Image de couverture
                    ebook.fullCoverImageUrl != null
                        ? Image.network(
                            ebook.fullCoverImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderCover(ebook);
                            },
                          )
                        : _buildPlaceholderCover(ebook),
                      
                      // Badge prix (si payant)
                      if (ebook.price != null && ebook.price! > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              Formatters.formatAmount(ebook.price!),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      
                      // Badge gratuit
                      if (ebook.price == null || ebook.price! <= 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'GRATUIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Overlay d'interaction
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showEbookDetails(ebook),
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Informations du livre
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ebook.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (ebook.author != null)
                    Text(
                      ebook.author!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  // Rating et pages
                  if (ebook.rating != null || ebook.pages != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (ebook.rating != null) ...[
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 2),
                            Text(
                              ebook.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                          if (ebook.rating != null && ebook.pages != null)
                            Text(' • ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          if (ebook.pages != null)
                            Text(
                              '${ebook.pages}p',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(Ebook ebook) {
    // Générateur de couleur basé sur le titre pour cohérence
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final color = colors[ebook.title.hashCode % colors.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.menu_book,
              size: 40,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Text(
              ebook.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showEbookDetails(Ebook ebook) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle pour fermer
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec image et infos principales
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Couverture
                        Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ebook.coverImageUrl != null
                                ? Image.network(
                                    ebook.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderCover(ebook);
                                    },
                                  )
                                : _buildPlaceholderCover(ebook),
                          ),
                        ),
                        
                        SizedBox(width: 16),
                        
                        // Informations
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ebook.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8),
                              if (ebook.author != null)
                                Text(
                                  'Par ${ebook.author}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              SizedBox(height: 16),
                              
                              // Stats rapides
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  if (ebook.rating != null)
                                    _buildStatChip(Icons.star, '${ebook.rating!.toStringAsFixed(1)}', Colors.amber),
                                  if (ebook.pages != null)
                                    _buildStatChip(Icons.description, '${ebook.pages} pages', Colors.blue),
                                  if (ebook.downloads != null)
                                    _buildStatChip(Icons.download, '${ebook.downloads}', Colors.green),
                                  if (ebook.category != null)
                                    _buildStatChip(Icons.category, ebook.category!, Colors.purple),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Prix
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prix',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (ebook.price != null && ebook.price! > 0)
                            Text(
                              Formatters.formatAmount(ebook.price!),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                            )
                          else
                            Text(
                              'Gratuit',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Description
                    if (ebook.description != null) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        ebook.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                    
                    // Bouton d'action
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _purchaseDownloadOrViewEbook(ebook);
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
                            Icon(
                              ebook.price != null && ebook.price! > 0
                                  ? (ebook.isPurchased ? Icons.visibility : Icons.shopping_cart)
                                  : Icons.download,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              ebook.price != null && ebook.price! > 0
                                  ? (ebook.isPurchased ? 'Consulter en ligne' : 'Acheter')
                                  : 'Télécharger gratuitement',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseDownloadOrViewEbook(Ebook ebook) async {
    final provider = Provider.of<EbookProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Si l'ebook est gratuit, le télécharger directement
    if (ebook.price == null || ebook.price! <= 0) {
      _downloadEbook(ebook);
      return;
    }
    
    // Si l'ebook a déjà été acheté, le consulter en ligne
    if (ebook.isPurchased) {
      _viewEbook(ebook);
      return;
    }
    
    // Sinon, procéder à l'achat
    // Vérifier le solde de l'utilisateur
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final canPurchase = walletProvider.balance >= ebook.price!;
    
    if (!canPurchase) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solde insuffisant pour acheter cet ebook'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Afficher une boîte de dialogue pour confirmer l'achat avec le solde
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmation d\'achat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous vraiment acheter "${ebook.title}" pour ${Formatters.formatAmount(ebook.price!)} en utilisant votre solde ?'),
            SizedBox(height: 16),
            if (ebook.coverImageUrl != null)
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ebook.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderCover(ebook);
                    },
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text('Acheter avec le solde'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await provider.purchaseEbook(ebook.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Ebook acheté avec succès !'),
              ],
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Erreur lors de l\'achat de l\'ebook'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _downloadEbook(Ebook ebook) async {
    final provider = Provider.of<EbookProvider>(context, listen: false);
    
    final success = await provider.downloadEbook(ebook.id);
    if (success) {
      // Au lieu d'ouvrir dans le navigateur, on ouvre dans l'application
      if (ebook.pdfUrl != null && ebook.pdfUrl!.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              title: ebook.title,
              pdfUrl: ebook.pdfUrl!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Ebook téléchargé avec succès !'),
              ],
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erreur lors du téléchargement de l\'ebook'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  
  void _viewEbook(Ebook ebook) async {
    // Vérifier si l'ebook a une URL PDF
    if (ebook.pdfUrl == null || ebook.pdfUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Lien PDF non disponible pour cet ebook'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    // Naviguer vers l'écran de visualisation PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          title: ebook.title,
          pdfUrl: ebook.pdfUrl!,
        ),
      ),
    );
  }
}