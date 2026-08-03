class TransactionModel {
  final String date;
  final String? given;
  final String? received;
  final String balance;
  final String subtitle;

  TransactionModel({
    required this.date,
    this.given,
    this.received,
    required this.balance,
    required this.subtitle,
  });
}