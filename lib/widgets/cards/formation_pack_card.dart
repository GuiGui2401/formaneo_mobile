import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/formation_pack.dart';

class FormationPackCard extends StatelessWidget {
  final FormationPack pack;
  final VoidCallback onTap;
  final bool showPrice;
  final bool isCompact;

  const FormationPackCard({
    Key? key,
    required this.pack,
    required this.onTap,
    this.showPrice = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: isCompact ? _buildCompactCard() : _buildFullCard(),
      ),
    );
  }

  Widget _buildFullCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(),
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: AppSpacing.sm),
              _buildDescription(),
              SizedBox(height: AppSpacing.md),
              _buildFooter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            child: Image.network(
              pack.thumbnailUrl ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.play_circle_fill, color: AppTheme.primaryColor),
                );
              },
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  pack.author,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '${(pack.totalDuration / 60).toStringAsFixed(0)}h',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    SizedBox(width: AppSpacing.md),
                    if (showPrice)
                      Text(
                        '${pack.price.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
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

  Widget _buildThumbnail() {
    return Stack(
      children: [
        Image.network(
          pack.thumbnailUrl ?? '',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
            );
          },
        ),
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              '${(pack.totalDuration / 60).toStringAsFixed(0)}h',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (pack.isPurchased)
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Text(
                'Acheté',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            pack.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Text(
            pack.author,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      pack.description ?? '',
      style: TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber, size: 16),
        SizedBox(width: 4),
        Text(
          pack.rating.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Icon(Icons.people, color: AppTheme.textSecondary, size: 16),
        SizedBox(width: 4),
        Text(
          '${pack.studentsCount}',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        Spacer(),
        if (showPrice)
          Text(
            '${pack.price.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
      ],
    );
  }
}