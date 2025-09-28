class Parrainage {
  final String id;
  final String parrainId;
  final String filleulId;
  final String parrainName;
  final String filleulName;
  final String filleulEmail;
  final DateTime dateInscription;
  final bool hasFirstPurchase;
  final DateTime? firstPurchaseDate;
  final double commissionEarned;
  final ParrainageLevel level;
  final ParrainageStatus status;

  Parrainage({
    required this.id,
    required this.parrainId,
    required this.filleulId,
    required this.parrainName,
    required this.filleulName,
    required this.filleulEmail,
    required this.dateInscription,
    this.hasFirstPurchase = false,
    this.firstPurchaseDate,
    this.commissionEarned = 0.0,
    this.level = ParrainageLevel.direct,
    this.status = ParrainageStatus.pending,
  });

  factory Parrainage.fromJson(Map<String, dynamic> json) {
    return Parrainage(
      id: json['id'],
      parrainId: json['parrainId'],
      filleulId: json['filleulId'],
      parrainName: json['parrainName'],
      filleulName: json['filleulName'],
      filleulEmail: json['filleulEmail'],
      dateInscription: DateTime.parse(json['dateInscription']),
      hasFirstPurchase: json['hasFirstPurchase'] ?? false,
      firstPurchaseDate: json['firstPurchaseDate'] != null 
          ? DateTime.parse(json['firstPurchaseDate']) 
          : null,
      commissionEarned: double.parse(json['commissionEarned'] ?? 0),
      level: ParrainageLevel.values.firstWhere(
        (e) => e.toString() == 'ParrainageLevel.${json['level']}',
        orElse: () => ParrainageLevel.direct,
      ),
      status: ParrainageStatus.values.firstWhere(
        (e) => e.toString() == 'ParrainageStatus.${json['status']}',
        orElse: () => ParrainageStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parrainId': parrainId,
      'filleulId': filleulId,
      'parrainName': parrainName,
      'filleulName': filleulName,
      'filleulEmail': filleulEmail,
      'dateInscription': dateInscription.toIso8601String(),
      'hasFirstPurchase': hasFirstPurchase,
      'firstPurchaseDate': firstPurchaseDate?.toIso8601String(),
      'commissionEarned': commissionEarned,
      'level': level.name,
      'status': status.name,
    };
  }

  Parrainage copyWith({
    String? id,
    String? parrainId,
    String? filleulId,
    String? parrainName,
    String? filleulName,
    String? filleulEmail,
    DateTime? dateInscription,
    bool? hasFirstPurchase,
    DateTime? firstPurchaseDate,
    double? commissionEarned,
    ParrainageLevel? level,
    ParrainageStatus? status,
  }) {
    return Parrainage(
      id: id ?? this.id,
      parrainId: parrainId ?? this.parrainId,
      filleulId: filleulId ?? this.filleulId,
      parrainName: parrainName ?? this.parrainName,
      filleulName: filleulName ?? this.filleulName,
      filleulEmail: filleulEmail ?? this.filleulEmail,
      dateInscription: dateInscription ?? this.dateInscription,
      hasFirstPurchase: hasFirstPurchase ?? this.hasFirstPurchase,
      firstPurchaseDate: firstPurchaseDate ?? this.firstPurchaseDate,
      commissionEarned: commissionEarned ?? this.commissionEarned,
      level: level ?? this.level,
      status: status ?? this.status,
    );
  }
}

enum ParrainageLevel {
  direct,   // Niveau 1 - filleul direct
  indirect, // Niveau 2 - filleul de filleul
}

enum ParrainageStatus {
  pending,    // En attente du premier achat
  active,     // Actif (premier achat effectué)
  inactive,   // Inactif
}

class ParrainageStats {
  final int directReferrals;
  final int indirectReferrals;
  final int totalReferrals;
  final double todayEarnings;
  final double yesterdayEarnings;
  final double currentMonthEarnings;
  final double lastMonthEarnings;
  final double totalEarnings;
  final int referralsWithPurchase;
  final int referralsWithoutPurchase;
  final int level2ReferralsWithDeposit;

  ParrainageStats({
    this.directReferrals = 0,
    this.indirectReferrals = 0,
    this.totalReferrals = 0,
    this.todayEarnings = 0.0,
    this.yesterdayEarnings = 0.0,
    this.currentMonthEarnings = 0.0,
    this.lastMonthEarnings = 0.0,
    this.totalEarnings = 0.0,
    this.referralsWithPurchase = 0,
    this.referralsWithoutPurchase = 0,
    this.level2ReferralsWithDeposit = 0,
  });

  factory ParrainageStats.fromJson(Map<String, dynamic> json) {
    return ParrainageStats(
      directReferrals: json['directReferrals'] ?? 0,
      indirectReferrals: json['indirectReferrals'] ?? 0,
      totalReferrals: json['totalReferrals'] ?? 0,
      todayEarnings: double.parse(json['todayEarnings'] ?? 0),
      yesterdayEarnings: double.parse(json['yesterdayEarnings'] ?? 0),
      currentMonthEarnings: double.parse(json['currentMonthEarnings'] ?? 0),
      lastMonthEarnings: double.parse(json['lastMonthEarnings'] ?? 0),
      totalEarnings: double.parse(json['totalEarnings'] ?? 0),
      referralsWithPurchase: json['referralsWithPurchase'] ?? 0,
      referralsWithoutPurchase: json['referralsWithoutPurchase'] ?? 0,
      level2ReferralsWithDeposit: json['level2ReferralsWithDeposit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'directReferrals': directReferrals,
      'indirectReferrals': indirectReferrals,
      'totalReferrals': totalReferrals,
      'todayEarnings': todayEarnings,
      'yesterdayEarnings': yesterdayEarnings,
      'currentMonthEarnings': currentMonthEarnings,
      'lastMonthEarnings': lastMonthEarnings,
      'totalEarnings': totalEarnings,
      'referralsWithPurchase': referralsWithPurchase,
      'referralsWithoutPurchase': referralsWithoutPurchase,
      'level2ReferralsWithDeposit': level2ReferralsWithDeposit,
    };
  }

  ParrainageStats copyWith({
    int? directReferrals,
    int? indirectReferrals,
    int? totalReferrals,
    double? todayEarnings,
    double? yesterdayEarnings,
    double? currentMonthEarnings,
    double? lastMonthEarnings,
    double? totalEarnings,
    int? referralsWithPurchase,
    int? referralsWithoutPurchase,
    int? level2ReferralsWithDeposit,
  }) {
    return ParrainageStats(
      directReferrals: directReferrals ?? this.directReferrals,
      indirectReferrals: indirectReferrals ?? this.indirectReferrals,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      yesterdayEarnings: yesterdayEarnings ?? this.yesterdayEarnings,
      currentMonthEarnings: currentMonthEarnings ?? this.currentMonthEarnings,
      lastMonthEarnings: lastMonthEarnings ?? this.lastMonthEarnings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      referralsWithPurchase: referralsWithPurchase ?? this.referralsWithPurchase,
      referralsWithoutPurchase: referralsWithoutPurchase ?? this.referralsWithoutPurchase,
      level2ReferralsWithDeposit: level2ReferralsWithDeposit ?? this.level2ReferralsWithDeposit,
    );
  }

  double get conversionRate {
    if (totalReferrals == 0) return 0.0;
    return (referralsWithPurchase / totalReferrals) * 100;
  }
}

class ReferralLink {
  final String userId;
  final String code;
  final String link;
  final DateTime createdAt;
  final int clickCount;
  final int signupCount;
  final int purchaseCount;

  ReferralLink({
    required this.userId,
    required this.code,
    required this.link,
    required this.createdAt,
    this.clickCount = 0,
    this.signupCount = 0,
    this.purchaseCount = 0,
  });

  factory ReferralLink.fromJson(Map<String, dynamic> json) {
    return ReferralLink(
      userId: json['userId'],
      code: json['code'],
      link: json['link'],
      createdAt: DateTime.parse(json['createdAt']),
      clickCount: json['clickCount'] ?? 0,
      signupCount: json['signupCount'] ?? 0,
      purchaseCount: json['purchaseCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'code': code,
      'link': link,
      'createdAt': createdAt.toIso8601String(),
      'clickCount': clickCount,
      'signupCount': signupCount,
      'purchaseCount': purchaseCount,
    };
  }

  ReferralLink copyWith({
    String? userId,
    String? code,
    String? link,
    DateTime? createdAt,
    int? clickCount,
    int? signupCount,
    int? purchaseCount,
  }) {
    return ReferralLink(
      userId: userId ?? this.userId,
      code: code ?? this.code,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
      clickCount: clickCount ?? this.clickCount,
      signupCount: signupCount ?? this.signupCount,
      purchaseCount: purchaseCount ?? this.purchaseCount,
    );
  }

  double get conversionRate {
    if (clickCount == 0) return 0.0;
    return (purchaseCount / clickCount) * 100;
  }
}