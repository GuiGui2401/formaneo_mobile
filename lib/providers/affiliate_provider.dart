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
      earnings: json['earnings'] is Map<String, dynamic> ? json['earnings'] : {},
      stats: json['stats'] is Map<String, dynamic> ? json['stats'] : {},
      affiliateLink: json['affiliate_link'] as String? ?? '',
      promoCode: json['promo_code'] as String? ?? '',
      affiliatesList: json['affiliates_list'] is List ? json['affiliates_list'] : [],
    );
  }
}

class DetailedStatsData {
  final List<dynamic> topPerformers;
  final Map<String, dynamic> chartData;

  DetailedStatsData({required this.topPerformers, required this.chartData});

  factory DetailedStatsData.fromJson(Map<String, dynamic> json) {
    return DetailedStatsData(
      topPerformers: json['top_performers'] as List? ?? [],
      chartData: json['chart_data'] is Map<String, dynamic> ? json['chart_data'] : {},
    );
  }
}

class AffiliateProvider extends ChangeNotifier {
  AffiliateData? _affiliateData;
  DetailedStatsData? _detailedStats;
  bool _isLoading = false;
  String? _error;

  // Getters for main data
  AffiliateData? get affiliateData => _affiliateData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for detailed stats
  DetailedStatsData? get detailedStats => _detailedStats;

  // Getters for individual properties with default values
  Map<String, dynamic> get earnings => _affiliateData?.earnings ?? {};
  Map<String, dynamic> get stats => _affiliateData?.stats ?? {};
  String get affiliateLink => _affiliateData?.affiliateLink ?? '';
  String get promoCode => _affiliateData?.promoCode ?? '';

  Future<void> loadAffiliateData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch dashboard and detailed stats in parallel for efficiency
      final results = await Future.wait([
        AffiliateService.getDashboardData(),
        AffiliateService.getDetailedStats(),
      ]);

      _affiliateData = AffiliateData.fromJson(results[0] as Map<String, dynamic>);
      _detailedStats = DetailedStatsData.fromJson(results[1] as Map<String, dynamic>);

    } catch (e) {
      _error = e.toString();
      _affiliateData = null;
      _detailedStats = null;
      print('Erreur lors du chargement des données d\'affiliation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
