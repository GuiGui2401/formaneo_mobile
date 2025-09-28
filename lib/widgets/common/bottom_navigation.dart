import 'package:flutter/material.dart';
import '../../config/theme.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textLight,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, 0),
              activeIcon: _buildNavIcon(Icons.home, 0, isActive: true),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.account_balance_wallet_outlined, 1),
              activeIcon: _buildNavIcon(Icons.account_balance_wallet, 1, isActive: true),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.shopping_bag_outlined, 2),
              activeIcon: _buildNavIcon(Icons.shopping_bag, 2, isActive: true),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, 3),
              activeIcon: _buildNavIcon(Icons.person, 3, isActive: true),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive && currentIndex == index 
            ? AppTheme.primaryColor.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isActive && currentIndex == index 
            ? AppTheme.primaryColor 
            : AppTheme.textLight,
      ),
    );
  }
}