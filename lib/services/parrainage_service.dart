import 'dart:math';
import '../models/affiliate.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ParrainageService {
  static const double LEVEL_1_COMMISSION = 1000.0; // FCFA pour filleul direct
  static const double LEVEL_2_COMMISSION = 500.0; // FCFA pour sous-filleul
  static const String BASE_REFERRAL_URL = 'http://cleanestuaire.com/invite/';

  // Obtenir les statistiques de parrainage
  static Future<ParrainageStats> getParrainageStats() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw ParrainageException('Utilisateur non connecté');
      }

      await Future.delayed(Duration(milliseconds: 500)); // Simulation réseau

      // Simulation de données de parrainage
      return ParrainageStats(
        directReferrals: 20,
        indirectReferrals: 43,
        totalReferrals: 66,
        todayEarnings: 2500.0,
        yesterdayEarnings: 11878.0,
        currentMonthEarnings: 51660.0,
        lastMonthEarnings: 31700.0,
        totalEarnings: 115566.0,
        referralsWithPurchase: 20,
        referralsWithoutPurchase: 43,
        level2ReferralsWithDeposit: 3,
      );
    } catch (e) {
      throw ParrainageException(
        'Erreur lors du chargement des statistiques: ${e.toString()}',
      );
    }
  }

  // Obtenir la liste des filleuls
  static Future<List<Parrainage>> getFilleuls() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw ParrainageException('Utilisateur non connecté');
      }

      await Future.delayed(Duration(milliseconds: 800));

      // Simulation de données de filleuls
      return [
        Parrainage(
          id: '1',
          parrainId: currentUser.id,
          filleulId: 'filleul_1',
          parrainName: currentUser.name,
          filleulName: 'Marie Koné',
          filleulEmail: 'marie.kone@email.com',
          dateInscription: DateTime.now().subtract(Duration(days: 15)),
          hasFirstPurchase: true,
          firstPurchaseDate: DateTime.now().subtract(Duration(days: 10)),
          commissionEarned: 1000.0,
          level: ParrainageLevel.direct,
          status: ParrainageStatus.active,
        ),
        Parrainage(
          id: '2',
          parrainId: currentUser.id,
          filleulId: 'filleul_2',
          parrainName: currentUser.name,
          filleulName: 'Jean Baptiste',
          filleulEmail: 'jean.baptiste@email.com',
          dateInscription: DateTime.now().subtract(Duration(days: 5)),
          hasFirstPurchase: false,
          commissionEarned: 0.0,
          level: ParrainageLevel.direct,
          status: ParrainageStatus.pending,
        ),
        Parrainage(
          id: '3',
          parrainId: currentUser.id,
          filleulId: 'filleul_3',
          parrainName: currentUser.name,
          filleulName: 'Sophie Laurent',
          filleulEmail: 'sophie.laurent@email.com',
          dateInscription: DateTime.now().subtract(Duration(days: 30)),
          hasFirstPurchase: true,
          firstPurchaseDate: DateTime.now().subtract(Duration(days: 25)),
          commissionEarned: 500.0,
          level: ParrainageLevel.indirect,
          status: ParrainageStatus.active,
        ),
      ];
    } catch (e) {
      throw ParrainageException(
        'Erreur lors du chargement des filleuls: ${e.toString()}',
      );
    }
  }

  // Créer un lien de parrainage
  static ReferralLink createReferralLink(String userId, String referralCode) {
    final link = '$BASE_REFERRAL_URL$referralCode';

    return ReferralLink(
      userId: userId,
      code: referralCode,
      link: link,
      createdAt: DateTime.now(),
    );
  }

  // Valider un code de parrainage
  static Future<bool> validateReferralCode(String code) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));

      // Validation du format
      if (code.length != 5) return false;
      if (!RegExp(r'^[A-Z]{2}\d{3}$').hasMatch(code)) return false;

      // Simulation de vérification en base de données
      // Dans une vraie app, on vérifierait si le code existe
      final validCodes = ['WB001', 'AB123', 'CD456', 'EF789'];
      return validCodes.contains(code);
    } catch (e) {
      return false;
    }
  }

  // Traiter un parrainage (inscription avec code)
  static Future<bool> processReferral({
    required String referralCode,
    required String newUserId,
    required String newUserName,
    required String newUserEmail,
  }) async {
    try {
      await Future.delayed(Duration(seconds: 1));

      // Valider le code
      final isValidCode = await validateReferralCode(referralCode);
      if (!isValidCode) {
        throw ParrainageException('Code de parrainage invalide');
      }

      // Trouver le parrain (simulation)
      final parrainId = await _findParrainByCode(referralCode);
      if (parrainId == null) {
        throw ParrainageException('Parrain introuvable');
      }

      // Créer la relation de parrainage
      final parrainage = Parrainage(
        id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
        parrainId: parrainId,
        filleulId: newUserId,
        parrainName: 'Parrain', // Dans une vraie app, on récupérerait le nom
        filleulName: newUserName,
        filleulEmail: newUserEmail,
        dateInscription: DateTime.now(),
        level: ParrainageLevel.direct,
        status: ParrainageStatus.pending,
      );

      // Sauvegarder la relation (simulation)
      await _saveParrainage(parrainage);

      return true;
    } catch (e) {
      throw ParrainageException(
        'Erreur lors du traitement du parrainage: ${e.toString()}',
      );
    }
  }

  // Traiter le premier achat d'un filleul
  static Future<void> processFirstPurchase({
    required String filleulId,
    required double purchaseAmount,
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));

      // Trouver la relation de parrainage
      final parrainage = await _findParrainageByFilleul(filleulId);
      if (parrainage == null) return;

      // Calculer et attribuer la commission niveau 1
      await _attributeCommission(
        parrainId: parrainage.parrainId,
        amount: LEVEL_1_COMMISSION,
        reason: 'Premier achat de ${parrainage.filleulName}',
      );

      // Vérifier s'il y a un parrain de niveau 2
      final parrainLevel2 = await _findLevel2Parrain(parrainage.parrainId);
      if (parrainLevel2 != null) {
        await _attributeCommission(
          parrainId: parrainLevel2,
          amount: LEVEL_2_COMMISSION,
          reason: 'Achat de sous-filleul ${parrainage.filleulName}',
        );
      }

      // Mettre à jour le statut du parrainage
      await _updateParrainageStatus(parrainage.id, ParrainageStatus.active);
    } catch (e) {
      throw ParrainageException(
        'Erreur lors du traitement de l\'achat: ${e.toString()}',
      );
    }
  }

  // Obtenir le classement des top parrains
  static Future<List<Map<String, dynamic>>> getTopReferrers() async {
    try {
      await Future.delayed(Duration(milliseconds: 600));

      return [
        {
          'rank': 1,
          'name': 'Marie K.',
          'totalEarnings': 45000.0,
          'totalReferrals': 15,
          'isCurrentUser': false,
        },
        {
          'rank': 2,
          'name': 'Jean B.',
          'totalEarnings': 38500.0,
          'totalReferrals': 12,
          'isCurrentUser': false,
        },
        {
          'rank': 3,
          'name': 'Sophie L.',
          'totalEarnings': 32000.0,
          'totalReferrals': 10,
          'isCurrentUser': false,
        },
        {
          'rank': 4,
          'name': 'Vous',
          'totalEarnings': 115566.0,
          'totalReferrals': 66,
          'isCurrentUser': true,
        },
      ];
    } catch (e) {
      throw ParrainageException(
        'Erreur lors du chargement du classement: ${e.toString()}',
      );
    }
  }

  // Obtenir l'historique des commissions
  static Future<List<Map<String, dynamic>>> getCommissionHistory() async {
    try {
      await Future.delayed(Duration(milliseconds: 400));

      return [
        {
          'date': DateTime.now().subtract(Duration(hours: 2)),
          'amount': 1000.0,
          'reason': 'Premier achat de Marie K.',
          'type': 'level1',
        },
        {
          'date': DateTime.now().subtract(Duration(days: 1)),
          'amount': 500.0,
          'reason': 'Achat de sous-filleul Pierre M.',
          'type': 'level2',
        },
        {
          'date': DateTime.now().subtract(Duration(days: 3)),
          'amount': 1000.0,
          'reason': 'Premier achat de Jean B.',
          'type': 'level1',
        },
      ];
    } catch (e) {
      throw ParrainageException(
        'Erreur lors du chargement de l\'historique: ${e.toString()}',
      );
    }
  }

  // Obtenir des conseils de parrainage
  static List<Map<String, dynamic>> getParrainageTips() {
    return [
      {
        'title': 'Partage ton expérience',
        'description':
            'Raconte comment Formaneo t\'a aidé dans ton apprentissage. L\'authenticité attire !',
        'icon': 'favorite',
        'color': 0xFFEC4899,
      },
      {
        'title': 'Utilise les réseaux sociaux',
        'description':
            'Partage ton lien sur WhatsApp, Facebook, Instagram. N\'oublie pas tes stories !',
        'icon': 'share',
        'color': 0xFF1E3A8A,
      },
      {
        'title': 'Aide tes filleuls',
        'description':
            'Guide tes filleuls dans leurs premiers pas. Plus ils réussissent, plus tu gagnes !',
        'icon': 'help',
        'color': 0xFF10B981,
      },
      {
        'title': 'Sois régulier',
        'description':
            'Partage régulièrement mais sans spammer. La consistance paye !',
        'icon': 'schedule',
        'color': 0xFFF59E0B,
      },
      {
        'title': 'Montre tes résultats',
        'description':
            'Partage tes gains et certificats. Les preuves sociales sont puissantes !',
        'icon': 'trending_up',
        'color': 0xFF8B5CF6,
      },
    ];
  }

  // Génerer des données de graphique pour les gains
  static List<Map<String, dynamic>> getEarningsChartData() {
    final random = Random();
    final data = <Map<String, dynamic>>[];

    for (int i = 0; i < 12; i++) {
      data.add({
        'week': i + 1,
        'clicks': random.nextInt(50) + 10,
        'signups': random.nextInt(30) + 5,
        'purchases': random.nextInt(15) + 2,
        'commissions': random.nextInt(20) + 5,
      });
    }

    return data;
  }

  // Fonctions privées de simulation
  static Future<String?> _findParrainByCode(String code) async {
    // Simulation de recherche de parrain par code
    final codes = {
      'WB001': 'parrain_1',
      'AB123': 'parrain_2',
      'CD456': 'parrain_3',
    };
    return codes[code];
  }

  static Future<void> _saveParrainage(Parrainage parrainage) async {
    // Simulation de sauvegarde en base de données
    await Future.delayed(Duration(milliseconds: 200));
  }

  static Future<Parrainage?> _findParrainageByFilleul(String filleulId) async {
    // Simulation de recherche de parrainage
    await Future.delayed(Duration(milliseconds: 100));

    return Parrainage(
      id: 'ref_example',
      parrainId: 'parrain_1',
      filleulId: filleulId,
      parrainName: 'Parrain Example',
      filleulName: 'Filleul Example',
      filleulEmail: 'filleul@example.com',
      dateInscription: DateTime.now(),
      level: ParrainageLevel.direct,
      status: ParrainageStatus.pending,
    );
  }

  static Future<String?> _findLevel2Parrain(String parrainLevel1Id) async {
    // Simulation de recherche de parrain niveau 2
    await Future.delayed(Duration(milliseconds: 100));

    // 30% de chance d'avoir un parrain niveau 2
    return Random().nextBool() ? 'parrain_level2' : null;
  }

  static Future<void> _attributeCommission({
    required String parrainId,
    required double amount,
    required String reason,
  }) async {
    // Simulation d'attribution de commission
    await Future.delayed(Duration(milliseconds: 150));

    // Dans une vraie app, on mettrait à jour le solde du parrain
    print('Commission de $amount FCFA attribuée à $parrainId pour: $reason');
  }

  static Future<void> _updateParrainageStatus(
    String parrainageId,
    ParrainageStatus newStatus,
  ) async {
    // Simulation de mise à jour du statut
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class ParrainageException implements Exception {
  final String message;
  final String? code;

  ParrainageException(this.message, {this.code});

  @override
  String toString() => 'ParrainageException: $message';
}
