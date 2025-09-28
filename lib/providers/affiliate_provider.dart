import 'package:flutter/foundation.dart';
import '../services/affiliate_service.dart';

class AffiliateData {
  final Map<String, dynamic> earnings;
  final Map<String, dynamic> stats;
  final String affiliateLink;
  final String promoCode;
  final List<dynamic> affiliatesList;

  AffiliateData({
    required this.earnings,
    required this.stats,
    required this.affiliateLink,
    required this.promoCode,
    required this.affiliatesList,
  });

  factory AffiliateData.fromJson(Map<String, dynamic> json) {
    return AffiliateData(
      earnings: json['earnings'] is Map<String, dynamic>
          ? json['earnings']
          : {},
      stats: json['stats'] is Map<String, dynamic> ? json['stats'] : {},
      affiliateLink: json['affiliate_link'] is String
          ? json['affiliate_link']
          : '',
      promoCode: json['promo_code'] is String ? json['promo_code'] : '',
      affiliatesList: json['affiliates_list'] is List
          ? json['affiliates_list']
          : [],
    );
  }
}

class AffiliateProvider extends ChangeNotifier {
  AffiliateData? _affiliateData;
  bool _isLoading = false;
  String? _error;

  AffiliateData? get affiliateData => _affiliateData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters pour les propriétés individuelles avec valeurs par défaut
  Map<String, dynamic> get earnings => _affiliateData?.earnings ?? {};
  Map<String, dynamic> get stats => _affiliateData?.stats ?? {};
  String get affiliateLink => _affiliateData?.affiliateLink ?? '';
  String get promoCode => _affiliateData?.promoCode ?? '';

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AffiliateService.getDashboardData();
      _affiliateData = AffiliateData.fromJson(data);
    } catch (e) {
      _error = e.toString();
      _affiliateData = null; // Réinitialiser les données en cas d'erreur
      print('Erreur lors du chargement des données d\'affiliation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAffiliateData() async {
    await loadDashboardData();
  }

  Future<void> loadAffiliates({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AffiliateService.getAffiliates(
        page: page,
        limit: limit,
      );
      // Mettre à jour les données des affiliés si nécessaire
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des affiliés: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCommissions({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AffiliateService.getCommissions(
        page: page,
        limit: limit,
      );
      // Mettre à jour les données des commissions si nécessaire
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des commissions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetailedStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AffiliateService.getDetailedStats();
      // Mettre à jour les statistiques détaillées si nécessaire
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des statistiques détaillées: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> generateAffiliateLink({String? campaign}) async {
    try {
      final data = await AffiliateService.generateLink(campaign: campaign);
      return data['link'];
    } catch (e) {
      _error = e.toString();
      print('Erreur lors de la génération du lien d\'affiliation: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getBanners() async {
    try {
      final data = await AffiliateService.getBanners();
      return data['banners'];
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du chargement des bannières: $e');
      return null;
    }
  }

  Future<String?> downloadBanner(String id) async {
    try {
      final data = await AffiliateService.downloadBanner(id);
      return data['download_url'];
    } catch (e) {
      _error = e.toString();
      print('Erreur lors du téléchargement de la bannière: $e');
      return null;
    }
  }
}
