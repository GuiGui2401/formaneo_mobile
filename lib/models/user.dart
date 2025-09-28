class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final double balance;
  final double availableForWithdrawal;
  final double pendingWithdrawals;
  final String? promoCode;
  final String affiliateLink;
  final int totalAffiliates;
  final int monthlyAffiliates;
  final int freeQuizzesLeft;
  final int totalQuizzesTaken;
  final int passedQuizzes;
  final double totalCommissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? settings;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    this.balance = 0.0,
    this.availableForWithdrawal = 0.0,
    this.pendingWithdrawals = 0.0,
    required this.promoCode,
    required this.affiliateLink,
    this.totalAffiliates = 0,
    this.monthlyAffiliates = 0,
    this.freeQuizzesLeft = 5,
    this.totalQuizzesTaken = 0,
    this.passedQuizzes = 0,
    this.totalCommissions = 0.0,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.isPremium = false,
    this.metadata,
    this.settings,
    this.isEmailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      balance: double.parse(json['balance']?.toString() ?? '0'),
      availableForWithdrawal: double.parse(
        json['available_for_withdrawal']?.toString() ?? '0',
      ),
      pendingWithdrawals: double.parse(
        json['pending_withdrawals']?.toString() ?? '0',
      ),
      promoCode: json['promo_code'] != null
        ? json['promo_code'].toString()
        : null,
      affiliateLink: json['affiliate_link'] ?? '',
      totalAffiliates: json['total_affiliates'] ?? 0,
      monthlyAffiliates: json['monthly_affiliates'] ?? 0,
      freeQuizzesLeft: json['free_quizzes_left'] ?? 5,
      totalQuizzesTaken: json['total_quizzes_taken'] ?? 0,
      passedQuizzes: json['passed_quizzes'] ?? 0,
      totalCommissions: double.parse(json['total_commissions']?.toString() ?? '0'),
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      isActive: json['is_active'] ?? true,
      isPremium: json['is_premium'] ?? false,
      metadata: json['metadata'],
      settings: json['settings'],
      isEmailVerified: json['is_email_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'balance': balance,
      'available_for_withdrawal': availableForWithdrawal,
      'pending_withdrawals': pendingWithdrawals,
      'promo_code': promoCode,
      'affiliate_link': affiliateLink,
      'total_affiliates': totalAffiliates,
      'monthly_affiliates': monthlyAffiliates,
      'free_quizzes_left': freeQuizzesLeft,
      'total_quizzes_taken': totalQuizzesTaken,
      'passed_quizzes': passedQuizzes,
      'total_commissions': totalCommissions,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive,
      'is_premium': isPremium,
      'metadata': metadata,
      'settings': settings,
      'is_email_verified': isEmailVerified,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    double? balance,
    double? availableForWithdrawal,
    double? pendingWithdrawals,
    String? promoCode,
    String? affiliateLink,
    int? totalAffiliates,
    int? monthlyAffiliates,
    int? freeQuizzesLeft,
    int? totalQuizzesTaken,
    int? passedQuizzes,
    double? totalCommissions,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isPremium,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? settings,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      balance: balance ?? this.balance,
      availableForWithdrawal: availableForWithdrawal ?? this.availableForWithdrawal,
      pendingWithdrawals: pendingWithdrawals ?? this.pendingWithdrawals,
      promoCode: promoCode ?? this.promoCode,
      affiliateLink: affiliateLink ?? this.affiliateLink,
      totalAffiliates: totalAffiliates ?? this.totalAffiliates,
      monthlyAffiliates: monthlyAffiliates ?? this.monthlyAffiliates,
      freeQuizzesLeft: freeQuizzesLeft ?? this.freeQuizzesLeft,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      passedQuizzes: passedQuizzes ?? this.passedQuizzes,
      totalCommissions: totalCommissions ?? this.totalCommissions,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
