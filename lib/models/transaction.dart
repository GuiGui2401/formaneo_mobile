enum TransactionType {
  deposit,
  withdrawal,
  bonus,
  commission,
  cashback,
  purchase,
  quiz_reward,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      type: _parseTransactionType(json['type']),
      amount: double.parse(json['amount'] ?? 0),
      description: json['description'] ?? '',
      status: _parseTransactionStatus(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'description': description,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type) {
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'bonus':
        return TransactionType.bonus;
      case 'commission':
        return TransactionType.commission;
      case 'cashback':
        return TransactionType.cashback;
      case 'purchase':
        return TransactionType.purchase;
      case 'quiz_reward':
        return TransactionType.quiz_reward;
      default:
        return TransactionType.bonus;
    }
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.commission:
        return 'Commission';
      case TransactionType.cashback:
        return 'Cashback';
      case TransactionType.purchase:
        return 'Achat';
      case TransactionType.quiz_reward:
        return 'Récompense Quiz';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.completed:
        return 'Complété';
      case TransactionStatus.failed:
        return 'Échoué';
      case TransactionStatus.cancelled:
        return 'Annulé';
    }
  }

  bool get isCredit {
    return type == TransactionType.deposit ||
           type == TransactionType.bonus ||
           type == TransactionType.commission ||
           type == TransactionType.cashback ||
           type == TransactionType.quiz_reward;
  }
}