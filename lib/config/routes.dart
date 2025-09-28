import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/formations/formation_packs_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/affiliate/affiliate_dashboard.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/store/store_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/ebooks/ebooks_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String home = '/home';
  static const String formations = '/formations';
  static const String quiz = '/quiz';
  static const String affiliate = '/affiliate';
  static const String wallet = '/wallet';
  static const String store = '/store';
  static const String profile = '/profile';
  static const String ebooks = '/ebooks';
  static const String transactions = '/transactions';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => LoginScreen(),
      signup: (context) => SignupScreen(),
      main: (context) => MainScreen(),
      home: (context) => HomeScreen(),
      formations: (context) => FormationPacksScreen(),
      quiz: (context) => QuizScreen(),
      affiliate: (context) => AffiliateDashboard(),
      wallet: (context) => WalletScreen(),
      store: (context) => StoreScreen(),
      profile: (context) => ProfileScreen(),
      ebooks: (context) => EbooksScreen(),
    };
  }
}