import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formaneo/providers/recent_activity_provider.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/formation_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/affiliate_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/ebook_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/screen_recorder_blocker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquer l'enregistrement d'écran
  await ScreenRecorderBlocker.enableSecureMode();
  
  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(FormaneoApp());
}

class FormaneoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FormationProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AffiliateProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => EbookProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RecentActivityProvider()), // Pour la gestion de l'authentification
      ],
      child: MaterialApp(
        title: 'Formaneo',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}