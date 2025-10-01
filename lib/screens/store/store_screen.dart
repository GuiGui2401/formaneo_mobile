import 'package:flutter/material.dart';
import 'package:formaneo/models/formation_pack.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';
import '../../services/store_service.dart';
import '../../services/formation_service.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../formations/pack_detail_screen.dart';
import '../cart/cart_screen.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  Future<void> _loadStoreData() async {
    await Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

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
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cartProvider.itemCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            ),
          ),
        ],
      ),
      body: productProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : productProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: AppTheme.errorColor),
                      SizedBox(height: 16),
                      Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        productProvider.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
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
                        _buildFeaturedSection(productProvider.products),
                        _buildProductGrid(productProvider.products),
                        SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
    );
  }

  IconData _getIconForCategory(String categoryId) {
    switch (categoryId) {
      case 'all':
        return Icons.apps;
      case 'formation_pack':
        return Icons.school;
      case 'ebook':
        return Icons.menu_book;
      case 'tool':
        return Icons.build;
      case 'template':
        return Icons.copy_all;
      default:
        return Icons.category;
    }
  }

  Color _getColorForCategory(String categoryId) {
    switch (categoryId) {
      case 'formation_pack':
        return Colors.purple;
      case 'ebook':
        return Colors.orange;
      case 'tool':
        return Colors.teal;
      case 'template':
        return Colors.blueGrey;
      default:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
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
          
          return GestureDetector(
            onTap: () {
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
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForCategory(category['id'] as String),
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    size: 24,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
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

  Widget _buildFeaturedSection(List<Product> products) {
    final promotedItems = products.where((product) {
      return product.isOnPromotion &&
          product.promotionPrice != null &&
          product.promotionPrice! > 0;
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

  Widget _buildPromoCarousel(List<Product> promotedItems) {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.9),
      itemCount: promotedItems.length,
      itemBuilder: (context, index) => _buildPromoCard(
        promotedItems[index],
        index,
      ),
    );
  }

  Widget _buildPromoCard(Product product, int index) {
    final originalPrice = product.price;
    final promoPrice = product.promotionPrice ?? product.price;
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
      onTap: () => _showProductDetails(product),
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
                        product.name,
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
                      _getIconForCategory(product.category),
                      color: Colors.white.withOpacity(0.3),
                      size: 35,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.metadata?['formations_count']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      product.category == 'formation_pack' ? 'formations' : '',
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

  Widget _buildProductGrid(List<Product> products) {
    final filteredItems = selectedCategory == 'all'
        ? products
        : products.where((product) => product.category == selectedCategory).toList();

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

  Widget _buildProductCard(Product product) {
    final showPromotion = product.isOnPromotion &&
        product.promotionPrice != null &&
        product.promotionPrice! > 0;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getColorForCategory(product.category).withOpacity(0.1),
                image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (product.imageUrl == null || product.imageUrl!.isEmpty)
                    Center(
                      child: Icon(
                        _getIconForCategory(product.category),
                        size: 40,
                        color: _getColorForCategory(product.category),
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
                          product.metadata?['badge'] ?? 'PROMO',
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        if (product.category == 'formation_pack')
                          Text(
                            '${product.metadata?['formations_count'] ?? 0} formations',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showPromotion) ...[
                          Text(
                            Formatters.formatAmount(product.promotionPrice!),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            Formatters.formatAmount(product.price),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            Formatters.formatAmount(product.price),
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

  void _showProductDetails(Product product) async {
    if (product.category == 'ebook') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Détails Ebook: ${product.name}'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }
    
    if (product.category == 'formation_pack') {
      try {
        final pack = FormationPack(
          id: product.id,
          name: product.name,
          slug: product.slug,
          author: product.metadata?['author'] ?? 'N/A',
          description: product.description,
          thumbnailUrl: product.imageUrl,
          price: product.price,
          promotionPrice: product.promotionPrice,
          isOnPromotion: product.isOnPromotion,
          totalDuration: product.metadata?['total_duration'] ?? 0,
          rating: product.metadata?['rating']?.toDouble() ?? 0.0,
          studentsCount: product.metadata?['students_count'] ?? 0,
          formationsCount: product.metadata?['formations_count'] ?? 0,
          isFeatured: product.metadata?['is_featured'] ?? false,
          isActive: product.isActive,
          order: product.metadata?['order'] ?? 0,
          createdAt: product.createdAt,
          updatedAt: product.updatedAt,
          formations: [],
          isPurchased: false,
        );
        
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
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails Produit: ${product.name} (Catégorie: ${product.category})'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}