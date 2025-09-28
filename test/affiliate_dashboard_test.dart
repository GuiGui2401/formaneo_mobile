import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/screens/affiliate/affiliate_dashboard.dart';
import '../lib/providers/affiliate_provider.dart';
import '../lib/providers/wallet_provider.dart';

// Generate mocks
@GenerateMocks([AffiliateProvider, WalletProvider])
import 'affiliate_dashboard_test.mocks.dart';

void main() {
  group('Affiliate Dashboard Tests', () {
    late MockAffiliateProvider mockAffiliateProvider;
    late MockWalletProvider mockWalletProvider;

    setUp(() {
      mockAffiliateProvider = MockAffiliateProvider();
      mockWalletProvider = MockWalletProvider();
    });

    testWidgets('Affiliate dashboard renders without errors', (WidgetTester tester) async {
      // Mock the provider data
      when(mockAffiliateProvider.earnings).thenReturn({
        'today': 5000.0,
        'yesterday': 4500.0,
        'currentMonth': 150000.0,
        'lastMonth': 120000.0,
        'total': 500000.0,
      });
      
      when(mockAffiliateProvider.stats).thenReturn({
        'totalAffiliates': 45,
        'monthlyAffiliates': 12,
      });
      
      when(mockAffiliateProvider.affiliateLink).thenReturn('http://cleanestuaire.com/invite/ABC123');
      when(mockAffiliateProvider.promoCode).thenReturn('AB123');
      
      when(mockWalletProvider.balance).thenReturn(25000.0);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AffiliateProvider>.value(value: mockAffiliateProvider),
              ChangeNotifierProvider<WalletProvider>.value(value: mockWalletProvider),
            ],
            child: AffiliateDashboard(),
          ),
        ),
      );

      // Check that the app bar is rendered
      expect(find.text('Affiliation'), findsOneWidget);
      
      // Check that key elements are present
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}