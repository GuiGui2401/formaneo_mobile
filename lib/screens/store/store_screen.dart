import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../services/store_service.dart';
import '../../services/formation_service.dart';
import '../../models/formation_pack.dart';
import '../formations/pack_detail_screen.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String selectedCategory = 'all';
  List<Map<String, dynamic>> storeItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final items = await StoreService.getStoreItems();
      
      // Debug logs
      print('📦 Total items loaded: ${items.length}');
      for (var item in items) {
        print('Item: ${item['name']} - Price: ${item['price']} - Original: ${item['original_price']} - Promo: ${item['is_on_promotion']}');
      }
      
      setState(() {
        storeItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading store data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Boutique'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
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
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: _showCart,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: AppTheme.errorColor),
                      SizedBox(height: 16),
                      Text('Erreur de chargement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(errorMessage!, textAlign: TextAlign.center),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStoreData,
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStoreData,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildCategories(),
                        _buildFeaturedSection(),
                        _buildProductGrid(),
                        SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'apps':
        return Icons.apps;
      case 'school':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      case 'menu_book':
        return Icons.menu_book;
      case 'build':
        return Icons.build;
      default:
        return Icons.category;
    }
  }

  Color _getColorForItem(String colorName) {
    switch (colorName) {
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getIconForItem(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'quiz':
        return Icons.quiz;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Boutique Formaneo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Formations, Quiz, Outils et plus encore',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
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
              children: [
                Icon(Icons.local_offer, color: Colors.white, size: 16),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Promo: -20% sur tous les packs ce mois',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

  Widget _buildCategories() {
    final categories = StoreService.getCategories();

    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];
          final isLocked = category['locked'] == true;
          
          return GestureDetector(
            onTap: isLocked ? null : () {
              setState(() {
                selectedCategory = category['id'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: AppSpacing.md),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isLocked 
                    ? Colors.grey[100]
                    : (isSelected ? AppTheme.primaryColor : Colors.white),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(
                  color: isLocked 
                      ? Colors.grey[300]!
                      : (isSelected ? AppTheme.primaryColor : Color(0xFFE2E8F0)),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForCategory(category['icon'] as String),
                        color: isLocked 
                            ? Colors.grey[400]
                            : (isSelected ? Colors.white : AppTheme.textSecondary),
                        size: 24,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          color: isLocked 
                              ? Colors.grey[500]
                              : (isSelected ? Colors.white : AppTheme.textSecondary),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (isLocked)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    // Find only items with active promotion
    final promotedItems = storeItems.where((item) {
      final isOnPromotion = item['is_on_promotion'] == true;
      final hasPromoPrice = item['promotion_price'] != null && item['promotion_price'] > 0;
      return isOnPromotion && hasPromoPrice;
    }).toList();

    print('🎯 Found ${promotedItems.length} items with active promotions');

    if (promotedItems.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promotions en cours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _buildPromoCarousel(promotedItems),
          ),
        ],
      ),
    );
  }


  Widget _buildPromoCarousel(List<Map<String, dynamic>> promotedItems) {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.9),
      itemCount: promotedItems.length,
      itemBuilder: (context, index) => _buildPromoCard(promotedItems[index], index),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> item, int index) {
    final originalPrice = (item['original_price'] ?? 0.0).toDouble();
    final promoPrice = (item['promotion_price'] ?? 0.0).toDouble();
    final discount = originalPrice > 0 
        ? (((originalPrice - promoPrice) / originalPrice) * 100).round()
        : 0;
    
    final gradientColors = [
      [Colors.purple, Colors.purple.withOpacity(0.8)],
      [Colors.orange, Colors.orange.withOpacity(0.8)],
      [Colors.teal, Colors.teal.withOpacity(0.8)],
      [Colors.pink, Colors.pink.withOpacity(0.8)],
    ];
    
    return GestureDetector(
      onTap: () => _navigateToPackDetail(item),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors[index % gradientColors.length],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discount%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              Formatters.formatAmount(promoPrice),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              Formatters.formatAmount(originalPrice),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school,
                      color: Colors.white.withOpacity(0.3),
                      size: 35,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${item['formations_count'] ?? 0}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'formations',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildProductGrid() {
    final filteredItems = selectedCategory == 'all'
        ? storeItems
        : storeItems.where((item) => item['category'] == selectedCategory).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produits disponibles',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return _buildProductCard(filteredItems[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final isOnPromotion = item['is_on_promotion'] == true;
    final hasPromoPrice = item['promotion_price'] != null && item['promotion_price'] > 0;
    final showPromotion = isOnPromotion && hasPromoPrice;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showProductDetails(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec image/icône
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.school,
                      size: 40,
                      color: Colors.purple,
                    ),
                  ),
                  if (showPromotion)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['badge'] ?? 'PROMO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom et description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${item['formations_count'] ?? 0} formations',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Prix
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showPromotion) ...[
                          Text(
                            Formatters.formatAmount((item['promotion_price'] ?? 0.0).toDouble()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            Formatters.formatAmount((item['original_price'] ?? 0.0).toDouble()),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            Formatters.formatAmount((item['price'] ?? 0.0).toDouble()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                      ],
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

  void _showProductDetails(Map<String, dynamic> item) {
    if (item['category'] == 'ebooks') {
      Navigator.pushNamed(context, '/ebooks');
      return;
    }
    
    // Naviguer vers la page de détail du pack
    _navigateToPackDetail(item);
  }
  
  void _navigateToPackDetail(Map<String, dynamic> item) async {
    try {
      // Obtenir les détails complets du pack depuis l'API
      final packDetails = await StoreService.getPackDetails(item['id'].toString());
      
      // Créer un objet FormationPack à partir des données
      final pack = FormationPack.fromJson(packDetails);
      
      // Naviguer vers l'écran de détail
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackDetailScreen(pack: pack),
          ),
        );
      }
    } catch (e) {
      print('❌ Error navigating to pack detail: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des détails du pack'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _addToCart(Map<String, dynamic> item) async {
    try {
      final response = await FormationService.purchaseFormationPack(item['id']);
      
      if (!mounted) return;
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['name']} acheté avec succès!'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erreur lors de l\'achat'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'achat: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Panier en cours de développement'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}